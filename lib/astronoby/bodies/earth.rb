# frozen_string_literal: true

module Astronoby
  # Represents the Earth. Provides ephemeris segments for computing Earth's
  # geometric position.
  class Earth < SolarSystemBody
    # @param ephem_source [Symbol] the ephemeris source type
    # @return [Array<Array>] ephemeris segment identifiers
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

    # @return [nil] Earth has no phase angle as seen from itself
    def phase_angle
      nil
    end
  end
end
