# frozen_string_literal: true

require 'webmock/rspec'
require_relative 'lib/cdek_api_client'
require_relative 'lib/testing/auto_mocker'

CDEKApiClient.configure do |config|
  config.client_id = 'test_id'
  config.client_secret = 'test_secret'
end

CDEKApiClient::Testing::AutoMocker.stub_all_endpoints!
api = CDEKApiClient.client.order
begin
  api.get({})
  puts 'SUCCESS!'
rescue StandardError => e
  puts "ERROR: #{e.class} - #{e.message}"
end
