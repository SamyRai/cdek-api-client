# frozen_string_literal: true

require 'dry-struct'

# Monkey-patch Dry::Struct to support Hash-like access for backward compatibility
module Dry
  class Struct
    def [](key)
      attributes[key.to_sym] || attributes[key.to_s]
    end

    def key?(key)
      attributes.key?(key.to_sym) || attributes.key?(key.to_s)
    end

    def include?(key)
      key?(key)
    end
  end
end
