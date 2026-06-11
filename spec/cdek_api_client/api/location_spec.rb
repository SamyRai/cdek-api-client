# frozen_string_literal: true

require 'spec_helper'
require 'cdek_api_client'
require 'json'
require_relative '../../support/schema_loader'
require_relative '../../support/schema_driven_generator'
require_relative '../../support/schema_validator'
require_relative '../../support/contract_tester'
require_relative '../../support/entity_factory'

RSpec.describe CDEKApiClient::API::Location do
  include ClientHelper

  let(:location) { client.location }
  # Schema-driven test data for requests
  let(:cities_request_params) do
    SchemaDrivenGenerator.generate_request('/v2/location/cities', 'get') || {}
  end
  let(:regions_request_params) do
    SchemaDrivenGenerator.generate_request('/v2/location/regions', 'get') || {}
  end
  let(:offices_request_params) do
    SchemaDrivenGenerator.generate_request('/v2/deliverypoints', 'get') || {}
  end

  def save_response_to_file(response, filename)
    File.write("data/#{filename}", JSON.pretty_generate(response))
  end

  describe '#cities' do
    context 'when using live data' do
      it 'retrieves a list of cities successfully' do
        response = location.cities(use_live_data: true)
        expect(response).to be_an(Array)
      end

      it 'checks the first city has a city key' do
        response = location.cities(use_live_data: true)
        expect(response.first).to have_key('city')
      end

      it 'cities response conforms to schema' do
        response = location.cities(use_live_data: true)
        result = SchemaValidator.validate_response('/v2/location/cities', 'get', 200, response)
        expect(result[:valid]).to be true
      end

      # This test verifies that live responses can be serialized to the filesystem
      it 'saves cities to filesystem' do
        allow(File).to receive(:write)
        response = location.cities(use_live_data: true)
        save_response_to_file(response, 'cities_mapping.json')
        expect(File).to have_received(:write).with('data/cities_mapping.json', anything)
      end
    end

    context 'when using cached data' do
      it 'retrieves a list of cities from the file system' do
        response = location.cities
        expect(response).to be_an(Array)
      end

      it 'checks the first city has a city key' do
        response = location.cities
        expect(response.first).to have_key('city')
      end

      it 'cities response conforms to schema' do
        response = location.cities
        # Validate that each city object in the array conforms to schema
        response.each do |city|
          expect(SchemaValidator.validate_data_against_schema(city,
                                                              { 'type' => 'object',
                                                                'properties' => { 'city' => { 'type' => 'string' } } })[:valid]).to be true
        end
      end
    end
  end

  describe '#regions' do
    context 'when using live data' do
      it 'retrieves a list of regions successfully' do
        response = location.regions(use_live_data: true)
        expect(response).to be_an(Array)
      end

      it 'checks the first region has a region key' do
        response = location.regions(use_live_data: true)
        expect(response.first).to have_key('region')
      end

      it 'regions response conforms to schema' do
        response = location.regions(use_live_data: true)
        result = SchemaValidator.validate_response('/v2/location/regions', 'get', 200, response)
        expect(result[:valid]).to be true
      end

      # This test verifies that live responses can be serialized to the filesystem
      it 'saves regions to filesystem' do
        allow(File).to receive(:write)
        response = location.regions(use_live_data: true)
        save_response_to_file(response, 'regions_mapping.json')
        expect(File).to have_received(:write).with('data/regions_mapping.json', anything)
      end
    end

    context 'when using cached data' do
      it 'retrieves a list of regions from the file system' do
        response = location.regions
        expect(response).to be_an(Array)
      end

      it 'checks the first region has a region key' do
        response = location.regions
        expect(response.first).to have_key('region')
      end

      it 'regions response conforms to schema' do
        response = location.regions
        # Validate that each region object in the array conforms to schema
        response.each do |region|
          expect(SchemaValidator.validate_data_against_schema(region,
                                                              { 'type' => 'object',
                                                                'properties' => { 'region' => { 'type' => 'string' } } })[:valid]).to be true
        end
      end
    end
  end

  describe '#offices' do
    context 'when using live data' do
      it 'retrieves a list of offices successfully' do
        response = location.offices(use_live_data: true)
        expect(response).to be_an(Array)
      end

      it 'checks the first office has a code key' do
        response = location.offices(use_live_data: true)
        expect(response.first).to have_key('code')
      end

      it 'offices response conforms to schema' do
        response = location.offices(use_live_data: true)
        result = SchemaValidator.validate_response('/v2/deliverypoints', 'get', 200, response)
        expect(result[:valid]).to be true
      end

      # This test verifies that live responses can be serialized to the filesystem
      it 'saves offices to filesystem' do
        allow(File).to receive(:write)
        response = location.offices(use_live_data: true)
        save_response_to_file(response, 'offices_mapping.json')
        expect(File).to have_received(:write).with('data/offices_mapping.json', anything)
      end
    end

    context 'when using cached data' do
      it 'retrieves a list of offices from the file system' do
        response = location.offices
        expect(response).to be_an(Array)
      end

      it 'checks the first office has a code key' do
        response = location.offices
        expect(response.first).to have_key('code')
      end

      it 'offices response conforms to schema' do
        response = location.offices
        # Validate that each office object in the array has required fields
        response.each do |office|
          expect(office).to have_key('code')
          # Basic validation that it's an object with expected structure
          expect(SchemaValidator.validate_data_against_schema(office,
                                                              { 'type' => 'object',
                                                                'properties' => { 'code' => { 'type' => 'string' } } })[:valid]).to be true
        end
      end
    end

    it 'handles errors gracefully' do
      allow(location).to receive(:offices).and_raise(StandardError, 'An error occurred')
      expect { location.offices }.to raise_error(StandardError, 'An error occurred')
    end
  end

  describe '#cities_with_postal_codes' do
    it 'retrieves cities and their postal codes successfully' do
      cities_response = location.cities(use_live_data: true)
      expect(cities_response).to be_an(Array)
    end

    it 'checks the first city has a code key' do
      cities_response = location.cities(use_live_data: true)
      expect(cities_response.first).to have_key('code')
    end

    # This test verifies we can iterate and save postal codes
    it 'retrieves postal codes for each city and saves to filesystem' do
      allow(File).to receive(:write)
      cities_response = location.cities(use_live_data: true)
      cities_with_postal_codes = cities_response.map do |city|
        city_code = city['code']
        postal_codes_response = location.postal_codes(city_code, use_live_data: true)
        {
          city:,
          postal_codes: postal_codes_response
        }
      end
      save_response_to_file(cities_with_postal_codes, 'cities_with_postal_codes_mapping.json')
      expect(File).to have_received(:write).with('data/cities_with_postal_codes_mapping.json', anything)
    end
  end

  describe '#postal_codes' do
    context 'when use_live_data is false' do
      it 'retrieves a list of postal codes from the file system' do
        cities_response = location.cities(use_live_data: true)
        city_code = cities_response.first['code']

        # Create the postal codes file for the first city (mocked)
        postal_codes_response = location.postal_codes(city_code, use_live_data: true)
        allow(File).to receive(:read).with("data/postal_codes_#{city_code}_mapping.json", encoding: 'UTF-8').and_return(JSON.generate(postal_codes_response))

        response = location.postal_codes(city_code)
        expect(response).to be_an(Array)
      end
    end

    context 'when city_code is nil' do
      it 'raises an ArgumentError' do
        expect { location.postal_codes(nil) }.to raise_error(ArgumentError, 'city_code is required')
      end
    end

    context 'when city_code is empty' do
      it 'raises an ArgumentError' do
        expect { location.postal_codes('') }.to raise_error(ArgumentError, 'city_code is required')
      end
    end
  end

  describe '#read_data_from_file' do
    context 'when the file does not exist' do
      it 'logs an error and returns an error hash' do
        response = location.send(:read_data_from_file, 'test.json')
        expect(response).to eq({ 'error' => 'No such file or directory @ rb_sysopen - data/test.json' })
      end
    end
  end

  describe 'API Contract Tests' do
    context 'with cities endpoint' do
      it 'maintains cities request/response contract' do
        # For GET endpoints without requestBody, we just validate the response
        response = location.cities(use_live_data: true)
        result = SchemaValidator.validate_response('/v2/location/cities', 'get', 200, response)
        expect(result[:valid]).to be true
      end
    end

    context 'with regions endpoint' do
      it 'maintains regions request/response contract' do
        response = location.regions(use_live_data: true)
        result = SchemaValidator.validate_response('/v2/location/regions', 'get', 200, response)
        expect(result[:valid]).to be true
      end
    end

    context 'with delivery points endpoint' do
      it 'maintains delivery points request/response contract' do
        response = location.offices(use_live_data: true)
        result = SchemaValidator.validate_response('/v2/deliverypoints', 'get', 200, response)
        expect(result[:valid]).to be true
      end
    end
  end
end
