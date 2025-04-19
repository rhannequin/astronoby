# frozen_string_literal: true

module Astronoby
  class Neptune < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(24_764_000)

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, NEPTUNE_BARYCENTER]]
    end
  end
end
