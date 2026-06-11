#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'time'

# Script to pull and organize CDEK API schemas from documentation
class CdekSchemaPuller
  CDEK_API_DOCS_URL = 'https://gateway.cdek.ru/api-cdek-docs/web/docs?sectionId=api_v2_integration'
  OUTPUT_FILE = 'cdek_api_schemas.json'

  def initialize
    @schemas = []
  end

  def fetch_api_documentation
    puts "Fetching CDEK API documentation from #{CDEK_API_DOCS_URL}..."

    uri = URI(CDEK_API_DOCS_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request['User-Agent'] = 'CDEK-API-Client/1.0'

    response = http.request(request)

    if response.code != '200'
      puts "Error: Failed to fetch API documentation (HTTP #{response.code})"
      return nil
    end

    puts 'Successfully fetched API documentation'
    response.body
  rescue StandardError => e
    puts "Error fetching API documentation: #{e.message}"
    nil
  end

  def parse_api_response(raw_response)
    puts 'Parsing API response...'

    begin
      # The response appears to be a JSON array of OpenAPI schema strings
      api_data = JSON.parse(raw_response)

      if api_data.is_a?(Array)
        puts "Found #{api_data.length} schema entries"
        api_data.each_with_index do |schema_str, index|
          puts "Processing schema #{index + 1}/#{api_data.length}..."
          process_schema_string(schema_str, index)
        end
      else
        puts "Unexpected response format. Expected array, got #{api_data.class}"
        return false
      end

      true
    rescue JSON::ParserError => e
      puts "Error parsing JSON response: #{e.message}"
      false
    end
  end

  def process_schema_string(schema_str, index)
    schema = JSON.parse(schema_str)
    version_info = extract_version_info(schema)

    schema_entry = {
      'index' => index,
      'metadata' => version_info,
      'schema' => clean_schema(schema)
    }

    @schemas << schema_entry
  rescue JSON::ParserError => e
    puts "Warning: Failed to parse schema #{index + 1}: #{e.message}"
  end

  def extract_version_info(schema)
    info = schema['info'] || {}

    {
      'version' => info['version'] || 'unknown',
      'title' => info['title'] || 'Unknown',
      'description' => info['description'] || '',
      'openapi_version' => schema['openapi'] || 'unknown',
      'servers' => schema['servers'] || [],
      'tags_count' => (schema['tags'] || []).length,
      'has_paths' => schema.key?('paths'),
      'has_components' => schema.key?('components'),
      'paths_count' => schema['paths'] ? schema['paths'].length : 0
    }
  end

  def clean_schema(schema)
    cleaned = {}

    schema.each do |key, value|
      next if value.nil?
      next if %w[description example summary x-displayName].include?(key)

      if value.is_a?(Hash)
        cleaned_dict = clean_schema(value)
        cleaned[key] = cleaned_dict unless cleaned_dict.empty?
      elsif value.is_a?(Array)
        cleaned_list = value.map do |item|
          item.is_a?(Hash) ? clean_schema(item) : item
        end.compact
        cleaned[key] = cleaned_list unless cleaned_list.empty?
      else
        cleaned[key] = value
      end
    end

    cleaned
  end

  def organize_schemas
    puts 'Organizing schemas...'

    {
      'metadata' => {
        'total_schemas' => @schemas.length,
        'parsed_at' => Time.now.utc.iso8601,
        'source_url' => CDEK_API_DOCS_URL
      },
      'schemas' => @schemas
    }
  end

  def save_schemas(organized_data)
    puts "Saving organized schemas to #{OUTPUT_FILE}..."

    File.write(OUTPUT_FILE, JSON.pretty_generate(organized_data))

    file_size = File.size(OUTPUT_FILE)
    puts "✅ Organized schemas saved to #{OUTPUT_FILE}"
    puts "   Total schemas: #{organized_data['schemas'].length}"
    puts "   File size: #{(file_size / 1024.0).round(2)} KB"
  end

  def analyze_schemas(organized_data)
    puts "\n#{'=' * 80}"
    puts 'CDEK API SCHEMAS ANALYSIS'
    puts '=' * 80

    all_paths = Hash.new { |h, k| h[k] = [] }

    organized_data['schemas'].each_with_index do |schema_entry, idx|
      schema = schema_entry['schema']
      meta = schema_entry['metadata']

      puts "\n#{'=' * 80}"
      puts "SCHEMA #{idx + 1}: #{meta['title']}"
      puts '=' * 80
      puts "OpenAPI Version: #{meta['openapi_version']}"
      puts "API Version: #{meta['version']}"
      puts "Tags: #{meta['tags_count']}"
      puts "Paths: #{meta['paths_count']}"
      puts "Components: #{meta['has_components']}"

      next unless schema['paths']

      paths = schema['paths']
      puts "\nEndpoints (#{paths.length}):"
      paths.sort.each do |path, methods|
        method_list = methods.keys
        puts "  #{path.ljust(50)} [#{method_list.join(', ').upcase}]"
        all_paths[path].concat(method_list)
      end
    end

    puts "\n#{'=' * 80}"
    puts 'SUMMARY'
    puts '=' * 80
    puts "Total unique endpoints: #{all_paths.length}"
    puts "\nAll endpoints across all schemas:"
    all_paths.sort.each do |path, methods|
      unique_methods = methods.uniq.sort
      puts "  #{path.ljust(50)} [#{unique_methods.join(', ').upcase}]"
    end
  end

  def run
    puts '🚀 Starting CDEK API Schema Puller'
    puts '=' * 50

    # Fetch the API documentation
    raw_response = fetch_api_documentation
    return unless raw_response

    # Parse and process schemas
    success = parse_api_response(raw_response)
    return unless success

    # Organize the data
    organized_data = organize_schemas

    # Save the organized schemas
    save_schemas(organized_data)

    # Analyze and display summary
    analyze_schemas(organized_data)

    puts "\n✅ Schema pull and organization completed successfully!"
  end
end

# Run the script if called directly
if __FILE__ == $PROGRAM_NAME
  puller = CdekSchemaPuller.new
  puller.run
end
