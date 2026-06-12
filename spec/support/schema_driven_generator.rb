# frozen_string_literal: true

require_relative 'schema_loader'
require 'faker'

# SchemaDrivenGenerator generates valid test data from JSON schemas
# Supports constraints, nested objects, arrays, and realistic data generation
class SchemaDrivenGenerator
  class << self
    # Generate a valid request for an endpoint
    def generate_request(path, method = 'post')
      schema = SchemaLoader.load_request_schema(path, method)
      return nil unless schema

      generate_from_schema(schema)
    end

    # Generate a valid response for an endpoint and status code
    def generate_response(path, method = 'post', status_code = 200)
      schema = SchemaLoader.load_response_schema(path, method, status_code)
      return nil unless schema

      generate_from_schema(schema)
    end

    # Generate test data from a JSON schema
    def generate_from_schema(schema, prop_name = nil)
      return nil unless schema

      case schema['type']
      when 'object'
        generate_object(schema)
      when 'array'
        generate_array(schema)
      when 'string'
        generate_string(schema, prop_name)
      when 'integer'
        generate_integer(schema)
      when 'number'
        generate_number(schema)
      when 'boolean'
        generate_boolean(schema)
      else
        # Handle other types or references
        if schema['$ref']
          resolved_schema = SchemaLoader.resolve_schema_reference(schema)
          generate_from_schema(resolved_schema, prop_name)
        elsif schema['oneOf'] || schema['anyOf']
          # Choose first option for simplicity
          option = schema['oneOf']&.first || schema['anyOf']&.first
          generate_from_schema(option, prop_name) if option
        elsif schema['allOf']
          # Merge all schemas
          merged_schema = merge_all_of_schemas(schema['allOf'])
          generate_from_schema(merged_schema, prop_name)
        else
          # Unknown type, return a basic value
          'test_value'
        end
      end
    end

    private

    def generate_object(schema)
      return {} unless schema['properties']

      result = {}

      # Handle required properties first
      required = schema['required'] || []

      # Generate all properties
      schema['properties'].each do |property_name, property_schema|
        next unless property_schema # Skip if no schema defined

        # Special handling for currency fields
        result[property_name] = if property_name == 'currency' && property_schema['type'] == 'integer'
                                  # Generate valid currency code integers (1=RUB, 3=USD, 4=EUR, etc.)
                                  [1, 2, 3, 4, 5, 6].sample
                                else
                                  generate_from_schema(property_schema, property_name)
                                end
      end

      result
    end

    def generate_array(schema)
      return [] unless schema['items']

      # Generate 1-3 items for testing
      count = rand(1..3)
      Array.new(count) { generate_from_schema(schema['items']) }
    end

    def generate_string(schema, prop_name = nil)
      # Handle enums first
      return schema['enum'].first if schema['enum']

      # Handle patterns
      if schema['pattern']
        # For now, generate a basic string that might match common patterns
        case schema['pattern']
        when /^\d+$/
          rand(1000..9999).to_s
        when /^[\w.-]+@[\w.-]+\.\w+$/
          Faker::Internet.email
        when /^\+?\d{10,15}$/
          Faker::PhoneNumber.cell_phone_in_e164
        else
          # Generate string within length constraints
          generate_string_with_constraints(schema, prop_name)
        end
      else
        generate_string_with_constraints(schema, prop_name)
      end
    end

    def generate_string_with_constraints(schema, prop_name = nil)
      min_length = schema['minLength'] || 1
      max_length = schema['maxLength'] || 50

      # Generate realistic strings based on common field names
      if schema['format'] == 'uuid' || prop_name&.downcase&.include?('uuid')
        'c80a68c1-1e43-42ca-b7e2-de1aad5b7d93'
      elsif prop_name&.downcase == 'state'
        'ACCEPTED'
      elsif schema['description']&.downcase&.include?('email')
        Faker::Internet.email
      elsif schema['description']&.downcase&.include?('phone')
        Faker::PhoneNumber.cell_phone_in_e164
      elsif schema['description']&.downcase&.include?('name')
        Faker::Name.name
      elsif schema['description']&.downcase&.include?('address')
        Faker::Address.full_address
      elsif schema['description']&.downcase&.include?('city')
        Faker::Address.city
      else
        # Generate alphanumeric string of appropriate length
        length = rand(min_length..max_length)
        Faker::Alphanumeric.alphanumeric(number: length)
      end
    end

    def generate_integer(schema)
      min_value = schema['minimum'] || 0
      max_value = schema['maximum'] || 1000

      # Handle exclusive bounds
      min_value += 1 if schema['exclusiveMinimum']
      max_value -= 1 if schema['exclusiveMaximum']

      rand(min_value..max_value)
    end

    def generate_number(schema)
      # For simplicity, generate integers for numbers
      # Could be enhanced to generate floats
      generate_integer(schema).to_f
    end

    def generate_boolean(_schema)
      [true, false].sample
    end

    def merge_all_of_schemas(schemas)
      merged = { 'type' => 'object', 'properties' => {} }

      schemas.each do |schema|
        resolved = schema['$ref'] ? SchemaLoader.resolve_schema_reference(schema) : schema

        merged['properties'].merge!(resolved['properties']) if resolved['properties']

        if resolved['required']
          merged['required'] ||= []
          merged['required'].concat(resolved['required'])
        end
      end

      merged['required']&.uniq!
      merged
    end
  end
end
