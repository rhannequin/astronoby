# frozen_string_literal: true

module Astronoby
  class Neptune < Planet
    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, NEPTUNE_BARYCENTER]]
    end
  end
end
