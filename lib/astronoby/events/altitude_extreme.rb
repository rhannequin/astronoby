# frozen_string_literal: true

module Astronoby
  # A culmination of a body, when it crosses the observer's meridian above or
  # below the pole.
  class AltitudeExtreme
    KINDS = [
      UPPER_CULMINATION = :upper_culmination,
      LOWER_CULMINATION = :lower_culmination
    ].freeze

    # @return [Symbol] +:upper_culmination+ (highest altitude) or
    #   +:lower_culmination+ (lowest altitude)
    attr_reader :kind

    # @return [Astronoby::Instant] when the body crosses the meridian
    attr_reader :instant

    # @return [Astronoby::Angle] the altitude at that instant
    attr_reader :altitude

    # @param kind [Symbol] +:upper_culmination+ or +:lower_culmination+
    # @param instant [Astronoby::Instant] when the body crosses the meridian
    # @param altitude [Astronoby::Angle] the altitude at that instant
    def initialize(kind:, instant:, altitude:)
      @kind = kind
      @instant = instant
      @altitude = altitude
    end
  end
end
