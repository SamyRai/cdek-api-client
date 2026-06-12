# frozen_string_literal: true

require 'dry-struct'
require_relative 'types'

module CDEKApiClient
  module Entities
    # Represents an intakes entity for courier intake requests in the CDEK API.
    class Intakes < Dry::Struct
      attribute :cdek_number, Types::String
      attribute :intake_date, Types::String
      attribute :intake_time_from, Types::String
      attribute :intake_time_to, Types::String
      attribute? :lunch_time_from, Types::String.optional
      attribute? :lunch_time_to, Types::String.optional
      attribute :name, Types::String
      attribute? :need_call, Types::Bool.optional
      attribute? :comment, Types::String.optional
      attribute :sender, Types::Hash
      attribute :from_location, Types::Hash
      attribute? :weight, Types::Coercible::Float.optional
      attribute? :length, Types::Coercible::Float.optional
      attribute? :width, Types::Coercible::Float.optional
      attribute? :height, Types::Coercible::Float.optional

      # Converts the Intakes object to a JSON representation.
      #
      # @return [String] the JSON representation of the Intakes.
      def to_json(*_args)
        to_h.compact.to_json
      end
    end
  end
end
