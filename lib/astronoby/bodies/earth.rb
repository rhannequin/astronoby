# frozen_string_literal: true

module Astronoby
  class Earth < SolarSystemBody
    def self.ephemeris_segments(ephem_source)
      if ephem_source == ::Ephem::SPK::JPL_DE
        [
          [SOLAR_SYSTEM_BARYCENTER, EARTH_MOON_BARYCENTER],
          [EARTH_MOON_BARYCENTER, EARTH]
        ]
      elsif ephem_source == ::Ephem::SPK::INPOP
        [
          [SOLAR_SYSTEM_BARYCENTER, EARTH]
        ]
      end
    end

    def phase_angle
      nil
    end
  end
end
