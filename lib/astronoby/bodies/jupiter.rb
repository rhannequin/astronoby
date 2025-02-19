# frozen_string_literal: true

module Astronoby
  class Jupiter < SolarSystemBody
    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, JUPITER_BARYCENTER]]
    end
  end
end
