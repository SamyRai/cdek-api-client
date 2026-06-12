# frozen_string_literal: true

require_relative 'extensions/dry_struct'

module CDEKApiClient
  # Provides backward compatibility with legacy API methods and structures
  module Compat
    def self.apply!
      # Map Legacy Classes
      CDEKApiClient::API.const_set(:Courier, CDEKApiClient::API::Intake)
      CDEKApiClient::API.const_set(:Payment, CDEKApiClient::API::Receipt)
      CDEKApiClient::API.const_set(:Tariff, CDEKApiClient::API::Calculator)
      CDEKApiClient::API.const_set(:TrackOrder, CDEKApiClient::API::Order)

      # Map Legacy Courier API
      CDEKApiClient::API::Intake.class_eval do
        alias_method :create_intake, :create if method_defined?(:create)
        alias_method :create_intake_available_days, :get_available_days if method_defined?(:get_available_days)

        def get_intake(uuid)
          @client.validate_uuid(uuid)
          get_by_uuid(uuid)
        end

        def delete_intake(uuid)
          @client.validate_uuid(uuid)
          delete_by_uuid(uuid)
        end

        def create_agreement(body_data = {}, query_params = {})
          @client.schedule.post_delivery(body_data, query_params)
        end

        def get_agreement(uuid, query_params = {})
          @client.schedule.get_delivery(uuid, query_params)
        end

        def get_delivery_intervals(query_params = {})
          @client.schedule.get_intervals(query_params)
        end
      end

      # Map Legacy Location API
      CDEKApiClient::API::Location.class_eval do
        def postal_codes(city_code, **kwargs)
          raise ArgumentError, 'city_code is required' if city_code.nil? || city_code.to_s.empty?

          res = postalcodes({ city_code: city_code }.merge(kwargs))
          res.is_a?(CDEKApiClient::Entities::PostcodesResponse) ? (res.postal_codes || []) : res
        end

        def offices(**kwargs)
          @client.deliverypoint.search(**kwargs)
        end

        private

        def read_data_from_file(filename)
          path = File.join('data', filename)
          return { 'error' => "No such file or directory @ rb_sysopen - #{path}" } unless File.exist?(path)

          JSON.parse(File.read(path))
        end

        def save_response_to_file(response, filename)
          FileUtils.mkdir_p('data')
          File.write(File.join('data', filename), response.to_json)
        end
      end

      # Map Legacy Order API
      CDEKApiClient::API::Order.class_eval do
        alias_method :create, :post_orders if method_defined?(:post_orders)

        # The legacy track method used the UUID
        def track(uuid)
          @client.validate_uuid(uuid)
          get_orders(uuid)
        end

        alias_method :_original_get, :get if method_defined?(:get)

        def get(uuid_or_query_params = nil, _maybe_query_params = {})
          if uuid_or_query_params.is_a?(String)
            @client.validate_uuid(uuid_or_query_params)
            get_orders(uuid_or_query_params)
          else
            _original_get(uuid_or_query_params || {})
          end
        end

        # Cancel mapped to delete
        alias_method :cancel, :delete if method_defined?(:delete)

        # Legacy custom queries
        def get_by_cdek_number(cdek_number)
          response = @client.request('get', 'orders', query: { cdek_number: cdek_number })
          result = @client.send(:handle_response, response)
          return result unless result.is_a?(Hash) && !result.empty?

          CDEKApiClient::Entities::OrderResponse.new(result)
        end

        def get_by_im_number(im_number)
          response = @client.request('get', 'orders', query: { im_number: im_number })
          result = @client.send(:handle_response, response)
          return result unless result.is_a?(Hash) && !result.empty?

          CDEKApiClient::Entities::OrderResponse.new(result)
        end
      end

      # Map Legacy Payment API
      CDEKApiClient::API::Receipt.class_eval do
        alias_method :get_checks, :get_check if method_defined?(:get_check)

        def get_payments(date)
          response = @client.request('get', 'payment', query: { date: date })
          @client.send(:handle_response, response)
        end

        def get_registries(date)
          response = @client.request('get', 'registries', query: { date: date })
          @client.send(:handle_response, response)
        end
      end

      # Map Legacy Webhook API
      CDEKApiClient::API::Webhook.class_eval do
        alias_method :register, :create_webhook if method_defined?(:create_webhook)
        alias_method :list, :get_all if method_defined?(:get_all)
        alias_method :list_all, :get_all if method_defined?(:get_all)
        def get(uuid)
          @client.validate_uuid(uuid)
          get_by_id(uuid)
        end

        def delete(uuid)
          @client.validate_uuid(uuid)
          delete_by_id(uuid)
        end
      end

      # Map Legacy Tariff API
      CDEKApiClient::API::Calculator.class_eval do
        alias_method :calculate, :tariff if method_defined?(:tariff)
        alias_method :calculate_list, :tariff_list if method_defined?(:tariff_list)
      end

      # Map Legacy Print API
      CDEKApiClient::API::Print.class_eval do
        alias_method :create_barcode, :barcode_print if method_defined?(:barcode_print)
        alias_method :get_barcode, :barcode_get if method_defined?(:barcode_get)
        alias_method :get_barcode_pdf, :barcode_download if method_defined?(:barcode_download)

        alias_method :create_invoice, :waybill_print if method_defined?(:waybill_print)
        alias_method :get_invoice, :waybill_get if method_defined?(:waybill_get)
        alias_method :get_invoice_pdf, :waybill_download if method_defined?(:waybill_download)
      end
    end
  end
end
