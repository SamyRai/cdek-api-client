# frozen_string_literal: true

require 'fileutils'
require 'json'
require_relative '../../../spec/support/schema_driven_generator'

module CDEKApiClient
  module Generators
    # FixtureGenerator generates static JSON fixtures for testing based on OpenAPI schemas
    class FixtureGenerator
      def endpoints
        schemas = SchemaLoader.load_schemas['schemas']
        all_endpoints = []

        schemas.each do |schema_entry|
          schema = schema_entry['schema']
          next unless schema['paths']

          schema['paths'].each do |path, methods|
            methods.each_key do |method|
              next unless %w[get post put delete patch].include?(method)

              # Get the 200/201 response status if any
              status = '200'
              status = methods[method]['responses'].keys.find { |k| k.start_with?('2') } || '200' if methods[method]['responses']

              all_endpoints << { path: path, method: method, response_status: status.to_i }
            end
          end
        end

        all_endpoints.uniq { |e| [e[:path], e[:method]] }
      end

      def initialize
        @fixtures_dir = File.expand_path('../../testing/fixtures', __dir__)
        @requests_dir = File.join(@fixtures_dir, 'requests')
        @responses_dir = File.join(@fixtures_dir, 'responses')
      end

      def generate_all
        puts 'Generating static JSON fixtures from OpenAPI schemas...'
        FileUtils.mkdir_p(@requests_dir)
        FileUtils.mkdir_p(@responses_dir)

        endpoints.each do |endpoint|
          path = endpoint[:path]
          method = endpoint[:method]
          status = endpoint[:response_status]

          file_base = path.gsub('/', '_').gsub(/_{2,}/, '_').gsub(/[{}]/, '').sub(/^_/, '') + "_#{method}"

          # Generate request fixture if it exists
          req_data = SchemaDrivenGenerator.generate_request(path, method)
          if req_data
            req_file = File.join(@requests_dir, "#{file_base}.json")
            File.write(req_file, JSON.pretty_generate(req_data))
            puts "Generated request fixture: #{req_file}"
          end

          # Generate response fixture
          res_data = SchemaDrivenGenerator.generate_response(path, method, status)
          next unless res_data

          # Workaround for CDEK OpenAPI schema bug where list endpoints are typed as objects
          array_endpoints = %w[
            /v2/location/cities
            /v2/location/regions
            /v2/location/postalcodes
            /v2/location/offices
            /v2/location/suggest/cities
            /v2/registries
            /v2/deliverypoints
          ]
          res_data = [res_data] if array_endpoints.include?(path) && res_data.is_a?(Hash)

          res_file = File.join(@responses_dir, "#{file_base}_#{status}.json")
          File.write(res_file, JSON.pretty_generate(res_data))
          puts "Generated response fixture: #{res_file}"
        end

        puts 'Fixtures generation complete!'
      end
    end
  end
end
