# frozen_string_literal: true

module Astronoby
  class Venus < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(6_051_800)

    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, VENUS_BARYCENTER]]
    end
  end
end
