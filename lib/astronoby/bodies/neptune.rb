# frozen_string_literal: true

module Astronoby
  class Neptune < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(24_764_000)
    ABSOLUTE_MAGNITUDE = -7.0

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, NEPTUNE_BARYCENTER]]
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
      if phase_angle_degrees < 133 && @instant.tt > JulianDate::J2000
        7.944 * 10**-3 * phase_angle_degrees +
          9.617 * 10**-5 * phase_angle_degrees * phase_angle_degrees
      else
        super
      end
    end
  end
end
