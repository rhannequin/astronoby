# frozen_string_literal: true

module Astronoby
  class Angle
    include Comparable

    MIN_PRECISION = 10
    FORMATS = %i[dms hms].freeze

    class << self
      def zero
        new(0)
      end

      def from_radians(radians)
        normalized_radians = radians.remainder(Constants::RADIANS_PER_CIRCLE)
        new(normalized_radians)
      end

      def from_degrees(degrees)
        radians = degrees / Constants::PI_IN_DEGREES * Math::PI
        from_radians(radians)
      end

      def from_degree_arcseconds(arcseconds)
        from_dms(0, 0, arcseconds)
      end

      def from_hours(hours)
        radians = hours * Constants::RADIAN_PER_HOUR
        from_radians(radians)
      end

      def from_hms(hour, minute, second)
        hours = hour +
          minute / Constants::MINUTES_PER_HOUR +
          second / Constants::SECONDS_PER_HOUR
        from_hours(hours)
      end

      def from_dms(degree, minute, second)
        sign = degree.negative? ? -1 : 1
        degrees = degree.abs +
          minute / Constants::MINUTES_PER_HOUR +
          second / Constants::SECONDS_PER_HOUR
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
      @radians = radians
      freeze
    end

    def degrees
      @radians * Constants::PI_IN_DEGREES / Math::PI
    end

    def hours
      @radians / Constants::RADIAN_PER_HOUR
    end

    def +(other)
      self.class.from_radians(radians + other.radians)
    end

    def -(other)
      self.class.from_radians(@radians - other.radians)
    end

    def -@
      self.class.from_radians(-@radians)
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

    def hash
      [radians, self.class].hash
    end

    def <=>(other)
      return unless other.is_a?(self.class)

      radians <=> other.radians
    end
    alias_method :eql?, :==

    def str(format, precision: 4)
      case format
      when :dms then to_dms.format(precision: precision)
      when :hms then to_hms.format(precision: precision)
      else
        raise UnsupportedFormatError.new(
          "Expected a format between #{FORMATS.join(", ")}, got #{format}"
        )
      end
    end

    def to_dms
      sign = degrees.negative? ? "-" : "+"
      absolute_degrees = degrees.abs
      deg = absolute_degrees.floor
      decimal_minutes = Constants::MINUTES_PER_DEGREE *
        (absolute_degrees - deg)
      absolute_decimal_minutes = (
        Constants::MINUTES_PER_DEGREE * (absolute_degrees - deg)
      ).abs
      minutes = decimal_minutes.floor
      seconds = Constants::SECONDS_PER_MINUTE * (
        absolute_decimal_minutes - absolute_decimal_minutes.floor
      )

      Dms.new(sign, deg, minutes, seconds)
    end

    def to_hms
      absolute_hours = hours.abs
      hrs = absolute_hours.floor
      decimal_minutes = Constants::MINUTES_PER_HOUR * (absolute_hours - hrs)
      absolute_decimal_minutes = (
        Constants::MINUTES_PER_HOUR * (absolute_hours - hrs)
      ).abs
      minutes = decimal_minutes.floor
      seconds = Constants::SECONDS_PER_MINUTE * (
        absolute_decimal_minutes - absolute_decimal_minutes.floor
      )

      Hms.new(hrs, minutes, seconds)
    end
  end
end
