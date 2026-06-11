# frozen_string_literal: true

require_relative 'schema_driven_generator'

# AdvancedEdgeCaseGenerator creates sophisticated invalid test data
# Extends basic edge case generation with constraint-aware invalidation
class AdvancedEdgeCaseGenerator
  class << self
    # Generate comprehensive edge cases for an endpoint
    def generate_comprehensive_edge_cases(path, method = 'post')
      schema = SchemaLoader.load_request_schema(path, method)
      return [] unless schema

      edge_cases = []

      # Generate different categories of invalid data
      edge_cases.concat(generate_constraint_violations(schema))
      edge_cases.concat(generate_type_mismatches(schema))
      edge_cases.concat(generate_structure_errors(schema))
      edge_cases.concat(generate_business_logic_errors(path, schema))

      # Remove duplicates and return
      edge_cases.uniq(&:to_json)
    end

    # Generate data that violates schema constraints
    def generate_constraint_violations(schema)
      violations = []

      schema['properties']&.each do |prop_name, prop_schema|
        next unless prop_schema.is_a?(Hash)

        valid_data = SchemaDrivenGenerator.generate_from_schema(prop_schema)

        # Generate violations based on constraint type
        case prop_schema['type']
        when 'string'
          violations.concat(generate_string_violations(prop_name, prop_schema, valid_data))
        when 'integer', 'number'
          violations.concat(generate_numeric_violations(prop_name, prop_schema, valid_data))
        when 'array'
          violations.concat(generate_array_violations(prop_name, prop_schema, valid_data))
        end
      end

      violations
    end

    # Generate string constraint violations
    def generate_string_violations(prop_name, schema, _valid_value)
      violations = []

      # Min length violation
      violations << { prop_name => 'a' * (schema['minLength'] - 1) } if schema['minLength'] && schema['minLength'] > 0

      # Max length violation
      violations << { prop_name => 'a' * (schema['maxLength'] + 1) } if schema['maxLength']

      # Pattern violation
      violations << { prop_name => 'invalid_pattern_string' } if schema['pattern']

      # Enum violation
      violations << { prop_name => 'invalid_enum_value_not_in_list' } if schema['enum']

      violations
    end

    # Generate numeric constraint violations
    def generate_numeric_violations(prop_name, schema, _valid_value)
      violations = []

      # Minimum violation
      violations << { prop_name => schema['minimum'] - 1 } if schema['minimum']

      # Maximum violation
      violations << { prop_name => schema['maximum'] + 1 } if schema['maximum']

      # Type mismatch (string instead of number)
      violations << { prop_name => 'not_a_number' }

      violations
    end

    # Generate array constraint violations
    def generate_array_violations(prop_name, schema, _valid_value)
      violations = []

      # Min items violation
      violations << { prop_name => [] } if schema['minItems'] && schema['minItems'] > 0

      # Type mismatch (object instead of array)
      violations << { prop_name => { invalid: 'structure' } }

      violations
    end

    # Generate type mismatch errors
    def generate_type_mismatches(schema)
      mismatches = []

      schema['properties']&.each do |prop_name, prop_schema|
        next unless prop_schema.is_a?(Hash)

        type_map = {
          'string' => 12_345,
          'integer' => 'not_an_integer',
          'number' => 'not_a_number',
          'boolean' => 'not_a_boolean',
          'object' => 'not_an_object',
          'array' => 'not_an_array'
        }

        mismatches << { prop_name => type_map[prop_schema['type']] } if prop_schema['type'] && type_map[prop_schema['type']]
      end

      mismatches
    end

    # Generate structural errors (missing required fields, etc.)
    def generate_structure_errors(schema)
      errors = []

      # Missing required fields
      required = schema['required'] || []
      required.each do |field|
        # Create data with this field missing
        valid_data = SchemaDrivenGenerator.generate_from_schema(schema)
        next unless valid_data.is_a?(Hash) && valid_data.key?(field)

        invalid_data = valid_data.dup
        invalid_data.delete(field)
        errors << invalid_data
      end

      # Extra invalid fields
      valid_data = SchemaDrivenGenerator.generate_from_schema(schema)
      if valid_data.is_a?(Hash)
        invalid_data = valid_data.dup
        invalid_data['invalid_extra_field'] = 'should_not_be_here'
        errors << invalid_data
      end

      errors
    end

    # Generate business logic specific errors
    def generate_business_logic_errors(path, schema)
      errors = []

      case path
      when '/v2/orders'
        # Order-specific business logic errors
        errors.concat(generate_order_business_errors(schema))
      when '/v2/calculator/tariff'
        # Calculator-specific errors
        errors.concat(generate_calculator_business_errors(schema))
      when '/v2/delivery'
        # Delivery-specific errors
        errors.concat(generate_delivery_business_errors(schema))
      end

      errors
    end

    # Order-specific business logic validations
    def generate_order_business_errors(schema)
      errors = []

      # Invalid date formats
      invalid_order = SchemaDrivenGenerator.generate_from_schema(schema)
      if invalid_order.is_a?(Hash)
        invalid_order['date'] = 'invalid-date-format'
        errors << invalid_order.dup

        # Impossible delivery scenario
        invalid_order['from_location'] = invalid_order['to_location']
        errors << invalid_order.dup
      end

      errors
    end

    # Calculator-specific business logic validations
    def generate_calculator_business_errors(schema)
      errors = []

      invalid_calc = SchemaDrivenGenerator.generate_from_schema(schema)
      if invalid_calc.is_a?(Hash) && invalid_calc['packages']
        # Package with negative weight
        invalid_calc['packages'].first['weight'] = -100
        errors << invalid_calc.dup
      end

      errors
    end

    # Delivery-specific business logic validations
    def generate_delivery_business_errors(schema)
      errors = []

      invalid_delivery = SchemaDrivenGenerator.generate_from_schema(schema)
      if invalid_delivery.is_a?(Hash)
        # Past delivery date
        invalid_delivery['date'] = '2000-01-01'
        errors << invalid_delivery.dup
      end

      errors
    end

    # Generate test scenarios for comprehensive testing
    def generate_test_scenarios(path, method = 'post')
      scenarios = {
        valid: SchemaDrivenGenerator.generate_request(path, method),
        edge_cases: generate_comprehensive_edge_cases(path, method),
        error_responses: ErrorResponseValidator.test_all_error_codes(path, method)
      }

      # Add scenario metadata
      scenarios[:metadata] = {
        path: path,
        method: method,
        valid_scenarios: scenarios[:valid] ? 1 : 0,
        edge_case_scenarios: scenarios[:edge_cases].size,
        error_scenarios: scenarios[:error_responses].size
      }

      scenarios
    end
  end
end
