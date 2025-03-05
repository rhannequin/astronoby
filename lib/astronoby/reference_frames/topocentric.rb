# frozen_string_literal: true

module Astronoby
  class Topocentric < ReferenceFrame
    def self.build_from_apparent(
      apparent:,
      observer:,
      instant:,
      target_body:
    )
      position = apparent.position - observer.geocentric_position
      velocity = apparent.velocity - observer.geocentric_velocity

      new(
        position: position,
        velocity: velocity,
        instant: instant,
        center_identifier: nil, # TODO: center_identifier really necessary?
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
