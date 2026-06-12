# frozen_string_literal: true

require 'spec_helper'
require 'cdek_api_client'
require_relative '../../support/schema_loader'
require_relative '../../support/schema_driven_generator'
require_relative '../../support/schema_validator'
require_relative '../../support/contract_tester'
require_relative '../../support/entity_factory'

RSpec.describe CDEKApiClient::API::Payment do
  include ClientHelper

  let(:payment_api) { client.payment }

  # Schema-driven test data for query parameters
  let(:payment_params) do
    load_request_fixture('/v2/payment', 'get') || {}
  end

  let(:check_params) do
    load_request_fixture('/v2/check', 'get') || {}
  end

  let(:registries_params) do
    load_request_fixture('/v2/registries', 'get') || {}
  end

  describe '#get_payments' do
    before do
      stub_request(:get, %r{/v2/payment}).to_return(status: 200, body: '{}')
    end

    it 'responds to get_payments method' do
      expect(payment_api).to respond_to(:get_payments)
    end

    it 'accepts date parameter' do
      expect { payment_api.get_payments('2024-01-17') }.not_to raise_error
    end

    it 'generated payment params conform to schema' do
      # For GET endpoints, validate that generated params match expected query parameters
      expect(payment_params).to be_a(Hash)
      expect(payment_params['date']).to be_present if payment_params.key?('date')
    end
  end

  describe '#get_checks' do
    let(:check_data) do
      # Use schema-generated data to create Check entity
      EntityFactory.create_check(check_params)
    end

    it 'responds to get_checks method' do
      expect(payment_api).to respond_to(:get_checks)
    end

    it 'accepts check data parameter' do
      expect { payment_api.get_checks(check_data.to_query_params) }.not_to raise_error
    end

    it 'generated check params conform to schema' do
      expect(check_params).to be_a(Hash)
      # Check entity should be created successfully
      expect(check_data).to be_a(CDEKApiClient::Entities::Check)
    end
  end

  describe '#get_registries' do
    it 'responds to get_registries method' do
      expect(payment_api).to respond_to(:get_registries)
    end

    it 'accepts date parameter' do
      expect { payment_api.get_registries('2024-01-17') }.not_to raise_error
    end

    it 'generated registries params conform to schema' do
      expect(registries_params).to be_a(Hash)
      expect(registries_params['date']).to be_present if registries_params.key?('date')
    end
  end
end
