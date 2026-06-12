# frozen_string_literal: true

require 'dry-types'

module CDEKApiClient
  module Entities
    # Core types for Dry::Struct attributes
    module Types
      include Dry.Types()
    end
  end
end
