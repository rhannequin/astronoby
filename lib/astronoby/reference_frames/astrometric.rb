# frozen_string_literal: true

module Astronoby
  class Astrometric < ReferenceFrame
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
