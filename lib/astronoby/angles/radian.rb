# frozen_string_literal: true

module Astronoby
  class Radian < Angle
    def initialize(angle)
      super(angle, unit: RADIANS)
    end

    def to_degrees
      self.class.as_degrees(@angle.to_r * 180r / Math::PI.to_r)
    end

    def to_radians
      self
    end
  end
end
