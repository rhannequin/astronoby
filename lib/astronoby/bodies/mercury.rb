# frozen_string_literal: true

module Astronoby
  class Mercury < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(2_439_700)

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, MERCURY_BARYCENTER]]
    end
  end
end
