# frozen_string_literal: true

require 'dry-struct'
require_relative 'types'

module CDEKApiClient
  module Entities
    # Represents a barcode entity for printing barcodes in the CDEK API.
    class Barcode < Dry::Struct
      attribute :orders, Types::Array.of(Types::Hash)
      attribute? :copy_count, Types::Integer.default(1)
      attribute? :type, Types::String.optional
      attribute? :format, Types::String.default('A4')
      attribute? :lang, Types::String.optional

      # Creates a Barcode with orders UUIDs.
      #
      # @param orders_uuid [String, Array<String>] the order UUID(s).
      # @return [Barcode] the barcode instance.
      def self.with_orders_uuid(orders_uuid)
        orders = Array(orders_uuid).map do |uuid|
          { order_uuid: uuid }
        end
        new(orders: orders)
      end

      # Creates a Barcode with CDEK numbers.
      #
      # @param cdek_numbers [String, Array<String>] the CDEK number(s).
      # @return [Barcode] the barcode instance.
      def self.with_cdek_numbers(cdek_numbers)
        orders = Array(cdek_numbers).map do |number|
          { cdek_number: number }
        end
        new(orders: orders)
      end

      # Converts the Barcode object to a JSON representation.
      #
      # @return [String] the JSON representation of the Barcode.
      def to_json(*_args)
        to_h.compact.to_json
      end
    end
  end
end
