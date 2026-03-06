# frozen_string_literal: true

module Astronoby
  # Astrometric reference frame (GCRS). Represents a body's position relative
  # to the Earth, corrected for light-time delay.
  class Astrometric < ReferenceFrame
    # Builds an astrometric frame from geometric frames with light-time
    # correction.
    #
    # @param instant [Astronoby::Instant] the time instant
    # @param earth_geometric [Astronoby::Geometric] Earth's geometric frame
    # @param light_time_corrected_position [Astronoby::Vector<Astronoby::Distance>]
    #   target position corrected for light-time delay
    # @param light_time_corrected_velocity [Astronoby::Vector<Astronoby::Velocity>]
    #   target velocity corrected for light-time delay
    # @param target_body [Class, Object] the target body
    # @return [Astronoby::Astrometric] a new astrometric frame
    def self.build_from_geometric(
      instant:,
      earth_geometric:,
      light_time_corrected_position:,
      light_time_corrected_velocity:,
      target_body:
    )
      new(
        position: light_time_corrected_position - earth_geometric.position,
        velocity: light_time_corrected_velocity - earth_geometric.velocity,
        instant: instant,
        center_identifier: SolarSystemBody::EARTH,
        target_body: target_body
      )
    end
  end
end
