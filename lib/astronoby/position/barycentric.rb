# frozen_string_literal: true

module Astronoby
  module Position
    class Barycentric < ICRF
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
        earth_barycentric = Earth.barycentric(ephem: ephem, instant: @instant)
        position_corrected = apply_light_time_delay_correction(
          earth_barycentric,
          self,
          ephem
        )
        Astrometric.new(
          position: position_corrected - earth_barycentric.position,
          velocity: @velocity - @velocity,
          instant: @instant,
          center_identifier: Planet::EARTH,
          target_body: self.class
        )
      end

      private

      def apply_light_time_delay_correction(center, target, ephem)
        corrected_position = Correction::LightTimeDelay.compute(
          center: center,
          target: target,
          ephem: ephem
        )

        Vector[
          corrected_position[0], corrected_position[1], corrected_position[2]
        ]
      end
    end
  end
end
