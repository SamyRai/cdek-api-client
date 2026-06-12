# frozen_string_literal: true

require 'spec_helper'
require 'cdek_api_client'
require_relative '../../support/schema_loader'
require_relative '../../support/schema_driven_generator'
require_relative '../../support/schema_validator'
require_relative '../../support/contract_tester'
require_relative '../../support/entity_factory'

RSpec.describe CDEKApiClient::API::Webhook do
  include ClientHelper

  let(:webhook) { client.webhook }

  # Schema-driven test data
  let(:raw_webhook_data) do
    load_request_fixture('/v2/webhooks', 'post') || {}
  end

  let(:webhook_data) do
    EntityFactory.create_webhook(raw_webhook_data)
  end

  describe '#register' do
    it 'request data conforms to schema' do
      result = SchemaValidator.validate_request('/v2/webhooks', 'post', raw_webhook_data)
      expect(result[:valid]).to be true
    end

    it 'registers a webhook successfully' do
      response = webhook.register(webhook_data)
      expect(response).not_to include('error')
    end

    it 'response includes uuid' do
      response = webhook.register(webhook_data)
      expect(response['entity']).to include('uuid')
    end

    it 'register response conforms to schema' do
      response = webhook.register(webhook_data)
      result = SchemaValidator.validate_response('/v2/webhooks', 'post', 200, response)
      expect(result[:valid]).to be true
    end
  end

  describe '#list' do
    it 'retrieves webhooks successfully' do
      response = webhook.list
      expect(response).not_to include('error')
    end

    it 'response is an array' do
      response = webhook.list
      expect(response).to be_an(Array)
    end

    it 'list response conforms to schema' do
      response = webhook.list
      result = SchemaValidator.validate_response('/v2/webhooks', 'get', 200, response)
      expect(result[:valid]).to be true
    end
  end

  describe '#list_all' do
    it 'responds to list_all method' do
      expect(webhook).to respond_to(:list_all)
    end

    it 'returns response without error' do
      response = webhook.list_all
      expect(response).not_to include('error')
    end
  end

  describe '#get' do
    let(:webhook_uuid) do
      response = webhook.register(webhook_data)
      response['entity']['uuid']
    end

    it 'responds to get method' do
      expect(webhook).to respond_to(:get)
    end

    it 'accepts webhook uuid parameter' do
      expect { webhook.get(webhook_uuid) }.not_to raise_error
    end
  end

  describe '#delete' do
    let(:webhook_id) do
      response = webhook.register(webhook_data)
      response['entity']['uuid']
    end

    it 'deletes a webhook successfully' do
      delete_response = webhook.delete(webhook_id)
      expect(delete_response).not_to include('error')
    end

    it 'deletion is successful' do
      delete_response = webhook.delete(webhook_id)
      expect(%w[ACCEPTED SUCCESSFUL]).to include(delete_response['requests'].first['state'])
    end

    it 'delete response conforms to schema' do
      delete_response = webhook.delete(webhook_id)
      result = SchemaValidator.validate_response('/v2/webhooks/{uuid}', 'delete', 200, delete_response)
      expect(result[:valid]).to be true
    end
  end

  describe 'API Contract Tests' do
    context 'with webhook registration' do
      it 'maintains register webhook request/response contract' do
        test_api_contract('/v2/webhooks', 'post') do |request|
          webhook_data = EntityFactory.create_webhook(request)
          webhook.register(webhook_data)
        end
      end
    end

    context 'with webhook listing' do
      it 'maintains list webhooks request/response contract' do
        response = webhook.list
        result = SchemaValidator.validate_response('/v2/webhooks', 'get', 200, response)
        expect(result[:valid]).to be true
      end
    end

    context 'with webhook deletion' do
      it 'maintains delete webhook request/response contract' do
        create_response = webhook.register(webhook_data)
        webhook_uuid = create_response['entity']['uuid']

        delete_response = webhook.delete(webhook_uuid)
        result = SchemaValidator.validate_response('/v2/webhooks/{uuid}', 'delete', 200, delete_response)
        expect(result[:valid]).to be true
      end
    end
  end
end
