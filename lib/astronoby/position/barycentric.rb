# frozen_string_literal: true

module Astronoby
  module Position
    class Barycentric < ICRF
      LIGHT_SPEED_KM_PER_S = 299792.458
      KM_PER_DAY_SECONDS = 1.15741e-5
      SECONDS_PER_DAY = 86400.0
      LIGHT_SPEED_CORRECTION_PRECISION = 1e-12
      LIGHT_SPEED_CORRECTION_MAXIMUM_ITERATIONS = 10

      # TODO: Move constants into Astronomy::Constants
      # TODO: Create Velocity value object
      # TODO: Add Velocity.light_speed
      # TODO: Wrap Ephem vectors into Distance and Velocity instances?

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
          center_identifier: 0, # TODO: replace with constant
          target_body: target_body
        )
      end
    end
  end
end
