# frozen_string_literal: true

module Astronoby
  # Apparent reference frame. Represents a body's geocentric position as it
  # appears from Earth, corrected for light deflection, aberration,
  # precession, and nutation.
  class Apparent < ReferenceFrame
    # The Sun does not deflect its own light, and the Moon is too close for
    # the deflection to exceed 0.01 mas.
    UNDEFLECTED_BODIES = [Sun, Moon].freeze

    # Builds an apparent frame from an astrometric frame by applying the
    # Sun's gravitational light deflection and aberration in GCRS, then
    # rotating by nutation * precession (with ICRS frame bias). Without Earth's
    # geometric frame there is no observer position or velocity to derive these
    # corrections from, so only the rotation is applied. Deflection also needs
    # the Sun's geometric frame.
    #
    # @param instant [Astronoby::Instant] the time instant
    # @param target_astrometric [Astronoby::Astrometric] target's astrometric
    #   frame
    # @param earth_geometric [Astronoby::Geometric, nil] Earth's geometric
    #   frame
    # @param sun_geometric [Astronoby::Geometric, nil] the Sun's geometric
    #   frame, used to apply light deflection
    # @param target_body [Astronoby::Body, nil] the target body
    # @param precession_matrix [Matrix] precession-bias matrix at the instant
    # @param nutation_matrix [Matrix] nutation matrix at the instant
    # @return [Astronoby::Apparent] a new apparent frame
    def self.build_from_astrometric(
      instant:,
      target_astrometric:,
      target_body:,
      earth_geometric: nil,
      sun_geometric: nil,
      precession_matrix: Precession.matrix_for(instant),
      nutation_matrix: Nutation.matrix_for(instant)
    )
      position = target_astrometric.position
      velocity = target_astrometric.velocity

      if earth_geometric && sun_geometric &&
          !UNDEFLECTED_BODIES.include?(target_body)
        position = Deflection.new(
          target_astrometric_position: position,
          observer_position: earth_geometric.position,
          sun_position: sun_geometric.position
        ).corrected_position
      end

      corrected_position = if earth_geometric
        Aberration.new(
          astrometric_position: position,
          observer_velocity: earth_geometric.velocity
        ).corrected_position
      else
        position
      end

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
        center: Center.geocentric,
        target_body: target_body
      )
    end

    # @return [Numeric] Julian Date epoch of the frame's coordinates, which
    #   are referred to the true equator and equinox of date
    def epoch
      instant.tt
    end

    # @return [Astronoby::Coordinates::Ecliptic] ecliptic coordinates at the
    #   current instant (true ecliptic and equinox of date)
    def ecliptic
      @ecliptic ||= begin
        return Coordinates::Ecliptic.zero if distance.zero?

        equatorial.to_ecliptic(
          instant: @instant,
          obliquity: TrueObliquity.at(@instant)
        )
      end
    end
  end
end
