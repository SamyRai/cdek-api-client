# frozen_string_literal: true

require_relative 'schema_driven_generator'
require_relative 'schema_validator'

# ContractTester provides high-level contract testing for API endpoints
# Tests that request/response pairs conform to their OpenAPI schemas
class ContractTester
  extend FixtureLoader

  class << self
    # Test a complete request/response contract for an endpoint
    def test_contract(path, method = 'post', &block)
      raise ArgumentError, 'Block required for API call' unless block_given?

      # Generate valid request data from schema
      request_data = load_request_fixture(path, method)
      raise "Could not generate request data for #{path} #{method}" unless request_data

      # Validate request data against schema
      request_validation = SchemaValidator.validate_request(path, method, request_data)
      raise "Generated request data is invalid: #{request_validation[:errors].join(', ')}" unless request_validation[:valid]

      # Execute the API call
      begin
        response_data = block.call(request_data)
      rescue StandardError => e
        raise "API call failed: #{e.message}"
      end

      # Validate response data against schema
      success_status = find_success_status_code(path, method)
      response_validation = SchemaValidator.validate_response(path, method, success_status, response_data)
      raise "Response data does not match schema: #{response_validation[:errors].join(', ')}" unless response_validation[:valid]

      # Return the response for further testing if needed
      response_data
    end

    # Test only request generation and validation (for unit tests)
    def test_request_contract(path, method = 'post')
      request_data = load_request_fixture(path, method)
      raise "Could not generate request data for #{path} #{method}" unless request_data

      validation = SchemaValidator.validate_request(path, method, request_data)
      raise "Generated request data is invalid: #{validation[:errors].join(', ')}" unless validation[:valid]

      request_data
    end

    # Test only response validation (for mocking tests)
    def test_response_contract(path, method = 'post', status_code = nil, response_data)
      status_code ||= find_success_status_code(path, method)
      validation = SchemaValidator.validate_response(path, method, status_code, response_data)
      raise "Response data does not match schema: #{validation[:errors].join(', ')}" unless validation[:valid]

      true
    end

    # Find the appropriate success status code from the schema
    def find_success_status_code(path, method = 'post')
      endpoint_schema = SchemaLoader.find_endpoint_schema(path, method)
      return 200 unless endpoint_schema && endpoint_schema['responses']

      # Look for success status codes (2xx)
      success_codes = endpoint_schema['responses'].keys.select { |code| code.start_with?('2') }
      # Return the first success code, or 200 as fallback
      success_codes.first&.to_i || 200
    end

    # Test error response contracts
    def test_error_contract(path, method = 'post', status_code, &block)
      raise ArgumentError, 'Block required for API call' unless block_given?

      # Generate valid request data
      request_data = load_request_fixture(path, method)
      raise "Could not generate request data for #{path} #{method}" unless request_data

      # Execute API call that should result in error
      begin
        response_data = block.call(request_data)
      rescue StandardError => e
        raise "API call failed: #{e.message}"
      end

      # Validate error response against schema
      validation = SchemaValidator.validate_response(path, method, status_code, response_data)
      raise "Error response data does not match schema: #{validation[:errors].join(', ')}" unless validation[:valid]

      response_data
    end

    # RSpec helper methods for contract testing
    module RSpecHelpers
      def test_api_contract(path, method = 'post', &)
        ContractTester.test_contract(path, method, &)
      end

      def test_request_only_contract(path, method = 'post')
        ContractTester.test_request_contract(path, method)
      end

      def test_response_only_contract(path, method = 'post', status_code = 200, response_data)
        ContractTester.test_response_contract(path, method, status_code, response_data)
      end

      def test_error_contract(path, method = 'post', status_code, &)
        ContractTester.test_error_contract(path, method, status_code, &)
      end
    end
  end
end

# Make helper methods available globally for testing
def test_api_contract(path, method = 'post', &)
  ContractTester.test_contract(path, method, &)
end

def test_request_only_contract(path, method = 'post')
  ContractTester.test_request_contract(path, method)
end

def test_response_only_contract(path, method = 'post', status_code = 200, response_data)
  ContractTester.test_response_contract(path, method, status_code, response_data)
end

def test_error_contract(path, method = 'post', status_code, &)
  ContractTester.test_error_contract(path, method, status_code, &)
end
