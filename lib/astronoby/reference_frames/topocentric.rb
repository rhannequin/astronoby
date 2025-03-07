# frozen_string_literal: true

module Astronoby
  class Topocentric < ReferenceFrame
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
        matrix * observer.geocentric_velocity.map(&:kmps)
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

    def ecliptic
      @ecliptic ||= begin
        return Coordinates::Ecliptic.zero if distance.zero?

        equatorial.to_ecliptic(epoch: @instant.tdb)
      end
    end

    def horizontal
      @horizontal ||= equatorial.to_horizontal(
        time: @instant.to_time,
        observer: @observer
      )
    end
  end
end
