# frozen_string_literal: true

module Astronoby
  class Venus < Planet
    private

    def ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, VENUS_BARYCENTER]]
    end
  end
end
