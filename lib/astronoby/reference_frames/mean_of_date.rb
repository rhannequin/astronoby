# frozen_string_literal: true

module Astronoby
  # Mean-of-date reference frame. Represents a body's geocentric position
  # corrected for precession only (no nutation or aberration).
  class MeanOfDate < ReferenceFrame
    # Builds a mean-of-date frame from geometric frames by applying
    # precession.
    #
    # @param instant [Astronoby::Instant] the time instant
    # @param target_geometric [Astronoby::Geometric] target's geometric frame
    # @param earth_geometric [Astronoby::Geometric] Earth's geometric frame
    # @param target_body [Class, Object] the target body
    # @return [Astronoby::MeanOfDate] a new mean-of-date frame
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

    # @return [Astronoby::Coordinates::Ecliptic] ecliptic coordinates at the
    #   current instant (mean equinox of date)
    def ecliptic
      @ecliptic ||= begin
        return Coordinates::Ecliptic.zero if distance.zero?

        equatorial.to_ecliptic(instant: @instant)
      end
    end
  end
end
