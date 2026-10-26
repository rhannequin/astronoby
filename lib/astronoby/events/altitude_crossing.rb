# frozen_string_literal: true

module Astronoby
  # A moment when a body's altitude passes through a given value.
  class AltitudeCrossing
    # @return [Astronoby::Instant] when the crossing happens, unrounded
    attr_reader :instant

    # @return [Symbol] +:rising+ when the altitude increases through the
    #   target, +:setting+ when it decreases
    attr_reader :direction

    # @param instant [Astronoby::Instant] when the crossing happens
    # @param direction [Symbol] +:rising+ or +:setting+
    # @param grazing [Boolean] whether the body only just reaches the target
    def initialize(instant:, direction:, grazing: false)
      @instant = instant
      @direction = direction
      @grazing = grazing
    end

    # @return [Boolean] true when the target is within a few hundredths of a
    #   degree of the body's highest or lowest altitude, so the crossing is
    #   nearly tangent and its instant is sensitive to small errors
    def grazing?
      @grazing
    end
  end
end
