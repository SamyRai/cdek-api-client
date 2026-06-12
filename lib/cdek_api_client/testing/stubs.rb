# frozen_string_literal: true

module CDEKApiClient
  module Testing
    # Stubs provides WebMock interceptors backed by the schema-driven JSON fixtures
    module Stubs
      extend FixtureLoader

      class << self
        # Stubs an API endpoint with the pre-generated JSON response fixture
        #
        # @param path [String] The endpoint path, e.g. '/v2/orders'
        # @param method [String, Symbol] The HTTP method, e.g. :post or 'post'
        # @param status [Integer] The HTTP status code to return (default 200/201 depending on fixture)
        # @param base_url [String] The API base URL to intercept
        def stub_endpoint(path, method = :post, status = nil, base_url = 'https://api.cdek.ru/v2')
          require 'webmock'

          # Try to resolve status if not provided explicitly
          if status.nil?
            status = load_response_fixture(path, method.to_s, 200) ? 200 : 202
            status = 201 if !load_response_fixture(path, method.to_s, status) && load_response_fixture(path, method.to_s, 201)
          end

          response_data = load_response_fixture(path, method.to_s, status) || {}

          WebMock::API.stub_request(method.to_sym, /#{Regexp.escape(base_url)}.*#{Regexp.escape(path.sub('/v2', ''))}/)
                      .to_return(
                        status: status,
                        body: response_data.to_json,
                        headers: { 'Content-Type' => 'application/json' }
                      )
        end

        # Helper to stub auth endpoint
        def stub_auth(base_url = 'https://api.cdek.ru/v2')
          require 'webmock'

          response_data = load_response_fixture('/v2/oauth/token', 'post', 200) || {
            access_token: 'mock_token',
            token_type: 'bearer',
            expires_in: 3600,
            scope: '',
            jti: 'mock_jti'
          }

          WebMock::API.stub_request(:post, "#{base_url}/oauth/token?parameters")
                      .to_return(
                        status: 200,
                        body: response_data.to_json,
                        headers: { 'Content-Type' => 'application/json' }
                      )
        end
      end
    end
  end
end
