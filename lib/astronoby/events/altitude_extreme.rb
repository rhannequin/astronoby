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

    # @return [Astronoby::Angle] the altitude at that instant, true or
    #   apparent depending on {#refracted?}
    attr_reader :altitude

    # @param kind [Symbol] +:upper_culmination+ or +:lower_culmination+
    # @param instant [Astronoby::Instant] when the body crosses the meridian
    # @param altitude [Astronoby::Angle] the altitude at that instant
    # @param refracted [Boolean] whether the altitude includes atmospheric
    #   refraction
    # @param observer [Astronoby::Observer, nil] the observer, whose
    #   atmosphere tells whether a body below the true horizon is visible
    def initialize(kind:, instant:, altitude:, refracted: false, observer: nil)
      @kind = kind
      @instant = instant
      @altitude = altitude
      @refracted = refracted ? true : false
      @observer = observer
    end

    # @return [Boolean] true if the altitude is the apparent one, with
    #   atmospheric refraction, false if it is the true, geometric one
    def refracted?
      @refracted
    end

    # @return [Astronoby::Airmass, nil] the airmass at {#altitude}, so at the
    #   calculator's reference point, the limb when one is used, or nil below
    #   the apparent horizon
    def airmass
      if refracted?
        Airmass.from_apparent_altitude(@altitude)
      else
        Airmass.from_true_altitude(@altitude, observer: @observer)
      end
    end
  end
end
