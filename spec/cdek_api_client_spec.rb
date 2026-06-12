# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CDEKApiClient do
  describe '.configure' do
    it 'yields the client to the provided block' do
      expect { |b| described_class.configure(&b) }.to yield_control
    end
  end

  describe '.client' do
    let(:client_double) { instance_double(CDEKApiClient::Client) }

    before do
      described_class.instance_variable_set(:@client, nil)
      allow(CDEKApiClient::Client).to receive(:new).and_return(client_double)
    end

    it 'returns a CDEKApiClient::Client instance' do
      expect(described_class.client).to eq(client_double)
    end
  end
end
