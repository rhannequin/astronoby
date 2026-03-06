# frozen_string_literal: true

module Astronoby
  # Apparent reference frame. Represents a body's geocentric position as it
  # appears from Earth, corrected for aberration, precession, and nutation.
  class Apparent < ReferenceFrame
    # Builds an apparent frame from an astrometric frame by applying
    # aberration in GCRS, then rotating by nutation * precession (with ICRS
    # frame bias).
    #
    # @param instant [Astronoby::Instant] the time instant
    # @param target_astrometric [Astronoby::Astrometric] target's astrometric
    #   frame
    # @param earth_geometric [Astronoby::Geometric] Earth's geometric frame
    # @param target_body [Class, Object] the target body
    # @return [Astronoby::Apparent] a new apparent frame
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

      corrected_position = Aberration.new(
        astrometric_position: position,
        observer_velocity: earth_geometric.velocity
      ).corrected_position

      # In theory, here we should also apply light deflection. However, so far
      # the deflection algorithm hasn't shown any significant changes to the
      # apparent position. Therefore, for now, we are saving some computation
      # time by not applying it, and we will investigate if the algorithm is
      # correct or if the deflection is indeed negligible.

      corrected_position = Distance.vector_from_meters(
        nutation_matrix * precession_matrix * corrected_position.map(&:m)
      )

      corrected_velocity = Velocity.vector_from_mps(
        nutation_matrix * precession_matrix * velocity.map(&:mps)
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
    #   current instant (true equinox of date)
    def ecliptic
      @ecliptic ||= begin
        return Coordinates::Ecliptic.zero if distance.zero?

        equatorial.to_ecliptic(instant: @instant)
      end
    end
  end
end
