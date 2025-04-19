# frozen_string_literal: true

module Astronoby
  class Saturn < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(60_268_000)

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, SATURN_BARYCENTER]]
    end
  end
end
