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
      self.class.as_radians(@angle / BigDecimal("180") * PI)
    end

    def to_dms
      sign = @angle.negative? ? -1 : 1
      absolute_degrees = @angle.abs
      degrees = absolute_degrees.floor
      decimal_minutes = 60 * (absolute_degrees - degrees)
      absolute_decimal_minutes = (60 * (absolute_degrees - degrees)).abs
      minutes = decimal_minutes.floor
      seconds = 60 * (absolute_decimal_minutes - absolute_decimal_minutes.floor)

      Dms.new(sign * degrees, minutes, seconds.floor(2))
    end
  end
end
