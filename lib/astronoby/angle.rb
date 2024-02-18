# frozen_string_literal: true

require "bigdecimal/math"

module Astronoby
  class Angle
    PRECISION = 14
    PI = BigMath.PI(PRECISION)
    FORMATS = %i[dms hms].freeze

    class << self
      def as_radians(radians)
        new(radians)
      end

      def as_degrees(degrees)
        radians = degrees / BigDecimal("180") * PI
        new(radians)
      end

      def as_hours(hours)
        radians = hours * (PI / BigDecimal("12"))
        new(radians)
      end

      def as_hms(hour, minute, second)
        hours = hour + minute / 60.0 + second / 3600.0
        as_hours(hours)
      end

      def as_dms(degree, minute, second)
        sign = degree.negative? ? -1 : 1
        degrees = degree.abs + minute / 60.0 + second / 3600.0
        as_degrees(sign * degrees)
      end
    end

    def radians
      @angle
    end

    def degrees
      @angle * BigDecimal("180") / PI
    end

    def hours
      @angle / (PI / BigDecimal("12"))
    end

    def initialize(angle)
      @angle = if angle.is_a?(Integer) || angle.is_a?(BigDecimal)
        BigDecimal(angle)
      else
        BigDecimal(angle, PRECISION)
      end
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
      decimal_minutes = BigDecimal("60") * (absolute_degrees - degrees)
      absolute_decimal_minutes = (
        BigDecimal("60") * (absolute_degrees - degrees)
      ).abs
      minutes = decimal_minutes.floor
      seconds = BigDecimal("60") * (
        absolute_decimal_minutes - absolute_decimal_minutes.floor
      )

      Dms.new(sign, degrees, minutes, seconds.to_f.floor(4))
    end

    def to_hms(hrs)
      absolute_hours = hrs.abs
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
