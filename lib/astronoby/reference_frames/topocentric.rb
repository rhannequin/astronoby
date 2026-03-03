# frozen_string_literal: true

module Astronoby
  # Topocentric reference frame. Represents a body's position as seen from a
  # specific observer on Earth's surface, accounting for the observer's
  # geocentric position and Earth rotation.
  class Topocentric < ReferenceFrame
    # Builds a topocentric frame from an apparent frame and observer.
    #
    # @param apparent [Astronoby::Apparent] the apparent frame
    # @param observer [Astronoby::Observer] the observer
    # @param instant [Astronoby::Instant] the time instant
    # @param target_body [Class, Object] the target body
    # @return [Astronoby::Topocentric] a new topocentric frame
    def self.build_from_apparent(
      apparent:,
      observer:,
      instant:,
      target_body:
    )
      matrix = observer.earth_fixed_rotation_matrix_for(instant)

      observer_position = Distance.vector_from_meters(
        matrix * observer.geocentric_position.map(&:m)
      )
      observer_velocity = Velocity.vector_from_mps(
        matrix * observer.geocentric_velocity.map(&:mps)
      )

      position = apparent.position - observer_position
      velocity = apparent.velocity - observer_velocity

      new(
        position: position,
        velocity: velocity,
        instant: instant,
        center_identifier: [observer.longitude, observer.latitude],
        target_body: target_body,
        observer: observer
      )
    end

    # @param position [Astronoby::Vector<Astronoby::Distance>] position vector
    # @param velocity [Astronoby::Vector<Astronoby::Velocity>] velocity vector
    # @param instant [Astronoby::Instant] the time instant
    # @param center_identifier [Array] observer coordinates
    # @param target_body [Class, Object] the target body
    # @param observer [Astronoby::Observer] the observer
    def initialize(
      position:,
      velocity:,
      instant:,
      center_identifier:,
      target_body:,
      observer:
    )
      super(
        position: position,
        velocity: velocity,
        instant: instant,
        center_identifier: center_identifier,
        target_body: target_body
      )
      @observer = observer
    end

    # @return [Astronoby::Coordinates::Ecliptic] ecliptic coordinates at the
    #   current instant
    def ecliptic
      @ecliptic ||= begin
        return Coordinates::Ecliptic.zero if distance.zero?

        equatorial.to_ecliptic(instant: @instant)
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

      if refraction
        Refraction.correct_horizontal_coordinates(coordinates: horizontal)
      else
        horizontal
      end
    end
  end
end
