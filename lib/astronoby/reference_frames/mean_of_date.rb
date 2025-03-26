# frozen_string_literal: true

module Astronoby
  class MeanOfDate < ReferenceFrame
    def self.build_from_geometric(
      instant:,
      target_geometric:,
      earth_geometric:,
      target_body:
    )
      position = target_geometric.position - earth_geometric.position
      velocity = target_geometric.velocity - earth_geometric.velocity
      precession_matrix = Precession.matrix_for(instant)
      corrected_position = Distance.vector_from_m(
        precession_matrix * position.map(&:m)
      )
      corrected_velocity = Velocity.vector_from_mps(
        precession_matrix * velocity.map(&:mps)
      )

      new(
        position: corrected_position,
        velocity: corrected_velocity,
        instant: instant,
        center_identifier: SolarSystemBody::EARTH,
        target_body: target_body
      )
    end

    def ecliptic
      @ecliptic ||= begin
        return Coordinates::Ecliptic.zero if distance.zero?

        equatorial.to_ecliptic(epoch: @instant.tdb)
      end
    end
  end
end
