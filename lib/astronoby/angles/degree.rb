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
      decimal_minutes = BigDecimal("60") * (absolute_degrees - degrees)
      absolute_decimal_minutes = (
        BigDecimal("60") * (absolute_degrees - degrees)
      ).abs
      minutes = decimal_minutes.floor
      seconds = BigDecimal("60") * (
        absolute_decimal_minutes - absolute_decimal_minutes.floor
      )

      Dms.new(sign * degrees, minutes, seconds.to_f.floor(4))
    end

    def to_hms
      sign = @angle.negative? ? -1 : 1
      absolute_hours = @angle.abs
      hours = absolute_hours.floor
      decimal_minutes = BigDecimal("60") * (absolute_hours - hours)
      absolute_decimal_minutes = (
        BigDecimal("60") * (absolute_hours - hours)
      ).abs
      minutes = decimal_minutes.floor
      seconds = BigDecimal("60") * (
        absolute_decimal_minutes - absolute_decimal_minutes.floor
      )

      Hms.new(sign * hours, minutes, seconds.to_f.floor(4))
    end
  end
end
