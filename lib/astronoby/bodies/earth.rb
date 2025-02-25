# frozen_string_literal: true

module Astronoby
  class Earth < SolarSystemBody
    def self.ephemeris_segments
      [
        [SOLAR_SYSTEM_BARYCENTER, EARTH_MOON_BARYCENTER],
        [EARTH_MOON_BARYCENTER, EARTH]
      ]
    end

    private

    def compute_astrometric(ephem)
      Astrometric.new(
        position: Vector[
          Distance.zero,
          Distance.zero,
          Distance.zero
        ],
        velocity: Vector[
          Velocity.zero,
          Velocity.zero,
          Velocity.zero
        ],
        instant: @instant,
        center_identifier: EARTH,
        target_body: self.class
      )
    end

    def compute_mean_of_date(ephem)
      MeanOfDate.new(
        position: Vector[
          Distance.zero,
          Distance.zero,
          Distance.zero
        ],
        velocity: Vector[
          Velocity.zero,
          Velocity.zero,
          Velocity.zero
        ],
        instant: @instant,
        center_identifier: EARTH,
        target_body: self.class
      )
    end
  end
end
