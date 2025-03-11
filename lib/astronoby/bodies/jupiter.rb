# frozen_string_literal: true

module Astronoby
  class Jupiter < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(71_492_000)

    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, JUPITER_BARYCENTER]]
    end
  end
end
