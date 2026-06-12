# frozen_string_literal: true

require 'spec_helper'
require 'cdek_api_client'
require_relative '../../support/schema_loader'
require_relative '../../support/schema_driven_generator'
require_relative '../../support/schema_validator'
require_relative '../../support/entity_factory'

RSpec.describe CDEKApiClient::API::Tariff do
  include ClientHelper

  let(:tariff) { client.tariff }

  let(:raw_tariff_data) do
    # Generate tariff data from schema instead of hardcoded values
    load_request_fixture('/v2/calculator/tariff', 'post')
  end

  let(:tariff_data) do
    EntityFactory.create_tariff_data(raw_tariff_data)
  end

  describe '#calculate' do
    subject(:response) { tariff.calculate(tariff_data) }

    it 'request data conforms to schema' do
      result = SchemaValidator.validate_request('/v2/calculator/tariff', 'post', raw_tariff_data)
      expect(result[:valid]).to be true
    end

    it 'does not include error' do
      expect(response).not_to include('error')
    end

    it 'calculates the total_sum' do
      raise "Unexpected response format: #{response.inspect}" unless response['total_sum']

      expect(response).to include('total_sum')
    end

    it 'response conforms to schema' do
      result = SchemaValidator.validate_response('/v2/calculator/tariff', 'post', 200, response)
      expect(result[:valid]).to be true
    end
  end

  describe '#calculate_list' do
    let(:raw_tariff_data_list) do
      # Generate tariff data from schema instead of hardcoded values
      load_request_fixture('/v2/calculator/tariff', 'post')
    end

    let(:tariff_data_list) do
      EntityFactory.create_tariff_data(raw_tariff_data_list)
    end

    it 'responds to calculate_list method' do
      expect(tariff).to respond_to(:calculate_list)
    end

    it 'accepts tariff data parameter' do
      expect { tariff.calculate_list(tariff_data_list) }.not_to raise_error
    end
  end
end
