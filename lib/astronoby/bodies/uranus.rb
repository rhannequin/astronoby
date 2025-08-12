# frozen_string_literal: true

module Astronoby
  class Uranus < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(25_559_000)
    ABSOLUTE_MAGNITUDE = -7.11

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, URANUS_BARYCENTER]]
    end

    def self.absolute_magnitude
      ABSOLUTE_MAGNITUDE
    end
  end
end
