# frozen_string_literal: true

module Astronoby
  module Position
    class Geometric < ICRF
      def initialize(
        position:,
        velocity:,
        instant:,
        target_body:
      )
        super(
          position: position,
          velocity: velocity,
          instant: instant,
          center_identifier: Planet::SOLAR_SYSTEM_BARYCENTER,
          target_body: target_body
        )
      end

      def to_astrometric(ephem:)
        earth_geometric = Earth.geometric(ephem: ephem, instant: @instant)
        position_corrected, velocity_corrected =
          apply_light_time_delay_correction(
            earth_geometric,
            self,
            ephem
          )
        Astrometric.new(
          position: position_corrected - earth_geometric.position,
          velocity: velocity_corrected - earth_geometric.velocity,
          instant: @instant,
          center_identifier: Planet::EARTH,
          target_body: self.class
        )
      end

      private

      def apply_light_time_delay_correction(center, target, ephem)
        corrected_position, corrected_velocity =
          Correction::LightTimeDelay.compute(
            center: center,
            target: target,
            ephem: ephem
          )

        [Vector[*corrected_position], Vector[*corrected_velocity]]
      end
    end
  end
end
