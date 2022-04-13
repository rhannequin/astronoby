# frozen_string_literal: true

module Astronoby
  class Angle
    DEGREES = :degrees
    RADIANS = :radians

    def self.as_degrees(angle)
      new(angle, unit: DEGREES)
    end

    def self.as_radians
      new(angle, unit: RADIANS)
    end

    def initialize(angle, unit:)
      @angle = angle
      @unit = unit
    end

    def to_degrees
      return @angle if degrees?

      @angle.to_r * 180r / Math::PI.to_r
    end

    def to_radians
      return @angle if radians?

      @angle.to_r / 180r * Math::PI.to_r
    end

    private

    def degrees?
      @unit == DEGREES
    end

    def radians?
      @unit == RADIANS
    end
  end
end
