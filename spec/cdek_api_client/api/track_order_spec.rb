# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

RSpec.describe CDEKApiClient::API::TrackOrder do
  include ClientHelper

  let(:track_order_api) { described_class.new(client) }
  let(:order_uuid) { SecureRandom.uuid }

  describe '#get' do
    context 'with a valid uuid' do
      before do
        stub_request(:get, "https://api.edu.cdek.ru/v2/orders/#{order_uuid}")
          .to_return(status: 200, body: { 'entity' => { 'uuid' => order_uuid } }.to_json, headers: {})
      end

      it 'returns the tracking information' do
        response = track_order_api.get(order_uuid)
        expect(response['entity']['uuid']).to eq(order_uuid)
      end
    end

    context 'with an invalid uuid' do
      it 'raises an ArgumentError' do
        expect { track_order_api.get('invalid_uuid') }.to raise_error(ArgumentError, 'Invalid UUID format')
      end
    end

    context 'when the API returns an error' do
      before do
        stub_request(:get, %r{https://api\.edu\.cdek\.ru/v2/orders/.*})
          .to_return(status: 500, body: { error: 'Internal Server Error' }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises a ServerError' do
        expect { track_order_api.get('12345678-1234-5678-9012-123456789abc') }.to raise_error(CDEKApiClient::ServerError, /Server error 500:/)
      end
    end
  end
end
