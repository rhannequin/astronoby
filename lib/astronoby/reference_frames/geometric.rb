# frozen_string_literal: true

module Astronoby
  # Geometric reference frame (BCRS). Represents a body's position relative
  # to the Solar System Barycenter, without any corrections applied.
  class Geometric < ReferenceFrame
    # @param position [Astronoby::Vector<Astronoby::Distance>] position vector
    # @param velocity [Astronoby::Vector<Astronoby::Velocity>] velocity vector
    # @param instant [Astronoby::Instant] the time instant
    # @param target_body [Class] the target body class
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
        center_identifier: SolarSystemBody::SOLAR_SYSTEM_BARYCENTER,
        target_body: target_body
      )
    end
  end
end
