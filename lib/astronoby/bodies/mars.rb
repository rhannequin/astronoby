# frozen_string_literal: true

module Astronoby
  class Mars < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(3_396_200)

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, MARS_BARYCENTER]]
    end
  end
end
