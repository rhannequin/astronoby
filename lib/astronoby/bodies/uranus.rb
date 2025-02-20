# frozen_string_literal: true

module Astronoby
  class Uranus < SolarSystemBody
    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, URANUS_BARYCENTER]]
    end
  end
end
