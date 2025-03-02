# frozen_string_literal: true

module Astronoby
  class Apparent < ReferenceFrame
    def self.build_from_astrometric(
      ephem:,
      instant:,
      target_astrometric:,
      target_body:
    )
      earth_geometric = Earth.geometric(ephem: ephem, instant: instant)
      position = target_astrometric.position
      velocity = target_astrometric.velocity
      precession_matrix = Precession.matrix_for(instant)
      nutation_matrix = Nutation2.matrix_for(instant)

      corrected_position = Vector
        .elements(precession_matrix * nutation_matrix * position.map(&:m))
        .map { Distance.from_meters(_1) }
      corrected_position = Aberration2.new(
        astrometric_position: corrected_position,
        observer_velocity: earth_geometric.velocity
      ).corrected_position
      # In theory, here we should also apply light deflection. However, so far
      # the deflection algorithm hasn't shown any significant changes to the
      # apparent position. Therefore, for now, we are saving some computation
      # time by not applying it, and we will investigate if the algorithm is
      # correct or if the deflection is indeed negligible.

      corrected_velocity = Vector[
        *precession_matrix * nutation_matrix * velocity.map(&:aupd)
      ].map { Velocity.from_astronomical_units_per_day(_1) }

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
