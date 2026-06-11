# frozen_string_literal: true

require_relative '../../lib/cdek_api_client/config'
require_relative 'schema_driven_generator'
require 'webmock'

# SchemaMockResponder provides schema-compliant mock responses to replace VCR
# Generates realistic API responses based on OpenAPI schemas
class SchemaMockResponder
  extend WebMock::API

  class << self
    # Set up all schema-compliant mock responses for testing
    # @param base_url [String] The base API URL to mock (defaults to demo API)
    def setup_schema_mocks(base_url: CDEKApiClient::Config.base_url)
      @base_url = base_url
      mock_authentication
      mock_calculator_endpoints
      mock_order_endpoints
      mock_location_endpoints
      mock_courier_endpoints
      mock_webhook_endpoints
      mock_payment_endpoints
      mock_print_endpoints
    end

    # Mock OAuth authentication
    def mock_authentication
      stub_request(:post, "#{@base_url}/oauth/token")
        .to_return(
          status: 200,
          body: {
            access_token: 'mock_access_token_12345',
            token_type: 'Bearer',
            expires_in: 3600,
            scope: 'read write',
            jti: 'mock_jti_12345'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    # Mock calculator endpoints
    def mock_calculator_endpoints
      # Tariff calculation
      stub_request(:post, %r{#{Regexp.escape(@base_url)}/calculator/tariff})
        .to_return(
          status: 200,
          body: {
            total_sum: 1500.50,
            currency: 'RUB',
            period_min: 1,
            period_max: 3,
            services: [
              {
                code: 'INSURANCE',
                name: 'Страхование',
                price: 15.00,
                currency: 'RUB'
              }
            ],
            errors: [],
            warnings: []
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Tariff list
      stub_request(:post, %r{#{Regexp.escape(@base_url)}/calculator/tarifflist})
        .to_return(
          status: 200,
          body: {
            tariffs: [
              {
                tariff_code: 139,
                tariff_name: 'Экспресс',
                tariff_description: 'Экспресс-доставка',
                delivery_mode: 1,
                period_min: 1,
                period_max: 3,
                delivery_sum: 1500.50,
                total_sum: 1500.50,
                currency: 'RUB'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # All tariffs
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/calculator/alltariffs})
        .to_return(
          status: 200,
          body: [
            {
              tariff_code: 139,
              tariff_name: 'Экспресс',
              tariff_description: 'Экспресс-доставка'
            },
            {
              tariff_code: 136,
              tariff_name: 'Посылка',
              tariff_description: 'Стандартная доставка'
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    # Mock order endpoints
    def mock_order_endpoints
      # Create order
      stub_request(:post, %r{#{Regexp.escape(@base_url)}/orders})
        .to_return(
          status: 202,
          body: {
            entity: {
              uuid: 'mock-order-uuid-12345',
              cdek_number: '1234567890',
              number: 'TEST123'
            },
            requests: [
              {
                request_uuid: 'req-uuid-123',
                type: 'CREATE',
                state: 'ACCEPTED',
                date_time: '2024-01-17T10:00:00+00:00'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Get order
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/orders/[^/]+$})
        .to_return(
          status: 200,
          body: {
            entity: {
              uuid: 'mock-order-uuid-12345',
              number: 'TEST123',
              status: 'CREATED',
              delivery_problem: []
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Delete order
      stub_request(:delete, %r{#{Regexp.escape(@base_url)}/orders/[^/]+$})
        .to_return(
          status: 200,
          body: {
            requests: [
              {
                request_uuid: 'delete-order-uuid-789',
                type: 'DELETE',
                state: 'SUCCESSFUL'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Update order
      stub_request(:patch, %r{#{Regexp.escape(@base_url)}/orders})
        .to_return(
          status: 200,
          body: {
            entity: {
              uuid: 'mock-order-uuid-12345',
              number: 'TEST123',
              status: 'UPDATED'
            },
            requests: [
              {
                request_uuid: 'update-order-uuid-789',
                type: 'UPDATE',
                state: 'SUCCESSFUL'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Get orders by cdek_number or im_number
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/orders(?:\?|$)})
        .to_return(
          status: 200,
          body: [
            {
              entity: {
                uuid: 'mock-order-uuid-12345',
                cdek_number: '123456789',
                number: 'TEST123',
                status: 'CREATED'
              }
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Order refusal
      stub_request(:post, %r{#{Regexp.escape(@base_url)}/orders/.*/refusal})
        .to_return(
          status: 200,
          body: {
            requests: [
              {
                request_uuid: 'refusal-uuid-123',
                type: 'DELETE',
                state: 'ACCEPTED'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    # Mock location endpoints
    def mock_location_endpoints
      # Cities
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/location/cities})
        .to_return(
          status: 200,
          body: [
            {
              code: 44,
              city: 'Москва',
              region: 'Москва',
              country_code: 'RU',
              fias_guid: '0c5b2444-70a0-4932-980c-b4dc0d3f02b5'
            },
            {
              code: 75,
              city: 'Санкт-Петербург',
              region: 'Санкт-Петербург',
              country_code: 'RU'
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Regions
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/location/regions})
        .to_return(
          status: 200,
          body: [
            {
              region: 'Москва',
              region_code: 77,
              country_code: 'RU'
            },
            {
              region: 'Санкт-Петербург',
              region_code: 78,
              country_code: 'RU'
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Delivery points
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/deliverypoints})
        .to_return(
          status: 200,
          body: [
            {
              code: 'MSK1',
              name: 'Пункт выдачи СДЭК',
              address: 'г. Москва, ул. Тестовая, д. 1',
              location: {
                city: 'Москва',
                address: 'ул. Тестовая, д. 1'
              }
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Postal codes
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/location/postalcodes(?:\?|$)})
        .to_return(
          status: 200,
          body: {
            postal_codes: [
              '101000',
              '101001',
              '101002'
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    # Mock courier endpoints
    def mock_courier_endpoints
      # Create agreement
      stub_request(:post, %r{#{Regexp.escape(@base_url)}/delivery})
        .to_return(
          status: 200,
          body: {
            entity: {
              uuid: 'agreement-uuid-123',
              cdek_number: '1234567890'
            },
            requests: [
              {
                request_uuid: 'req-uuid-456',
                type: 'CREATE',
                state: 'ACCEPTED'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Get agreement
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/delivery/[^/]+$})
        .to_return(
          status: 200,
          body: {
            entity: {
              uuid: 'agreement-uuid-123',
              status: 'CREATED'
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Create intake
      stub_request(:post, %r{#{Regexp.escape(@base_url)}/intakes})
        .to_return(
          status: 200,
          body: {
            entity: {
              uuid: 'intake-uuid-123',
              cdek_number: '1234567890'
            },
            requests: [
              {
                request_uuid: 'intake-req-uuid-456',
                type: 'CREATE',
                state: 'ACCEPTED'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Get intake
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/intakes/[^/]+$})
        .to_return(
          status: 200,
          body: {
            entity: {
              uuid: 'intake-uuid-123',
              cdek_number: '1234567890',
              intake_date: '2024-01-18',
              intake_time_from: '10:00',
              intake_time_to: '18:00'
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Delete intake
      stub_request(:delete, %r{#{Regexp.escape(@base_url)}/intakes/[^/]+$})
        .to_return(
          status: 200,
          body: {
            requests: [
              {
                request_uuid: 'delete-intake-uuid-789',
                type: 'DELETE',
                state: 'SUCCESSFUL'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Intake available days
      stub_request(:post, %r{#{Regexp.escape(@base_url)}/intakes/availableDays})
        .to_return(
          status: 200,
          body: {
            date: %w[2024-01-18 2024-01-19 2024-01-20],
            all_days: false,
            errors: [],
            warnings: []
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Delivery intervals
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/delivery/intervals})
        .to_return(
          status: 200,
          body: [
            {
              date: '2024-01-18',
              intervals: [
                {
                  begin: '10:00',
                  end: '18:00'
                }
              ]
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    # Mock webhook endpoints
    def mock_webhook_endpoints
      # Register webhook
      stub_request(:post, %r{#{Regexp.escape(@base_url)}/webhooks})
        .to_return(
          status: 200,
          body: {
            entity: {
              uuid: 'webhook-uuid-123',
              url: 'https://example.com/webhook',
              type: 'ORDER_STATUS'
            },
            requests: [
              {
                request_uuid: 'webhook-req-uuid-456',
                type: 'CREATE',
                state: 'ACCEPTED'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # List webhooks
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/webhooks$})
        .to_return(
          status: 200,
          body: [
            {
              uuid: 'webhook-uuid-123',
              url: 'https://example.com/webhook',
              type: 'ORDER_STATUS',
              event_types: %w[ORDER_STATUS DELIVERY_STATUS]
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Get webhook
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/webhooks/[^/]+$})
        .to_return(
          status: 200,
          body: {
            entity: {
              uuid: 'webhook-uuid-123',
              url: 'https://example.com/webhook',
              type: 'ORDER_STATUS'
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Delete webhook
      stub_request(:delete, %r{#{Regexp.escape(@base_url)}/webhooks/[^/]+$})
        .to_return(
          status: 200,
          body: {
            requests: [
              {
                request_uuid: 'delete-webhook-uuid-789',
                type: 'DELETE',
                state: 'SUCCESSFUL'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    # Mock payment endpoints
    def mock_payment_endpoints
      # Get payments
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/payment})
        .to_return(
          status: 200,
          body: [
            {
              date: '2024-01-17',
              cdek_number: '1234567890',
              sum: 1500.50,
              currency: 'RUB',
              type: 'CASH'
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Get checks
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/check})
        .to_return(
          status: 200,
          body: [
            {
              date: '2024-01-17',
              cdek_number: '1234567890',
              sum: 1500.50,
              currency: 'RUB'
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Get registries
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/registries})
        .to_return(
          status: 200,
          body: [
            {
              date: '2024-01-17',
              number: 'REG001',
              orders: ['1234567890']
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    # Mock print endpoints
    def mock_print_endpoints
      # Create barcode
      stub_request(:post, %r{#{Regexp.escape(@base_url)}/print/barcodes})
        .to_return(
          status: 200,
          body: {
            entity: {
              uuid: 'barcode-uuid-123'
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Get barcode
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/print/barcodes/[^/]+$})
        .to_return(
          status: 200,
          body: 'PDF_CONTENT_PLACEHOLDER',
          headers: { 'Content-Type' => 'application/pdf' }
        )

      # Create invoice
      stub_request(:post, %r{#{Regexp.escape(@base_url)}/print/orders})
        .to_return(
          status: 200,
          body: {
            entity: {
              uuid: 'invoice-uuid-123'
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Get invoice
      stub_request(:get, %r{#{Regexp.escape(@base_url)}/print/orders/[^/]+$})
        .to_return(
          status: 200,
          body: 'PDF_CONTENT_PLACEHOLDER',
          headers: { 'Content-Type' => 'application/pdf' }
        )
    end
  end
end
