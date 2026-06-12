# frozen_string_literal: true

require 'erb'
require_relative '../../../spec/support/schema_loader'

module CDEKApiClient
  module Generators
    # DocGenerator parses OpenAPI schemas and creates a comprehensive API reference markdown file.
    class DocGenerator
      def initialize
        @output_file = File.expand_path('../../../API_REFERENCE.md', __dir__)
      end

      def generate_all
        schemas = SchemaLoader.load_schemas['schemas']
        endpoints_by_tag = Hash.new { |h, k| h[k] = [] }

        schemas.each do |schema_entry|
          schema = schema_entry['schema']
          next unless schema['paths']

          schema['paths'].each do |path, methods|
            methods.each do |method, details|
              next unless %w[get post put delete patch].include?(method)

              tag = (details['tags'] || ['Common']).first

              title = details['summary']
              if !title || title.empty? || title == 'No description available'
                title = details['operationId'] ? details['operationId'].gsub(/([A-Z])/, ' \1').capitalize : 'Endpoint'
              end

              request_schema_node = details.dig('requestBody', 'content', 'application/json', 'schema')
              request_props = []
              if request_schema_node
                SchemaLoader.current_context_schema = schema
                resolved_req = SchemaLoader.resolve_schema_reference(request_schema_node)
                if resolved_req && resolved_req['properties']
                  request_props = resolved_req['properties'].map do |k, v|
                    type = v['type'] || (v['$ref'] ? 'object' : 'any')
                    type = "#{type}[]" if type == 'array'
                    { name: k, type: type, description: v['description'] }
                  end
                end
              end

              response_props = []
              response_ref = nil
              %w[200 202].each do |code|
                resp_schema_node = details.dig('responses', code, 'content', 'application/json', 'schema')
                next unless resp_schema_node

                response_ref = resp_schema_node['$ref']&.split('/')&.last
                SchemaLoader.current_context_schema = schema
                resolved_resp = SchemaLoader.resolve_schema_reference(resp_schema_node)
                if resolved_resp && resolved_resp['properties']
                  response_props = resolved_resp['properties'].map do |k, v|
                    type = v['type'] || (v['$ref'] ? 'object' : 'any')
                    type = "#{type}[]" if type == 'array'
                    { name: k, type: type, description: v['description'] }
                  end
                end
                break
              end

              endpoints_by_tag[tag] << {
                path: path,
                method: method.upcase,
                summary: title,
                description: details['description'],
                operationId: details['operationId'],
                request_schema: request_schema_node ? request_schema_node['$ref']&.split('/')&.last : nil,
                response_schema: response_ref,
                request_props: request_props,
                response_props: response_props
              }
            end
          end
        end

        content = generate_markdown(endpoints_by_tag)
        File.write(@output_file, content)
        puts "Generated API_REFERENCE.md with #{endpoints_by_tag.keys.size} sections!"
      end

      private

      def generate_markdown(endpoints_by_tag)
        template = <<~ERB
          # CDEK API Reference

          This document provides a reference of all available API endpoints supported by this client, automatically generated from the official OpenAPI schemas.

          <% endpoints_by_tag.sort.each do |tag, endpoints| %>
          ## <%= tag %>

          <% endpoints.sort_by { |e| e[:path] }.each do |endpoint| %>
          ### <%= endpoint[:summary] %>

          **HTTP Method:** `<%= endpoint[:method] %>`#{'  '}
          **Path:** `<%= endpoint[:path] %>`#{'  '}
          <% if endpoint[:operationId] %>
          **Operation ID:** `<%= endpoint[:operationId] %>`
          <% end %>
          <% if endpoint[:request_schema] %>
          **Request Body:** `<%= endpoint[:request_schema] %>`
          <% if endpoint[:request_props] && !endpoint[:request_props].empty? %>
          | Attribute | Type | Description |
          | --------- | ---- | ----------- |
          <% endpoint[:request_props].each do |prop| %>| `<%= prop[:name] %>` | `<%= prop[:type] %>` | <%= prop[:description]&.gsub("\n", " ") %> |
          <% end %>
          <% end %>
          <% end %>

          <% if endpoint[:response_schema] %>
          **Success Response:** `<%= endpoint[:response_schema] %>`
          <% if endpoint[:response_props] && !endpoint[:response_props].empty? %>
          | Attribute | Type | Description |
          | --------- | ---- | ----------- |
          <% endpoint[:response_props].each do |prop| %>| `<%= prop[:name] %>` | `<%= prop[:type] %>` | <%= prop[:description]&.gsub("\n", " ") %> |
          <% end %>
          <% end %>
          <% end %>

          <% if endpoint[:description] %>
          <%= endpoint[:description] %>
          <% end %>

          ---
          <% end %>
          <% end %>
        ERB

        ERB.new(template, trim_mode: '-').result(binding)
      end
    end
  end
end
