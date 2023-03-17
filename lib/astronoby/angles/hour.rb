# frozen_string_literal: true

module Astronoby
  class Hour < Angle
    def initialize(angle)
      super(angle, unit: HOURS)
    end

    def to_degrees
      self.class.as_degrees(@angle * BigDecimal("15"))
    end

    def to_hours
      self
    end

    def to_radians
      self.class.as_radians(@angle * (PI / BigDecimal("12")))
    end

    def to_hms
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

      Hms.new(hours, minutes, seconds.to_f.floor(4))
    end
  end
end
