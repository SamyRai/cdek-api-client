# frozen_string_literal: true

# Validatable module provides validation capabilities for entities.
module CDEKApiClient
  module Entities
    # This module provides validation capabilities for entities.
    # It allows for presence and type validations on attributes.
    module Validatable
      def self.included(base)
        base.extend ClassMethods
      end

      # Class methods for the Validatable module.
      module ClassMethods
        # Defines validations for attributes.
        #
        # @param attribute [Symbol] the name of the attribute to validate.
        # @param options [Hash] the validation options.
        # @option options [Symbol] :type the expected type of the attribute.
        # @option options [Boolean] :presence whether the attribute is required.
        def validates(attribute, options)
          @validations ||= {}
          @validations[attribute] = options
        end

        # Returns the defined validations.
        #
        # @return [Hash] the defined validations.
        def validations
          @validations
        end
      end

      # Validates the entity's attributes based on the defined validations.
      #
      # @raise [RuntimeError] if any validation fails.
      def validate!
        self.class.validations.each do |attribute, rule|
          value = send(attribute)
          validate_presence(attribute, value, rule)
          validate_type(attribute, value, rule) unless value.nil?
        end
      end

      private

      # Validates the presence of an attribute.
      #
      # @param attribute [Symbol] the name of the attribute.
      # @param value [Object] the value of the attribute.
      # @param rule [Hash] the validation rule.
      # @raise [RuntimeError] if the validation fails.
      def validate_presence(attribute, value, rule)
        raise "#{attribute} is required" if rule[:presence] && value.nil?
      end

      # Validates the type of an attribute.
      #
      # @param attribute [Symbol] the name of the attribute.
      # @param value [Object] the value of the attribute.
      # @param rule [Hash] the validation rule.
      # @raise [RuntimeError] if the validation fails.
      def validate_type(attribute, value, rule)
        case rule[:type]
        when :string
          validate_string(attribute, value)
        when :integer
          validate_integer(attribute, value, rule)
        when :array
          validate_array(attribute, value, rule)
        when :object
          validate_object(attribute, value, rule)
        when :hash
          validate_hash(attribute, value, rule)
        end
      end

      # Validates that a value is a string.
      #
      # @param attribute [Symbol] the name of the attribute.
      # @param value [Object] the value of the attribute.
      # @raise [RuntimeError] if the validation fails.
      def validate_string(attribute, value)
        raise "#{attribute} must be a String" unless value.is_a?(String)
      end

      # Validates that a value is an integer and optionally that it is positive.
      #
      # @param attribute [Symbol] the name of the attribute.
      # @param value [Integer] the value of the attribute.
      # @param rule [Hash] the validation rule.
      # @raise [RuntimeError] if the validation fails.
      def validate_integer(attribute, value, rule)
        raise "#{attribute} must be an Integer" unless value.is_a?(Integer)

        validate_positive(attribute, value, rule)
      end

      # Validates that a value is an array and its items.
      #
      # @param attribute [Symbol] the name of the attribute.
      # @param array [Array] the value of the attribute.
      # @param rule [Hash] the validation rule.
      # @raise [RuntimeError] if the validation fails.
      def validate_array(attribute, array, rule)
        raise "#{attribute} must be an Array" unless array.is_a?(Array)

        validate_array_items(attribute, array, rule)
      end

      # Validates that a value is positive.
      #
      # @param attribute [Symbol] the name of the attribute.
      # @param value [Integer] the value of the attribute.
      # @param rule [Hash] the validation rule.
      # @raise [RuntimeError] if the validation fails.
      def validate_positive(attribute, value, rule)
        raise "#{attribute} must be a positive number" if rule[:positive] && value <= 0
      end

      # Validates the items of an array.
      #
      # @param attribute [Symbol] the name of the attribute.
      # @param array [Array] the value of the attribute.
      # @param rule [Hash] the validation rule.
      # @raise [RuntimeError] if the validation fails.
      def validate_array_items(attribute, array, rule)
        array.each do |item|
          if item.is_a?(Hash)
            validate_hash(attribute, item, rule[:items].first)
          elsif item.is_a?(self.class || Class)
            validate_object(attribute, item, rule[:items].first)
          else
            rule[:items].each do |key, val_rule|
              validate_presence(key, item, { type: val_rule })
              validate_type(key, item, { type: val_rule })
            end
          end
        end
      end

      # Validates an object.
      #
      # @param _attribute [Symbol] the name of the attribute.
      # @param object [Object] the value of the attribute.
      # @param _rule [Hash] the validation rule.
      # @raise [RuntimeError] if the validation fails.
      def validate_object(_attribute, object, _rule)
        object.class.validations.each do |attr, validation_rule|
          value = object.send(attr)
          validate_presence(attr, value, validation_rule)
          validate_type(attr, value, validation_rule) unless value.nil?
        end
      end

      # Validates a hash.
      #
      # @param _attribute [Symbol] the name of the attribute.
      # @param hash [Hash] the value of the attribute.
      # @param rule [Hash] the validation rule.
      # @raise [RuntimeError] if the validation fails.
      def validate_hash(_attribute, hash, rule)
        return unless rule[:schema]

        rule[:schema].each do |attr, validation_rule|
          value = hash[attr]
          validate_presence(attr, value, validation_rule)
          validate_type(attr, value, validation_rule) unless value.nil?
        end
      end
    end
  end
end
