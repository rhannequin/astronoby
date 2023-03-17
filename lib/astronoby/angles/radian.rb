# frozen_string_literal: true

module Astronoby
  class Radian < Angle
    def initialize(angle)
      super(angle, unit: RADIANS)
    end

    def to_degrees
      self.class.as_degrees(@angle * BigDecimal("180") / PI)
    end

    def to_hours
      self.class.as_hours(@angle / (PI / BigDecimal("12")))
    end

    def to_radians
      self
    end

    def to_dms
      to_degrees.to_dms
    end
  end
end
