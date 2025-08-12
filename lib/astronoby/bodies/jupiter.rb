# frozen_string_literal: true

module Astronoby
  class Jupiter < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(71_492_000)
    ABSOLUTE_MAGNITUDE = -9.395

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, JUPITER_BARYCENTER]]
    end

    def self.absolute_magnitude
      ABSOLUTE_MAGNITUDE
    end

    private

    # Source:
    #  Title: Computing Apparent Planetary Magnitudes for The Astronomical
    #    Almanac (2018)
    #  Authors: Anthony Mallama and James L. Hilton
    def magnitude_correction_term
      phase_angle_degrees = phase_angle.degrees
      -3.7 * 10**-4 * phase_angle_degrees +
        6.16 * 10**-4 * phase_angle_degrees * phase_angle_degrees
    end
  end
end
