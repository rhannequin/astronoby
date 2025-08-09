# frozen_string_literal: true

module Astronoby
  class Saturn < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(60_268_000)
    ABSOLUTE_MAGNITUDE = -8.914

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, SATURN_BARYCENTER]]
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
      if phase_angle_degrees <= 6
        -0.036 -
          3.7 * 10**-4 * phase_angle_degrees +
          6.16 * 10**-4 * phase_angle_degrees * phase_angle_degrees
      else
        0.026 +
          2.446 * 10**-4 * phase_angle_degrees +
          2.672 * 10**-4 * phase_angle_degrees * phase_angle_degrees -
          1.505 * 10**-6 * phase_angle_degrees**3 +
          4.767 * 10**-9 * phase_angle_degrees**4
      end
    end
  end
end
