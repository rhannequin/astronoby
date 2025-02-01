# frozen_string_literal: true

module Astronoby
  class Earth < Planet
    private

    def ephemeris_segments
      [
        [SOLAR_SYSTEM_BARYCENTER, EARTH_MOON_BARYCENTER],
        [EARTH_MOON_BARYCENTER, EARTH]
      ]
    end
  end
end
