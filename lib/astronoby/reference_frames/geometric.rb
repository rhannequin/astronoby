# frozen_string_literal: true

module Astronoby
  class Geometric < ReferenceFrame
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
  end
end
