# frozen_string_literal: true

require 'json'

file = File.read('./cdek_api_schemas.json')
data = JSON.parse(file)

data['schemas'].each do |schema_entry|
  schema = schema_entry['schema']
  next unless schema['paths']

  schema['paths'].each do |path, methods|
    methods.each do |method, details|
      responses = details['responses']
      next unless responses

      success = responses['200'] || responses['202']
      if success && success['content'] && success['content']['application/json'] && success['content']['application/json']['schema']
        s = success['content']['application/json']['schema']
        if s['$ref']
          puts "#{method.upcase} #{path} -> ref: #{s['$ref']}"
        elsif s['type'] == 'array' && s['items'] && s['items']['$ref']
          puts "#{method.upcase} #{path} -> array of ref: #{s['items']['$ref']}"
        else
          puts "#{method.upcase} #{path} -> schema: #{s.keys}"
        end
      else
        puts "#{method.upcase} #{path} -> NO SCHEMA or SUCCESS"
      end
    end
  end
end
