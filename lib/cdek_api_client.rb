# frozen_string_literal: true

require_relative 'cdek_api_client/client'
Dir[File.join(__dir__, 'cdek_api_client/entities', '*.rb')].each { |file| require file }
require_relative 'cdek_api_client/errors'
require_relative 'cdek_api_client/version'

# frozen_string_literal: true

# CDEKApiClient is a Ruby client for interacting with the CDEK API.
# It provides functionalities for order creation, tracking, tariff calculation,
# location data retrieval, and webhook management. This gem ensures clean,
# robust, and maintainable code with proper validations.
#
# To use this gem, configure it with your CDEK API client ID and secret,
# and then access various API functionalities through the provided client.
#
# Example:
#   CDEKApiClient.configure do |config|
#     config.client_id = 'your_client_id'
#     config.client_secret = 'your_client_secret'
#   end
#   client = CDEKApiClient.client
#
# For more details, refer to the README.
module CDEKApiClient
  class << self
    # Configures the client with the provided block.
    # @yield [self] Yields the client to the provided block.
    def configure
      yield self
    end

    # @!attribute [rw] client_id
    #   @return [String] The client ID for authentication.
    attr_accessor :client_id

    # @!attribute [rw] client_secret
    #   @return [String] The client secret for authentication.
    attr_accessor :client_secret
  end

  # Returns the CDEK API client.
  # @return [CDEKApiClient::Client] The CDEK API client instance.
  def self.client
    @client ||= CDEKApiClient::Client.new(client_id, client_secret)
  end
end
