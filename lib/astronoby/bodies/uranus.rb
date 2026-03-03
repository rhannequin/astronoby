# frozen_string_literal: true

module Astronoby
  # Represents Uranus.
  class Uranus < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(25_559_000)
    ABSOLUTE_MAGNITUDE = -7.11

    # @param _ephem_source [Symbol] the ephemeris source type
    # @return [Array<Array>] ephemeris segment identifiers
    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, URANUS_BARYCENTER]]
    end

    # @return [Float] absolute magnitude
    def self.absolute_magnitude
      ABSOLUTE_MAGNITUDE
    end
  end
end
