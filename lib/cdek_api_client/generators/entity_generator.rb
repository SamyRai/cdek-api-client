# frozen_string_literal: true

require 'json'
require 'erb'
require 'fileutils'
require_relative '../../../spec/support/schema_loader'

module CDEKApiClient
  module Generators
    # EntityGenerator reads the OpenAPI schema and rewrites the Entities
    class EntityGenerator
      # Map CDEK's OpenAPI Component names to our Ruby class names
      MAPPING = {
        'OrderCreateRequestDto' => 'OrderData',
        'PackageRequestDto' => 'Package',
        'ItemRequestDto' => 'Item',
        'RecipientContactDto' => 'Recipient',
        'SenderContactDto' => 'Sender',
        'LocationDto' => 'Location',
        'MoneyDto' => 'Payment',
        'CalculatorRequestDto' => 'TariffData',
        'WebhookDto' => 'Webhook',
        'AdditionalServiceRequestDto' => 'Service',
        'RequestDto' => 'AuthRequest',
        'AuthResponseDto' => 'AuthResponse',
        'ErrorResponseDto' => 'AuthErrorResponse',
        'IntakeAvailableDaysRequestDto' => 'IntakeAvailableDaysRequest',
        'IntakeAvailableDaysResponseDto' => 'IntakeAvailableDaysResponse'
      }.freeze

      # Presenter object for the ERB template
      class EntityContext
        attr_reader :class_name, :properties, :required_fields, :requires

        def initialize(class_name, properties, required_fields, requires)
          @class_name = class_name
          @properties = properties
          @required_fields = required_fields
          @requires = requires
        end

        def template_binding
          binding
        end

        def ruby_type(prop)
          return 'string' unless prop

          type = prop['type']
          case type
          when 'string' then 'string'
          when 'integer' then 'integer'
          when 'number' then 'integer' # Assuming number maps to integer/float based on needs, let's stick to integer/number logic
          when 'boolean' then 'boolean'
          when 'array' then 'array'
          when 'object' then 'object'
          else
            if prop['$ref']
              'object'
            else
              'string'
            end
          end
        end

        def items_validation(prop)
          if prop['type'] == 'array' && prop['items']
            if prop['items']['$ref']
              ref_name = prop['items']['$ref'].split('/').last
              mapped_class = MAPPING[ref_name]
              if mapped_class
                ", items: [#{mapped_class}]"
              else
                ', items: [{ type: :object }]'
              end
            else
              type = ruby_type(prop['items'])
              ", items: [{ type: :#{type} }]"
            end
          elsif prop['$ref'] || (prop['type'] == 'object' && prop['properties'])
            ''
          else
            ''
          end
        end

        def yard_type(prop)
          case ruby_type(prop)
          when 'string' then 'String'
          when 'integer' then 'Integer'
          when 'boolean' then 'Boolean'
          when 'array'
            if prop['items'] && prop['items']['$ref']
              ref_name = prop['items']['$ref'].split('/').last
              mapped_class = MAPPING[ref_name] || 'Object'
              "Array<#{mapped_class}>"
            else
              'Array'
            end
          when 'object'
            if prop['$ref']
              ref_name = prop['$ref'].split('/').last
              MAPPING[ref_name] || 'Object'
            else
              'Object'
            end
          else 'Object'
          end
        end

        def initialize_args(properties, required_fields)
          required = []
          optional = []

          properties.each_key do |k|
            if required_fields.include?(k.to_s)
              required << "#{k}:"
            else
              optional << "#{k}: nil"
            end
          end

          (required + optional).join(', ')
        end
      end

      def initialize
        # SchemaLoader looks for cdek_api_schemas.json in the current working directory
        @schemas = SchemaLoader.load_schemas['schemas']
      end

      def generate_all
        puts 'Loading CDEK OpenAPI schemas...'
        components = {}

        # Collect all components across all schemas
        @schemas.each do |schema_entry|
          next unless schema_entry.dig('schema', 'components', 'schemas')

          components.merge!(schema_entry['schema']['components']['schemas'])
        end

        puts "Found #{components.keys.size} components. Generating mapped entities..."

        MAPPING.each do |dto_name, class_name|
          schema = components[dto_name]
          unless schema
            puts "WARNING: Could not find DTO '#{dto_name}' in OpenAPI schema. Skipping '#{class_name}'..."
            next
          end

          generate_class(class_name, schema)
        end

        puts 'Done!'
      end

      private

      def generate_class(class_name, schema)
        properties = schema['properties'] || {}
        required_fields = schema['required'] || []

        # Collect dependencies
        requires = []
        properties.each_value do |prop|
          if prop['$ref']
            ref_name = prop['$ref'].split('/').last
            mapped = MAPPING[ref_name]
            requires << mapped.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase if mapped && mapped != class_name
          elsif prop['type'] == 'array' && prop['items'] && prop['items']['$ref']
            ref_name = prop['items']['$ref'].split('/').last
            mapped = MAPPING[ref_name]
            requires << mapped.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase if mapped && mapped != class_name
          end
        end
        requires.uniq!

        # Setup context
        context = EntityContext.new(class_name, properties, required_fields, requires)

        # Load and render template
        template_path = File.join(__dir__, 'templates', 'entity.rb.erb')
        template_content = File.read(template_path)
        erb = ERB.new(template_content, trim_mode: '-')
        result = erb.result(context.template_binding)

        # Write to file
        file_name = class_name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
        output_path = File.expand_path("../entities/#{file_name}.rb", __dir__)
        File.write(output_path, result)

        puts "Generated #{class_name} -> #{file_name}.rb"
      end
    end
  end
end
