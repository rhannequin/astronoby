# frozen_string_literal: true

module Astronoby
  class Mars < Planet
    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, MARS_BARYCENTER]]
    end
  end
end
