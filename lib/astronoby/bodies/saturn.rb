# frozen_string_literal: true

module Astronoby
  class Saturn < SolarSystemBody
    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, SATURN_BARYCENTER]]
    end
  end
end
