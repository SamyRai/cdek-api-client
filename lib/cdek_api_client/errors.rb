# frozen_string_literal: true

module CDEKApiClient
  # Base error class for all CDEK API errors
  class Error < StandardError; end

  # Raised when the API returns a 401 Authentication error
  class AuthenticationError < Error; end

  # Raised when the API returns a 429 Too Many Requests error
  class RateLimitError < Error; end

  # Raised when there is a network or timeout error during the request
  class RequestError < Error; end

  # Raised when the API returns a 5xx Server error
  class ServerError < Error; end

  # Raised when the API returns a 400 Bad Request or validation errors
  class ValidationError < Error
    # @return [Array<Hash>] list of error details returned by the API
    attr_reader :errors
    # @return [String, nil] the cdek number associated with the error
    attr_reader :cdek_number
    # @return [String, nil] the order uuid associated with the error
    attr_reader :uuid

    # @param message [String] the error message
    # @param errors [Array<Hash>] list of detailed errors
    # @param cdek_number [String, nil] optional CDEK number
    # @param uuid [String, nil] optional order UUID
    def initialize(message = 'Validation failed', errors: [], cdek_number: nil, uuid: nil)
      @errors = errors
      @cdek_number = cdek_number
      @uuid = uuid
      super(message)
    end
  end
end
