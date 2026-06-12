# frozen_string_literal: true

require 'spec_helper'
require 'cdek_api_client'
require_relative '../../support/schema_loader'
require_relative '../../support/schema_driven_generator'
require_relative '../../support/schema_validator'
require_relative '../../support/contract_tester'
require_relative '../../support/entity_factory'

RSpec.describe CDEKApiClient::API::Courier do
  include ClientHelper

  let(:courier_api) { client.courier }

  # Schema-driven test data
  let(:raw_delivery_data) do
    load_request_fixture('/v2/delivery', 'post') || {}
  end

  let(:raw_intake_data) do
    load_request_fixture('/v2/intakes', 'post') || {}
  end

  let(:raw_intake_available_days_data) do
    load_request_fixture('/v2/intakes/availableDays', 'post') || {}
  end

  let(:delivery_data) do
    EntityFactory.create_agreement(raw_delivery_data)
  end

  let(:intake_data) do
    EntityFactory.create_intakes(raw_intake_data)
  end

  let(:intake_available_days_data) do
    EntityFactory.create_intake_available_days_request(raw_intake_available_days_data)
  end

  describe '#create_agreement' do
    it 'responds to create_agreement method' do
      expect(courier_api).to respond_to(:create_agreement)
    end

    it 'accepts agreement data parameter' do
      expect { courier_api.create_agreement(delivery_data) }.not_to raise_error
    end

    it 'request data conforms to schema' do
      result = SchemaValidator.validate_request('/v2/delivery', 'post', raw_delivery_data)
      expect(result[:valid]).to be true
    end
  end

  describe '#get_agreement' do
    it 'responds to get_agreement method' do
      expect(courier_api).to respond_to(:get_agreement)
    end

    it 'accepts agreement uuid parameter' do
      expect { courier_api.get_agreement('12345678-1234-5678-9012-123456789abc') }.not_to raise_error
    end
  end

  describe '#create_intake' do
    it 'responds to create_intake method' do
      expect(courier_api).to respond_to(:create_intake)
    end

    it 'accepts intake data parameter' do
      expect { courier_api.create_intake(intake_data) }.not_to raise_error
    end

    it 'request data conforms to schema' do
      result = SchemaValidator.validate_request('/v2/intakes', 'post', raw_intake_data)
      expect(result[:valid]).to be true
    end
  end

  describe '#get_intake' do
    it 'responds to get_intake method' do
      expect(courier_api).to respond_to(:get_intake)
    end

    it 'accepts intake uuid parameter' do
      expect { courier_api.get_intake('12345678-1234-5678-9012-123456789abc') }.not_to raise_error
    end
  end

  describe '#delete_intake' do
    it 'responds to delete_intake method' do
      expect(courier_api).to respond_to(:delete_intake)
    end

    it 'accepts intake uuid parameter' do
      expect { courier_api.delete_intake('12345678-1234-5678-9012-123456789abc') }.not_to raise_error
    end
  end

  describe '#create_intake_available_days' do
    it 'responds to create_intake_available_days method' do
      expect(courier_api).to respond_to(:create_intake_available_days)
    end

    it 'accepts intake available days request parameter' do
      expect { courier_api.create_intake_available_days(intake_available_days_data) }.not_to raise_error
    end

    it 'request data conforms to schema' do
      result = SchemaValidator.validate_request('/v2/intakes/availableDays', 'post', raw_intake_available_days_data)
      expect(result[:valid]).to be true
    end
  end

  describe '#get_delivery_intervals' do
    it 'responds to get_delivery_intervals method' do
      expect(courier_api).to respond_to(:get_delivery_intervals)
    end

    it 'accepts cdek_number parameter' do
      expect { courier_api.get_delivery_intervals(cdek_number: '123456789') }.not_to raise_error
    end

    it 'accepts order_uuid parameter' do
      expect { courier_api.get_delivery_intervals(order_uuid: 'test-uuid') }.not_to raise_error
    end
  end
end
