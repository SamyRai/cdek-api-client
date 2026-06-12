# frozen_string_literal: true

require 'dry-struct'
require_relative 'types'

module CDEKApiClient
  module Entities
    # Represents an agreement entity for delivery agreements in the CDEK API.
    class Agreement < Dry::Struct
      attribute :cdek_number, Types::String
      attribute :date, Types::String
      attribute :time_from, Types::String
      attribute :time_to, Types::String
      attribute? :comment, Types::String.optional
      attribute? :delivery_point, Types::String.optional
      attribute? :to_location, Types::Hash.optional

      # Converts the Agreement object to a JSON representation.
      #
      # @return [String] the JSON representation of the Agreement.
      def to_json(*_args)
        to_h.compact.to_json
      end
    end
  end
end
