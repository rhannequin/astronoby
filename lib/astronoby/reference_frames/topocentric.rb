# frozen_string_literal: true

module Astronoby
  # Topocentric reference frame. Represents a body's position as seen from a
  # specific observer on Earth's surface, accounting for the observer's
  # geocentric position, its velocity from the Earth's rotation, and the
  # Earth's rotation itself.
  class Topocentric < ReferenceFrame
    LIGHT_SPEED = Velocity.light_speed.mps

    # Builds a topocentric frame from an astrometric frame and an observer.
    # The observer's position is subtracted from the astrometric position, with
    # the change in light time it brings, then the Sun's gravitational light
    # deflection and the aberration from the Earth's velocity and the
    # observer's own are applied in GCRS, before rotating by nutation *
    # precession (with ICRS frame bias). Without Earth's geometric frame the
    # aberration only comes from the observer's velocity and there is no
    # deflection, which also needs the Sun's geometric frame.
    #
    # @param instant [Astronoby::Instant] the time instant
    # @param target_astrometric [Astronoby::Astrometric] target's astrometric
    #   frame
    # @param observer [Astronoby::Observer] the observer
    # @param target_body [Astronoby::Body, nil] the target body
    # @param earth_geometric [Astronoby::Geometric, nil] Earth's geometric
    #   frame
    # @param sun_geometric [Astronoby::Geometric, nil] the Sun's geometric
    #   frame, used to apply light deflection
    # @param target_barycentric_velocity
    #   [Astronoby::Vector<Astronoby::Velocity>, nil] the target's velocity
    #   relative to the solar system barycentre, by default its astrometric
    #   velocity plus Earth's
    # @param precession_matrix [Matrix] precession-bias matrix at the instant
    # @param nutation_matrix [Matrix] nutation matrix at the instant
    # @return [Astronoby::Topocentric] a new topocentric frame
    def self.build_from_astrometric(
      instant:,
      target_astrometric:,
      observer:,
      target_body:,
      earth_geometric: nil,
      sun_geometric: nil,
      target_barycentric_velocity: nil,
      precession_matrix: Precession.matrix_for(instant),
      nutation_matrix: Nutation.matrix_for(instant)
    )
      true_of_date = nutation_matrix * precession_matrix
      to_gcrs = true_of_date.transpose *
        observer.earth_fixed_rotation_matrix_for(instant)
      observer_position = to_gcrs * observer.geocentric_position.map(&:m)
      observer_velocity = to_gcrs * observer.geocentric_velocity.map(&:mps)

      target_position = target_astrometric.position.map(&:m)
      target_velocity = target_astrometric.velocity.map(&:mps)
      earth_velocity = if earth_geometric
        earth_geometric.velocity.map(&:mps)
      else
        Vector[0.0, 0.0, 0.0]
      end
      barycentric_velocity = if target_barycentric_velocity
        target_barycentric_velocity.map(&:mps)
      else
        target_velocity + earth_velocity
      end
      distance = target_position.r
      light_time_change = if distance.zero?
        0.0
      else
        target_position.inner_product(observer_position) /
          (distance * LIGHT_SPEED)
      end

      position = Distance.vector_from_meters(
        target_position - observer_position +
          barycentric_velocity * light_time_change
      )

      if earth_geometric && sun_geometric &&
          !Apparent::UNDEFLECTED_BODIES.include?(target_body)
        position = Deflection.new(
          target_astrometric_position: position,
          observer_position: earth_geometric.position +
            Distance.vector_from_meters(observer_position),
          sun_position: sun_geometric.position
        ).corrected_position
      end

      position = Aberration.new(
        astrometric_position: position,
        observer_velocity: Velocity.vector_from_mps(
          earth_velocity + observer_velocity
        )
      ).corrected_position

      new(
        position: Distance.vector_from_meters(
          true_of_date * position.map(&:m)
        ),
        velocity: Velocity.vector_from_mps(
          true_of_date * (target_velocity - observer_velocity)
        ),
        instant: instant,
        center: Center.topocentric(observer),
        target_body: target_body,
        observer: observer
      )
    end

    # Builds a topocentric frame from an apparent frame and observer, by
    # subtracting the observer's position from the apparent position. It leaves
    # out the aberration from the observer's velocity.
    #
    # @deprecated Use {.build_from_astrometric} or +observed_by(observer)+
    # @param apparent [Astronoby::Apparent] the apparent frame
    # @param observer [Astronoby::Observer] the observer
    # @param instant [Astronoby::Instant] the time instant
    # @param target_body [Astronoby::Body, nil] the target body
    # @return [Astronoby::Topocentric] a new topocentric frame
    def self.build_from_apparent(
      apparent:,
      observer:,
      instant:,
      target_body:
    )
      Deprecation.warn(
        self,
        :build_from_apparent,
        instead: "Astronoby::Topocentric.build_from_astrometric"
      ) do
        [
          "Astronoby::Topocentric.build_from_apparent",
          "body.observed_by(observer)"
        ]
      end

      matrix = observer.earth_fixed_rotation_matrix_for(instant)

      observer_position = Distance.vector_from_meters(
        matrix * observer.geocentric_position.map(&:m)
      )
      observer_velocity = Velocity.vector_from_mps(
        matrix * observer.geocentric_velocity.map(&:mps)
      )

      new(
        position: apparent.position - observer_position,
        velocity: apparent.velocity - observer_velocity,
        instant: instant,
        center: Center.topocentric(observer),
        target_body: target_body,
        observer: observer
      )
    end

    # @param position [Astronoby::Vector<Astronoby::Distance>] position vector
    # @param velocity [Astronoby::Vector<Astronoby::Velocity>] velocity vector
    # @param instant [Astronoby::Instant] the time instant
    # @param center [Astronoby::Center] the center of the frame
    # @param target_body [Astronoby::Body, nil] the target body
    # @param observer [Astronoby::Observer] the observer
    def initialize(
      position:,
      velocity:,
      instant:,
      center:,
      target_body:,
      observer:
    )
      super(
        position: position,
        velocity: velocity,
        instant: instant,
        center: center,
        target_body: target_body
      )
      @observer = observer
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

    # Converts to horizontal coordinates (azimuth/altitude).
    #
    # @param refraction [Boolean] whether to apply atmospheric refraction
    #   correction (default: false)
    # @return [Astronoby::Coordinates::Horizontal] horizontal coordinates
    def horizontal(refraction: false)
      horizontal = equatorial.to_horizontal(
        time: @instant.to_time,
        observer: @observer
      )

      refraction ? horizontal.refract : horizontal
    end
  end
end
