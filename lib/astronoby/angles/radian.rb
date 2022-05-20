# frozen_string_literal: true

module Astronoby
  class Radian < Angle
    def initialize(angle)
      super(angle, unit: RADIANS)
    end

    def to_degrees
      self.class.as_degrees(@angle * 180 / PI)
    end

    def to_radians
      self
    end

    def to_dms
      to_degrees.to_dms
    end
  end
end
