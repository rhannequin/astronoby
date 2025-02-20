# frozen_string_literal: true

module Astronoby
  class Venus < SolarSystemBody
    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, VENUS_BARYCENTER]]
    end
  end
end
