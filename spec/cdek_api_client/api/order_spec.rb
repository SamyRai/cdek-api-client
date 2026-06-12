# frozen_string_literal: true

require 'spec_helper'
require 'cdek_api_client'
require_relative '../../support/schema_loader'
require_relative '../../support/schema_driven_generator'
require_relative '../../support/schema_validator'
require_relative '../../support/contract_tester'
require_relative '../../support/entity_factory'

RSpec.describe CDEKApiClient::API::Order do
  include ClientHelper

  let(:order) { client.order }

  # Schema-driven test data for order creation
  let(:raw_order_data) do
    load_request_fixture('/v2/orders', 'post') || {}
  end

  let(:order_data) do
    EntityFactory.create_order_data(raw_order_data)
  end

  describe '#create' do
    subject(:response) { order.create(order_data) }

    it 'request data conforms to schema' do
      result = SchemaValidator.validate_request('/v2/orders', 'post', raw_order_data)
      expect(result[:valid]).to be true
    end

    it 'creates an order successfully' do
      expect(response).not_to include('error')
    end

    it 'has an accepted state' do
      expect(response['requests'].first['state']).to eq('ACCEPTED')
    end

    it 'create response conforms to schema' do
      result = SchemaValidator.validate_response('/v2/orders', 'post', 202, response)
      expect(result[:valid]).to be true
    end
  end

  describe '#track' do
    subject(:response) { order.track(order_uuid) }

    let(:order_uuid) do
      response = order.create(order_data)
      response['entity']['uuid']
    end

    it 'tracks an order successfully' do
      expect(response).not_to include('error')
    end

    it 'includes the correct order uuid' do
      expect(response['entity']).to include('uuid' => order_uuid)
    end

    it 'track response conforms to schema' do
      result = SchemaValidator.validate_response('/v2/orders/{uuid}', 'get', 200, response)
      expect(result[:valid]).to be true
    end
  end

  describe '#delete' do
    it 'responds to delete method' do
      expect(order).to respond_to(:delete)
    end

    it 'accepts order uuid parameter' do
      expect { order.delete('12345678-1234-5678-9012-123456789abc') }.not_to raise_error
    end
  end

  describe '#cancel' do
    it 'responds to cancel method' do
      expect(order).to respond_to(:cancel)
    end

    it 'accepts order uuid parameter' do
      expect { order.cancel('12345678-1234-5678-9012-123456789abc') }.not_to raise_error
    end
  end

  describe '#update' do
    it 'responds to update method' do
      expect(order).to respond_to(:update)
    end

    it 'accepts order data parameter' do
      expect { order.update(order_data) }.not_to raise_error
    end
  end

  describe '#get_by_cdek_number' do
    it 'responds to get_by_cdek_number method' do
      expect(order).to respond_to(:get_by_cdek_number)
    end

    it 'accepts cdek number parameter' do
      expect { order.get_by_cdek_number('123456789') }.not_to raise_error
    end
  end

  describe '#get_by_im_number' do
    it 'responds to get_by_im_number method' do
      expect(order).to respond_to(:get_by_im_number)
    end

    it 'accepts im number parameter' do
      expect { order.get_by_im_number('test-order-123') }.not_to raise_error
    end
  end

  describe 'API Contract Tests' do
    context 'with order creation' do
      it 'maintains create order request/response contract' do
        test_api_contract('/v2/orders', 'post') do |request|
          order_data = EntityFactory.create_order_data(request)
          order.create(order_data)
        end
      end
    end

    context 'with order tracking' do
      it 'maintains track order request/response contract' do
        # For tracking, we need a valid order UUID
        create_response = order.create(order_data)
        order_uuid = create_response['entity']['uuid']

        # Validate the track response against schema
        track_response = order.track(order_uuid)
        result = SchemaValidator.validate_response('/v2/orders/{uuid}', 'get', 200, track_response)
        expect(result[:valid]).to be true
      end
    end
  end
end
