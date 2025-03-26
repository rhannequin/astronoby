# frozen_string_literal: true

module Astronoby
  class Apparent < ReferenceFrame
    def self.build_from_astrometric(
      instant:,
      target_astrometric:,
      earth_geometric:,
      target_body:
    )
      position = target_astrometric.position
      velocity = target_astrometric.velocity
      precession_matrix = Precession.matrix_for(instant)
      nutation_matrix = Nutation.matrix_for(instant)

      corrected_position = Distance.vector_from_meters(
        precession_matrix * nutation_matrix * position.map(&:m)
      )
      corrected_position = Aberration.new(
        astrometric_position: corrected_position,
        observer_velocity: earth_geometric.velocity
      ).corrected_position
      # In theory, here we should also apply light deflection. However, so far
      # the deflection algorithm hasn't shown any significant changes to the
      # apparent position. Therefore, for now, we are saving some computation
      # time by not applying it, and we will investigate if the algorithm is
      # correct or if the deflection is indeed negligible.

      corrected_velocity = Velocity.vector_from_mps(
        precession_matrix * nutation_matrix * velocity.map(&:mps)
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

    def angular_diameter
      @angular_radius ||= begin
        return Angle.zero if @position.zero?

        Angle.from_radians(
          Math.atan(@target_body.class::EQUATORIAL_RADIUS.m / distance.m) * 2
        )
      end
    end
  end
end
