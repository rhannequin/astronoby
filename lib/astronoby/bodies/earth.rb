# frozen_string_literal: true

module Astronoby
  class Earth < SolarSystemBody
    def self.ephemeris_segments(ephem_source)
      if ephem_source == ::Ephem::SPK::JPL_DE
        [
          [SOLAR_SYSTEM_BARYCENTER, EARTH_MOON_BARYCENTER],
          [EARTH_MOON_BARYCENTER, EARTH]
        ]
      elsif ephem_source == ::Ephem::SPK::INPOP
        [
          [SOLAR_SYSTEM_BARYCENTER, EARTH]
        ]
      end
    end

    def phase_angle
      nil
    end

    private

    # Phase angle is geocentric, therefore non-applicable for Earth.
    def compute_phase_angle?
      false
    end

    def compute_astrometric(_ephem)
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

    def compute_mean_of_date(_ephem)
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
