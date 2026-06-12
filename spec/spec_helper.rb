# frozen_string_literal: true

require 'webmock/rspec'
require 'faker'
require 'pry'
require_relative '../lib/cdek_api_client'
require_relative '../lib/cdek_api_client/testing/fixture_loader'
require 'testing/auto_mocker'

Faker::Config.locale = 'ru'

RSpec.configure do |config|
  config.before(:suite) do
    # Set up all schema-compliant mock responses
    CDEKApiClient::Testing::AutoMocker.stub_all_endpoints!
  end

  config.before do
    # Ensure clean mock state for each test
    WebMock.reset!
    CDEKApiClient::Testing::AutoMocker.stub_all_endpoints!
  end
end

module ClientHelper
  def client
    CDEKApiClient::Client.new(client_id, client_secret)
  end

  def client_id
    'wqGwiQx0gg8mLtiEKsUinjVSICCjtTEP'
  end

  def client_secret
    'RmAmgvSgSl1yirlz9QupbzOJVqhCxcP5'
  end
end
