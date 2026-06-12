# frozen_string_literal: true

require 'json'

# SchemaLoader loads and parses OpenAPI schemas from cdek_api_schemas.json
# Provides methods to extract request and response schemas for specific endpoints
class SchemaLoader
  SCHEMAS_FILE = 'cdek_api_schemas.json'

  class << self
    attr_accessor :current_context_schema

    # Load the complete schemas data
    def load_schemas
      @load_schemas ||= JSON.parse(File.read(SCHEMAS_FILE, encoding: 'UTF-8'))
    end

    # Get the main API schema (index 3 - Main Integration API) which contains most endpoints
    def main_api_schema
      schemas = load_schemas
      schemas['schemas'].find { |schema| schema['index'] == 3 }
    end

    # Get the locations API schema (index 2)
    def locations_api_schema
      schemas = load_schemas
      schemas['schemas'].find { |schema| schema['index'] == 2 }
    end

    # Get schema by index
    def schema_by_index(index)
      schemas = load_schemas
      schemas['schemas'].find { |schema| schema['index'] == index }
    end

    # Find schema for a specific endpoint and HTTP method
    def find_endpoint_schema(path, method = 'post')
      # Try main API schema first (index 3)
      schema = main_api_schema
      if schema && schema['schema']['paths'] && schema['schema']['paths'][path]
        endpoint = schema['schema']['paths'][path]
        return endpoint[method.downcase] if endpoint[method.downcase]
      end

      # Try locations API schema (index 2)
      schema = locations_api_schema
      if schema && schema['schema']['paths'] && schema['schema']['paths'][path]
        endpoint = schema['schema']['paths'][path]
        return endpoint[method.downcase] if endpoint[method.downcase]
      end

      # Try other schemas if needed
      schemas = load_schemas
      schemas['schemas'].each do |schema_entry|
        next if [2, 3].include?(schema_entry['index']) # Skip schemas we already checked

        schema = schema_entry['schema']
        next unless schema['paths'] && schema['paths'][path]

        endpoint = schema['paths'][path]
        return endpoint[method.downcase] if endpoint && endpoint[method.downcase]
      end

      nil
    end

    # Extract request schema for an endpoint
    def load_request_schema(path, method = 'post')
      endpoint_schema = find_endpoint_schema(path, method)
      return nil unless endpoint_schema && endpoint_schema['requestBody']

      content = endpoint_schema['requestBody']['content']
      return nil unless content && content['application/json']

      schema_ref = content['application/json']['schema']
      
      # Find the schema that contains this endpoint to resolve references correctly
      context_schema = find_context_schema_for_endpoint(path)
      self.current_context_schema = context_schema
      resolve_schema_reference_with_context(schema_ref, context_schema)
    end

    # Extract response schema for an endpoint and status code
    def load_response_schema(path, method = 'post', status_code = 200)
      endpoint_schema = find_endpoint_schema(path, method)
      return nil unless endpoint_schema && endpoint_schema['responses']

      response = endpoint_schema['responses'][status_code.to_s]
      return nil unless response && response['content'] && response['content']['application/json']

      schema_ref = response['content']['application/json']['schema']

      # Find the schema that contains this endpoint to resolve references correctly
      context_schema = find_context_schema_for_endpoint(path)
      self.current_context_schema = context_schema
      resolve_schema_reference_with_context(schema_ref, context_schema)
    end

    # Find which schema file contains the given path
    def find_context_schema_for_endpoint(path)
      schemas = load_schemas
      schemas['schemas'].each do |schema_entry|
        schema = schema_entry['schema']
        return schema if schema['paths'] && schema['paths'][path]
      end
      nil
    end

    # Resolve schema reference with specific context schema
    def resolve_schema_reference_with_context(schema_ref, context_schema)
      return schema_ref unless schema_ref.is_a?(Hash) && schema_ref['$ref']
      return schema_ref unless context_schema

      ref_path = schema_ref['$ref']
      if ref_path.start_with?('#/components/schemas/')
        schema_name = ref_path.sub('#/components/schemas/', '')
        context_schema['components']['schemas'][schema_name]
      else
        # Handle other types of references if needed
        schema_ref
      end
    end

    # Resolve a $ref reference to the actual schema by searching across all schemas
    def resolve_schema_reference(schema_ref)
      return schema_ref unless schema_ref.is_a?(Hash) && schema_ref['$ref']

      ref_path = schema_ref['$ref']
      if ref_path.start_with?('#/components/schemas/')
        schema_name = ref_path.sub('#/components/schemas/', '')
        
        # First try to resolve in the current context to avoid naming collisions (e.g. RequestDto)
        if current_context_schema && current_context_schema['components'] && current_context_schema['components']['schemas']
          resolved = current_context_schema['components']['schemas'][schema_name]
          return resolved if resolved
        end

        # Fallback to searching all schemas
        load_schemas['schemas'].each do |schema_entry|
          schema = schema_entry['schema']
          next unless schema['components'] && schema['components']['schemas']
          
          if schema['components']['schemas'][schema_name]
            return schema['components']['schemas'][schema_name]
          end
        end
      end
      
      schema_ref
    end

    # Get all available endpoints
    def available_endpoints
      schema = main_api_schema
      return [] unless schema && schema['schema']['paths']

      schema['schema']['paths'].keys
    end

    # Get all HTTP methods for a specific endpoint
    def endpoint_methods(path)
      endpoint_schema = find_endpoint_schema(path)
      return [] unless endpoint_schema

      endpoint_schema.keys
    end

    # Check if an endpoint exists
    def endpoint_exists?(path, method = 'post')
      find_endpoint_schema(path, method) != nil
    end
  end
end
