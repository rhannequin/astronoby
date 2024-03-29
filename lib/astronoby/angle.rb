# frozen_string_literal: true

require "bigdecimal/math"

module Astronoby
  class Angle
    include Comparable

    PRECISION = 14
    PI = BigMath.PI(PRECISION)
    PI_IN_DEGREES = BigDecimal("180")

    FULL_CIRCLE_IN_RADIANS = (2 * PI)

    RADIAN_PER_HOUR = PI / BigDecimal("12")
    MINUTES_PER_DEGREE = BigDecimal("60")
    MINUTES_PER_HOUR = BigDecimal("60")
    SECONDS_PER_MINUTE = BigDecimal("60")
    SECONDS_PER_HOUR = MINUTES_PER_HOUR * SECONDS_PER_MINUTE

    FORMATS = %i[dms hms].freeze

    class << self
      def zero
        new(0)
      end

      def from_radians(radians)
        normalized_radians = radians.remainder(FULL_CIRCLE_IN_RADIANS)
        new(normalized_radians)
      end

      def from_degrees(degrees)
        radians = degrees / PI_IN_DEGREES * PI
        from_radians(radians)
      end

      def from_hours(hours)
        radians = hours * RADIAN_PER_HOUR
        from_radians(radians)
      end

      def from_hms(hour, minute, second)
        hours = hour + minute / MINUTES_PER_HOUR + second / SECONDS_PER_HOUR
        from_hours(hours)
      end

      def from_dms(degree, minute, second)
        sign = degree.negative? ? -1 : 1
        degrees = degree.abs + minute / MINUTES_PER_HOUR + second / SECONDS_PER_HOUR
        from_degrees(sign * degrees)
      end

      def asin(ratio)
        radians = Math.asin(ratio)
        from_radians(radians)
      end

      def acos(ratio)
        radians = Math.acos(ratio)
        from_radians(radians)
      end

      def atan(ratio)
        radians = Math.atan(ratio)
        from_radians(radians)
      end
    end

    attr_reader :radians

    def initialize(radians)
      @radians = if radians.is_a?(Integer) || radians.is_a?(BigDecimal)
        BigDecimal(radians)
      else
        BigDecimal(radians, PRECISION)
      end
      freeze
    end

    def degrees
      @radians * PI_IN_DEGREES / PI
    end

    def hours
      @radians / RADIAN_PER_HOUR
    end

    def +(other)
      self.class.from_radians(radians + other.radians)
    end

    def -(other)
      self.class.from_radians(@radians - other.radians)
    end

    def sin
      Math.sin(radians)
    end

    def cos
      Math.cos(radians)
    end

    def tan
      Math.tan(radians)
    end

    def positive?
      radians > 0
    end

    def negative?
      radians < 0
    end

    def zero?
      radians.zero?
    end

    def ==(other)
      other.is_a?(self.class) && radians == other.radians
    end
    alias_method :eql?, :==

    def hash
      [radians, self.class].hash
    end

    def <=>(other)
      return nil unless other.is_a?(self.class)

      radians <=> other.radians
    end

    def str(format)
      case format
      when :dms then to_dms(degrees).format
      when :hms then to_hms(hours).format
      else
        raise UnsupportedFormatError.new(
          "Expected a format between #{FORMATS.join(", ")}, got #{format}"
        )
      end
    end

    def to_dms(deg)
      sign = deg.negative? ? "-" : "+"
      absolute_degrees = deg.abs
      degrees = absolute_degrees.floor
      decimal_minutes = MINUTES_PER_DEGREE * (absolute_degrees - degrees)
      absolute_decimal_minutes = (
        MINUTES_PER_DEGREE * (absolute_degrees - degrees)
      ).abs
      minutes = decimal_minutes.floor
      seconds = SECONDS_PER_MINUTE * (
        absolute_decimal_minutes - absolute_decimal_minutes.floor
      )

      Dms.new(sign, degrees, minutes, seconds.to_f.floor(4))
    end

    def to_hms(hrs)
      absolute_hours = hrs.abs
      hours = absolute_hours.floor
      decimal_minutes = MINUTES_PER_HOUR * (absolute_hours - hours)
      absolute_decimal_minutes = (
        MINUTES_PER_HOUR * (absolute_hours - hours)
      ).abs
      minutes = decimal_minutes.floor
      seconds = SECONDS_PER_MINUTE * (
        absolute_decimal_minutes - absolute_decimal_minutes.floor
      )

      Hms.new(hours, minutes, seconds.to_f.floor(4))
    end
  end
end
