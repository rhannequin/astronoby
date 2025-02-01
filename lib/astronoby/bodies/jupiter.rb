# frozen_string_literal: true

module Astronoby
  class Jupiter < Planet
    private

    def ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, JUPITER_BARYCENTER]]
    end
  end
end
