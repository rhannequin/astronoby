# frozen_string_literal: true

module Astronoby
  class Uranus < Planet
    private

    def ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, URANUS_BARYCENTER]]
    end
  end
end
