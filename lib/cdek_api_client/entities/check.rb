# frozen_string_literal: true

require 'dry-struct'
require_relative 'types'

module CDEKApiClient
  module Entities
    # Represents a check entity for retrieving check information in the CDEK API.
    class Check < Dry::Struct
      attribute? :cdek_number, Types::String.optional
      attribute? :date, Types::String.optional

      # Converts the Check object to a hash for query parameters.
      #
      # @return [Hash] the query parameters.
      def to_query_params
        to_h.compact
      end

      # Converts the Check object to a JSON representation.
      #
      # @return [String] the JSON representation of the Check.
      def to_json(*_args)
        to_query_params.to_json
      end
    end
  end
end
