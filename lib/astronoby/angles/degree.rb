# frozen_string_literal: true

module Astronoby
  class Degree < Angle
    def initialize(angle)
      super(angle, unit: DEGREES)
    end

    def to_degrees
      self
    end

    def to_radians
      self.class.as_radians(@angle.to_r / 180r * Math::PI.to_r)
    end
  end
end
