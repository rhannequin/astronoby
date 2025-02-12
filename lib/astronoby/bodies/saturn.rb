# frozen_string_literal: true

module Astronoby
  class Saturn < Planet
    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, SATURN_BARYCENTER]]
    end
  end
end
