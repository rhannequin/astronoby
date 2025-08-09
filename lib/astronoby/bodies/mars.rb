# frozen_string_literal: true

module Astronoby
  class Mars < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(3_396_200)
    ABSOLUTE_MAGNITUDE = -1.601

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, MARS_BARYCENTER]]
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
      2.267 * 10**-2 * phase_angle_degrees -
        1.302 * 10**-4 * phase_angle_degrees * phase_angle_degrees
    end
  end
end
