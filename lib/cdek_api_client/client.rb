# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'logger'
require_relative 'config'
require_relative 'api/generated/auth'
require_relative 'api/generated/calculator'
require_relative 'api/generated/deliverypoint'
require_relative 'api/generated/intake'
require_relative 'api/generated/location'
require_relative 'api/generated/order'
require_relative 'api/generated/passport'
require_relative 'api/generated/photo'
require_relative 'api/generated/prealert'
require_relative 'api/generated/print'
require_relative 'api/generated/receipt'
require_relative 'api/generated/registries'
require_relative 'api/generated/restrictionhints'
require_relative 'api/generated/reverse'
require_relative 'api/generated/schedule'
require_relative 'api/generated/webhook'
require_relative 'compat'

module CDEKApiClient
  # Client class for interacting with the CDEK API.
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

    attr_reader :auth, :calculator, :deliverypoint, :intake, :location, :order,
                :passport, :photo, :prealert, :print, :receipt, :registries,
                :restrictionhints, :reverse, :schedule, :webhook

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

      @auth = CDEKApiClient::API::Auth.new(self)
      @calculator = CDEKApiClient::API::Calculator.new(self)
      @deliverypoint = CDEKApiClient::API::Deliverypoint.new(self)
      @intake = CDEKApiClient::API::Intake.new(self)
      @location = CDEKApiClient::API::Location.new(self)
      @order = CDEKApiClient::API::Order.new(self)
      @passport = CDEKApiClient::API::Passport.new(self)
      @photo = CDEKApiClient::API::Photo.new(self)
      @prealert = CDEKApiClient::API::Prealert.new(self)
      @print = CDEKApiClient::API::Print.new(self)
      @receipt = CDEKApiClient::API::Receipt.new(self)
      @registries = CDEKApiClient::API::Registries.new(self)
      @restrictionhints = CDEKApiClient::API::Restrictionhints.new(self)
      @reverse = CDEKApiClient::API::Reverse.new(self)
      @schedule = CDEKApiClient::API::Schedule.new(self)
      @webhook = CDEKApiClient::API::Webhook.new(self)
    end

    # Legacy aliases for backward compatibility
    alias courier intake
    alias payment receipt
    alias tariff calculator

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
          raise AuthenticationError, "Failed to parse authentication response: #{e.message}"
        rescue ArgumentError => e
          raise AuthenticationError, "Invalid authentication response format: #{e.message}"
        end
      else
        begin
          error_data = JSON.parse(response.body)
          error_response = CDEKApiClient::Entities::AuthErrorResponse.new(
            error: error_data['error'],
            error_description: error_data['error_description']
          )
          raise AuthenticationError, "Authentication failed: #{error_response.error} - #{error_response.error_description}"
        rescue JSON::ParserError, ArgumentError
          raise AuthenticationError, "Authentication failed with HTTP #{response.code}: #{response.body}"
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
    def request(method, path, body: nil, query: nil, parse_response: true)
      uri = URI("#{@base_url}/#{path}")
      uri.query = URI.encode_www_form(query) if query
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = build_request(method, uri, body)
      response = execute_with_retry(http, request)

      return response unless parse_response

      handle_response(response)
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET, EOFError => e
      raise RequestError, "Network error during request: #{e.message}"
    rescue StandardError => e
      raise e if e.is_a?(CDEKApiClient::Error)

      raise RequestError, "HTTP request failed: #{e.message}"
    end

    def validate_uuid(uuid)
      puts "VALIDATING UUID: #{uuid.inspect}"
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
        raise RequestError, "Request failed after #{MAX_RETRIES} retries: #{e.message}"
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
      return response if response.is_a?(Hash) || response.is_a?(Array)

      parsed_response = nil
      begin
        parsed_response = parse_json(response.body) if response.body && !response.body.empty?
      rescue RequestError => e
        raise e if response.is_a?(Net::HTTPSuccess)
      end

      case response
      when Net::HTTPSuccess
        parsed_response
      when Net::HTTPUnauthorized
        raise AuthenticationError, "401 Unauthorized: #{parsed_response || response.body}"
      when Net::HTTPTooManyRequests
        raise RateLimitError, "429 Too Many Requests: #{parsed_response || response.body}"
      when Net::HTTPBadRequest, Net::HTTPUnprocessableEntity
        errors = extract_cdek_errors(parsed_response)
        uuid = extract_uuid(parsed_response)
        cdek_number = extract_cdek_number(parsed_response)
        raise ValidationError.new("Validation failed with HTTP #{response.code}", errors: errors, uuid: uuid, cdek_number: cdek_number)
      when Net::HTTPServerError
        raise ServerError, "Server error #{response.code}: #{parsed_response || response.body}"
      else
        raise RequestError, "Unexpected HTTP #{response.code}: #{parsed_response || response.body}"
      end
    end

    def extract_cdek_errors(parsed)
      return [] unless parsed.is_a?(Hash)

      if parsed['requests']
        parsed['requests'].flat_map { |req| req['errors'] }.compact
      elsif parsed['errors']
        parsed['errors']
      else
        []
      end
    end

    def extract_uuid(parsed)
      parsed.is_a?(Hash) && parsed.dig('requests', 0, 'request_uuid')
    end

    def extract_cdek_number(parsed)
      parsed.is_a?(Hash) && parsed.dig('requests', 0, 'cdek_number')
    end

    # Parses a JSON string, handling any parsing errors.
    #
    # @param body [String] the JSON string to parse.
    # @return [Hash] the parsed JSON.
    def parse_json(body)
      JSON.parse(body)
    rescue JSON::ParserError => e
      raise RequestError, "Failed to parse JSON body: #{e.message}"
    end

    # Logs an error message.
    #
    # @param message [String] the error message to log.
    def log_error(message)
      @logger.error(message)
    end
  end
end

CDEKApiClient::Compat.apply!
