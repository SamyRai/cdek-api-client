# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'logger'
require_relative 'config'
require_relative 'api/courier'
require_relative 'api/location'
require_relative 'api/order'
require_relative 'api/payment'
require_relative 'api/print'
require_relative 'api/tariff'
require_relative 'api/webhook'
require_relative 'entities/auth_response'
require_relative 'entities/auth_error_response'

module CDEKApiClient
  # Client class for interacting with the CDEK API.
  # rubocop:disable Metrics/ClassLength
  class Client
    # Maximum number of retries for API requests
    MAX_RETRIES = 3
    # HTTP status codes that should trigger a retry (Rate Limits and Server Errors)
    RETRY_STATUS_CODES = [429, 500, 502, 503, 504].freeze

    # @return [String] the base API URL
    attr_reader :base_url
    # @return [String] the access token for API authentication.
    attr_reader :token
    # @return [Logger] the logger instance.
    attr_reader :logger
    # @return [CDEKApiClient::Courier] the courier API interface.
    attr_reader :courier
    # @return [CDEKApiClient::Location] the location API interface.
    attr_reader :location
    # @return [CDEKApiClient::Order] the order API interface.
    attr_reader :order
    # @return [CDEKApiClient::Payment] the payment API interface.
    attr_reader :payment
    # @return [CDEKApiClient::Print] the print API interface.
    attr_reader :print
    # @return [CDEKApiClient::Tariff] the tariff API interface.
    attr_reader :tariff
    # @return [CDEKApiClient::Webhook] the webhook API interface.
    attr_reader :webhook

    # Initializes the client with API credentials and configuration.
    #
    # @param client_id [String] the client ID.
    # @param client_secret [String] the client secret.
    # @param environment [Symbol, String] the API environment (:production or :demo).
    #   Defaults to :demo or value from CDEK_API_ENV environment variable.
    # @param base_url [String] custom API base URL (overrides environment).
    #   Defaults to value from CDEK_API_URL environment variable or environment default.
    # @param logger [Logger] the logger instance.
    def initialize(client_id, client_secret, environment: nil, base_url: nil, logger: Logger.new($stdout))
      @client_id = client_id
      @client_secret = client_secret
      @base_url = Config.base_url(environment: environment, custom_url: base_url)
      @logger = logger
      @token = authenticate

      @courier = CDEKApiClient::API::Courier.new(self)
      @location = CDEKApiClient::API::Location.new(self)
      @order = CDEKApiClient::API::Order.new(self)
      @payment = CDEKApiClient::API::Payment.new(self)
      @print = CDEKApiClient::API::Print.new(self)
      @tariff = CDEKApiClient::API::Tariff.new(self)
      @webhook = CDEKApiClient::API::Webhook.new(self)
    end

    # Authenticates with the API and retrieves an access token.
    #
    # @return [String] the access token.
    # @raise [StandardError] if authentication fails.
    def authenticate
      uri = URI(Config.token_url(custom_url: @base_url))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request.set_form_data(
        'grant_type' => 'client_credentials',
        'client_id' => @client_id,
        'client_secret' => @client_secret
      )

      response = execute_with_retry(http, request)

      case response
      when Net::HTTPSuccess
        begin
          data = JSON.parse(response.body)
          auth_response = CDEKApiClient::Entities::AuthResponse.new(
            access_token: data['access_token'],
            token_type: data['token_type'],
            expires_in: data['expires_in'],
            scope: data['scope'],
            jti: data['jti']
          )
          @logger.info("Successfully authenticated, token expires in #{auth_response.expires_in} seconds")
          auth_response.access_token
        rescue JSON::ParserError => e
          raise "Failed to parse authentication response: #{e.message}"
        rescue ArgumentError => e
          raise "Invalid authentication response format: #{e.message}"
        end
      else
        begin
          error_data = JSON.parse(response.body)
          error_response = CDEKApiClient::Entities::AuthErrorResponse.new(
            error: error_data['error'],
            error_description: error_data['error_description']
          )
          raise "Authentication failed: #{error_response.error} - #{error_response.error_description}"
        rescue JSON::ParserError, ArgumentError
          raise "Authentication failed with HTTP #{response.code}: #{response.body}"
        end
      end
    end

    # Makes an HTTP request to the API.
    #
    # @param method [String] the HTTP method (e.g., 'get', 'post').
    # @param path [String] the API endpoint path.
    # @param body [Hash, nil] the request body.
    # @param query [Hash, nil] the query parameters.
    # @return [Hash, Array] the parsed response.
    def request(method, path, body: nil, query: nil)
      uri = URI("#{@base_url}/#{path}")
      uri.query = URI.encode_www_form(query) if query
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = build_request(method, uri, body)
      response = execute_with_retry(http, request)
      handle_response(response)
    rescue StandardError => e
      @logger.error("HTTP request failed: #{e.message}")
      { 'error' => e.message }
    end

    def validate_uuid(uuid)
      raise ArgumentError, 'Invalid UUID format' unless uuid&.match?(/\A[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i)
    end

    private

    # Executes an HTTP request with automatic retry and exponential backoff.
    #
    # @param http [Net::HTTP] the HTTP connection.
    # @param request [Net::HTTPRequest] the HTTP request.
    # @return [Net::HTTPResponse] the HTTP response.
    def execute_with_retry(http, request)
      retries = 0
      loop do
        response = http.request(request)
        if RETRY_STATUS_CODES.include?(response.code.to_i) && retries < MAX_RETRIES
          retries += 1
          sleep(0.5 * (2**retries))
          next
        end
        return response
      rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET, EOFError => e
        if retries < MAX_RETRIES
          retries += 1
          sleep(0.5 * (2**retries))
          next
        end
        raise "Request failed after #{MAX_RETRIES} retries: #{e.message}"
      end
    end

    # Builds an HTTP request with the specified method, URI, and body.
    #
    # @param method [String] the HTTP method (e.g., 'get', 'post').
    # @param uri [URI::HTTP] the URI for the request.
    # @param body [Hash, nil] the request body.
    # @return [Net::HTTPRequest] the constructed HTTP request.
    def build_request(method, uri, body)
      request_class = Net::HTTP.const_get(method.capitalize)
      request = request_class.new(uri.request_uri)
      request['Authorization'] = "Bearer #{@token}"
      request['Content-Type'] = 'application/json'
      request.body = body.to_json if body
      request
    end

    # Handles the API response, parsing JSON and handling errors.
    #
    # @param response [Net::HTTPResponse] the HTTP response.
    # @return [Hash, Array] the parsed response.
    def handle_response(response)
      case response
      when Net::HTTPSuccess
        parsed_response = parse_json(response.body)
        return parsed_response unless parsed_response.is_a?(Hash) && parsed_response.key?('error')

        log_error("API Error: #{parsed_response['error']}")
        { 'error' => parsed_response['error'] }
      when Array, Hash
        response
      else
        parsed_response = parse_json(response.body) if response.body
        log_error("Unexpected response type: #{response.class}")
        { 'error' => parsed_response || "Unexpected response type: #{response.class}" }
      end
    rescue JSON::ParserError => e
      log_error("Failed to parse response: #{e.message}")
      { 'error' => "Failed to parse response: #{e.message}" }
    end

    # Parses a JSON string, handling any parsing errors.
    #
    # @param body [String] the JSON string to parse.
    # @return [Hash] the parsed JSON.
    def parse_json(body)
      JSON.parse(body)
    rescue JSON::ParserError => e
      log_error("Failed to parse JSON body: #{e.message}")
      { 'error' => "Failed to parse JSON body: #{e.message}" }
    end

    # Logs an error message.
    #
    # @param message [String] the error message to log.
    def log_error(message)
      @logger.error(message)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
