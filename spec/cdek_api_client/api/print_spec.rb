# frozen_string_literal: true

require 'spec_helper'
require 'cdek_api_client'
require_relative '../../support/schema_loader'
require_relative '../../support/schema_driven_generator'
require_relative '../../support/schema_validator'
require_relative '../../support/contract_tester'
require_relative '../../support/entity_factory'

RSpec.describe CDEKApiClient::API::Print do
  include ClientHelper

  let(:print_api) { client.print }

  # Schema-driven test data
  let(:raw_barcode_data) do
    load_request_fixture('/v2/print/barcodes', 'post') || {}
  end

  let(:raw_invoice_data) do
    load_request_fixture('/v2/print/orders', 'post') || {}
  end

  let(:barcode_data) do
    EntityFactory.create_barcode(raw_barcode_data)
  end

  let(:invoice_data) do
    EntityFactory.create_invoice(raw_invoice_data)
  end

  describe '#create_barcode' do
    it 'responds to create_barcode method' do
      expect(print_api).to respond_to(:create_barcode)
    end

    it 'accepts barcode data parameter' do
      expect { print_api.create_barcode(barcode_data) }.not_to raise_error
    end

    it 'request data conforms to schema' do
      result = SchemaValidator.validate_request('/v2/print/barcodes', 'post', raw_barcode_data)
      expect(result[:valid]).to be true
    end
  end

  describe '#get_barcode' do
    it 'responds to get_barcode method' do
      expect(print_api).to respond_to(:get_barcode)
    end

    it 'accepts barcode uuid parameter' do
      expect { print_api.get_barcode('test-uuid') }.not_to raise_error
    end
  end

  describe '#get_barcode_pdf' do
    it 'responds to get_barcode_pdf method' do
      expect(print_api).to respond_to(:get_barcode_pdf)
    end

    it 'accepts barcode uuid parameter' do
      expect { print_api.get_barcode_pdf('test-uuid') }.not_to raise_error
    end
  end

  describe '#create_invoice' do
    it 'responds to create_invoice method' do
      expect(print_api).to respond_to(:create_invoice)
    end

    it 'accepts invoice data parameter' do
      expect { print_api.create_invoice(invoice_data) }.not_to raise_error
    end

    it 'request data conforms to schema' do
      result = SchemaValidator.validate_request('/v2/print/orders', 'post', raw_invoice_data)
      expect(result[:valid]).to be true
    end
  end

  describe '#get_invoice' do
    it 'responds to get_invoice method' do
      expect(print_api).to respond_to(:get_invoice)
    end

    it 'accepts invoice uuid parameter' do
      expect { print_api.get_invoice('test-uuid') }.not_to raise_error
    end
  end

  describe '#get_invoice_pdf' do
    it 'responds to get_invoice_pdf method' do
      expect(print_api).to respond_to(:get_invoice_pdf)
    end

    it 'accepts invoice uuid parameter' do
      expect { print_api.get_invoice_pdf('test-uuid') }.not_to raise_error
    end
  end
end
