# frozen_string_literal: true

module Astronoby
  class Mercury < Planet
    private

    def ephemeris_segments
      [
        [SOLAR_SYSTEM_BARYCENTER, MERCURY_BARYCENTER],
        [MERCURY_BARYCENTER, MERCURY]
      ]
    end
  end
end
