# frozen_string_literal: true

module Astronoby
  class Mercury < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(2_439_700)
    ABSOLUTE_MAGNITUDE = -0.613

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, MERCURY_BARYCENTER]]
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
      6.328 * 10**-2 * phase_angle_degrees -
        1.6336 * 10**-3 * phase_angle_degrees * phase_angle_degrees +
        3.3634 * 10**-5 * phase_angle_degrees**3 -
        3.4265 * 10**-7 * phase_angle_degrees**4 +
        1.6893 * 10**-9 * phase_angle_degrees**5 -
        3.0334 * 10**-12 * phase_angle_degrees**6
    end
  end
end
