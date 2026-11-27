# frozen_string_literal: true

module Astronoby
  # A moment when the Sun's centre crosses the altitude that starts or ends a
  # civil, nautical or astronomical twilight.
  class TwilightCrossing < AltitudeCrossing
    # @return [Symbol] +:civil+, +:nautical+ or +:astronomical+
    attr_reader :kind

    # @param instant [Astronoby::Instant] when the crossing happens
    # @param direction [Symbol] +:rising+ at dawn, +:setting+ at dusk
    # @param kind [Symbol] +:civil+, +:nautical+ or +:astronomical+
    # @param grazing [Boolean] whether the Sun only just reaches the altitude
    def initialize(instant:, direction:, kind:, grazing: false)
      super(instant: instant, direction: direction, grazing: grazing)
      @kind = kind
    end

    # @return [Boolean] true when the Sun rises through the altitude
    def dawn?
      direction == :rising
    end

    # @return [Boolean] true when the Sun sets through the altitude
    def dusk?
      direction == :setting
    end
  end
end
