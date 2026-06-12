# frozen_string_literal: true

require 'json'

module FixtureLoader
  def load_fixture(type, endpoint, status_code = nil)
    base_dir = File.expand_path('fixtures', __dir__)

    file_name = endpoint.gsub('/', '_').gsub(/_{2,}/, '_').gsub(/[{}]/, '').sub(/^_/, '')

    file_path = if type == :request
                  File.join(base_dir, 'requests', "#{file_name}.json")
                else
                  File.join(base_dir, 'responses', "#{file_name}_#{status_code}.json")
                end

    return nil unless File.exist?(file_path)

    JSON.parse(File.read(file_path))
  end

  def load_request_fixture(path, method = 'post')
    file_name = path.gsub('/', '_').gsub(/_{2,}/, '_').gsub(/[{}]/, '').sub(/^_/, '') + "_#{method}"
    file_path = File.join(File.expand_path('fixtures', __dir__), 'requests', "#{file_name}.json")
    return nil unless File.exist?(file_path)

    JSON.parse(File.read(file_path))
  end

  def load_response_fixture(path, method = 'post', status = 200)
    file_name = path.gsub('/', '_').gsub(/_{2,}/, '_').gsub(/[{}]/, '').sub(/^_/, '') + "_#{method}_#{status}"
    file_path = File.join(File.expand_path('fixtures', __dir__), 'responses', "#{file_name}.json")
    return nil unless File.exist?(file_path)

    JSON.parse(File.read(file_path))
  end
end

RSpec.configure do |config|
  config.include FixtureLoader
end
