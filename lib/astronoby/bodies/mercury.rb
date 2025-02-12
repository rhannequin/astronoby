# frozen_string_literal: true

module Astronoby
  class Mercury < Planet
    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, MERCURY_BARYCENTER]]
    end
  end
end
