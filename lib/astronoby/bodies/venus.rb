# frozen_string_literal: true

module Astronoby
  class Venus < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(6_051_800)
    ABSOLUTE_MAGNITUDE = -4.384

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, VENUS_BARYCENTER]]
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
      if phase_angle_degrees < 163.7
        -1.044 * 10**-3 * phase_angle_degrees +
          3.687 * 10**-4 * phase_angle_degrees * phase_angle_degrees -
          2.814 * 10**-6 * phase_angle_degrees**3 +
          8.938 * 10**-9 * phase_angle_degrees**4

      else
        240.44228 - 2.81914 * phase_angle_degrees +
          8.39034 * 10**-3 * phase_angle_degrees * phase_angle_degrees
      end
    end
  end
end
