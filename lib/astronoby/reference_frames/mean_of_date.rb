# frozen_string_literal: true

module Astronoby
  class MeanOfDate < ReferenceFrame
    def self.build_from_geometric(
      ephem:,
      instant:,
      target_geometric:,
      target_body:
    )
      earth_geometric = Earth.geometric(ephem: ephem, instant: instant)
      position = target_geometric.position - earth_geometric.position
      velocity = target_geometric.velocity - earth_geometric.velocity
      precession_matrix = Precession.matrix_for(instant)
      corrected_position = Vector
        .elements(precession_matrix * position.map(&:m))
        .map { Distance.from_meters(_1) }
      corrected_velocity = Vector[*precession_matrix * velocity
        .map(&:aupd)].map { Velocity.from_astronomical_units_per_day(_1) }

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
