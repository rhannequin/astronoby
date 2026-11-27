# frozen_string_literal: true

module Astronoby
  class Sky
    # The point of a target that crosses an altitude: its centre or one of
    # its limbs.
    class TargetPoint
      REFERENCES = [:center, :upper_limb, :lower_limb].freeze

      # @return [Astronoby::Sky::Target]
      attr_reader :target

      # @return [Symbol] +:center+, +:upper_limb+ or +:lower_limb+
      attr_reader :reference

      # @api private
      # @param target [Astronoby::Sky::Target]
      # @param reference [Symbol] +:center+, +:upper_limb+ or +:lower_limb+
      def initialize(target:, reference:)
        @target = target
        @reference = reference
      end

      def inspect
        "#<#{self.class} #{@target.inspect} #{@reference}>"
      end
    end
  end
end
