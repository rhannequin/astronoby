# frozen_string_literal: true

module Astronoby
  class Mars < Planet
    private

    def ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, MARS_BARYCENTER]]
    end
  end
end
