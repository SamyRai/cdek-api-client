# frozen_string_literal: true

require 'dry-struct'
require_relative 'types'

module CDEKApiClient
  module Entities
    # Represents an invoice entity for printing invoices in the CDEK API.
    class Invoice < Dry::Struct
      attribute :orders, Types::Array.of(Types::Hash)
      attribute? :copy_count, Types::Integer.default(1)
      attribute? :type, Types::String.optional

      # Creates an Invoice with orders UUIDs.
      #
      # @param orders_uuid [String, Array<String>] the order UUID(s).
      # @return [Invoice] the invoice instance.
      def self.with_orders_uuid(orders_uuid)
        orders = Array(orders_uuid).map do |uuid|
          { order_uuid: uuid }
        end
        new(orders: orders)
      end

      # Creates an Invoice with CDEK numbers.
      #
      # @param cdek_numbers [String, Array<String>] the CDEK number(s).
      # @return [Invoice] the invoice instance.
      def self.with_cdek_numbers(cdek_numbers)
        orders = Array(cdek_numbers).map do |number|
          { cdek_number: number }
        end
        new(orders: orders)
      end

      # Converts the Invoice object to a JSON representation.
      #
      # @return [String] the JSON representation of the Invoice.
      def to_json(*_args)
        to_h.compact.to_json
      end
    end
  end
end
