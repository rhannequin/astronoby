# frozen_string_literal: true

module Astronoby
  class Uranus < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(25_559_000)

    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, URANUS_BARYCENTER]]
    end
  end
end
