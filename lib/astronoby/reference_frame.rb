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
      @equatorial ||= begin
        return Coordinates::Equatorial.zero if distance.zero?

        Coordinates::Equatorial.from_position_vector(@position)
      end
    end

    def ecliptic
      @ecliptic ||= begin
        return Coordinates::Ecliptic.zero if distance.zero?

        equatorial.to_ecliptic(epoch: Epoch::J2000)
      end
    end

    def distance
      @distance ||= begin
        return Distance.zero if @position.zero?

        @position.magnitude
      end
    end
  end
end
