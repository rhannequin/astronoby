# frozen_string_literal: true

require "bigdecimal/math"

module Astronoby
  class Angle
    PRECISION = 14
    PI = BigMath.PI(PRECISION)
    PI_IN_DEGREES = BigDecimal("180")

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

      def as_radians(radians)
        new(radians)
      end

      def as_degrees(degrees)
        radians = degrees / PI_IN_DEGREES * PI
        new(radians)
      end

      def as_hours(hours)
        radians = hours * RADIAN_PER_HOUR
        new(radians)
      end

      def as_hms(hour, minute, second)
        hours = hour + minute / MINUTES_PER_HOUR + second / SECONDS_PER_HOUR
        as_hours(hours)
      end

      def as_dms(degree, minute, second)
        sign = degree.negative? ? -1 : 1
        degrees = degree.abs + minute / MINUTES_PER_HOUR + second / SECONDS_PER_HOUR
        as_degrees(sign * degrees)
      end

      def asin(ratio)
        radians = Math.asin(ratio)
        as_radians(radians)
      end

      def acos(ratio)
        radians = Math.acos(ratio)
        as_radians(radians)
      end

      def atan(ratio)
        radians = Math.atan(ratio)
        as_radians(radians)
      end
    end

    attr_reader :radians

    def initialize(radians)
      @radians = if radians.is_a?(Integer) || radians.is_a?(BigDecimal)
        BigDecimal(radians)
      else
        BigDecimal(radians, PRECISION)
      end
    end

    def degrees
      @radians * PI_IN_DEGREES / PI
    end

    def hours
      @radians / RADIAN_PER_HOUR
    end

    def +(other)
      self.class.as_radians(radians + other.radians)
    end

    def -(other)
      self.class.as_radians(@radians - other.radians)
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
