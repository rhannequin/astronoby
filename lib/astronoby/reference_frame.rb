# frozen_string_literal: true

module Astronoby
  class ReferenceFrame
    attr_reader :position,
      :velocity,
      :instant,
      :center_identifier,
      :target_body

    def initialize(
      position:,
      velocity:,
      instant:,
      center_identifier:,
      target_body:
    )
      @position = position
      @velocity = velocity
      @instant = instant
      @center_identifier = center_identifier
      @target_body = target_body
    end

    def equatorial
      return Coordinates::Equatorial.zero if distance.zero?

      Coordinates::Equatorial.from_position_vector(@position)
    end

    def ecliptic
      return Coordinates::Ecliptic.zero if distance.zero?

      equatorial.to_ecliptic(epoch: Epoch::J2000)
    end

    def distance
      return Distance.zero if @position.zero?

      Astronoby::Distance.from_meters(@position.magnitude)
    end
  end
end
