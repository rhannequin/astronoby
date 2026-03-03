# frozen_string_literal: true

module Astronoby
  # Represents an angle with radians as its internal representation.
  # Provides conversions between radians, degrees, hours, and sexagesimal
  # formats (DMS and HMS), as well as trigonometric operations.
  #
  # @example Create an angle from degrees
  #   angle = Astronoby::Angle.from_degrees(180)
  #   angle.radians  # => Math::PI
  #
  # @example Create an angle from hours, minutes, seconds
  #   angle = Astronoby::Angle.from_hms(12, 30, 0)
  #
  class Angle
    include Comparable

    MIN_PRECISION = 10
    FORMATS = %i[dms hms].freeze

    class << self
      # @return [Astronoby::Angle] a zero angle
      def zero
        new(0)
      end

      # @param radians [Numeric] the angle in radians
      # @return [Astronoby::Angle] a new Angle, normalized to (-2π, 2π)
      def from_radians(radians)
        normalized_radians = radians.remainder(Constants::RADIANS_PER_CIRCLE)
        new(normalized_radians)
      end

      # @param degrees [Numeric] the angle in degrees
      # @return [Astronoby::Angle] a new Angle
      def from_degrees(degrees)
        radians = degrees / Constants::PI_IN_DEGREES * Math::PI
        from_radians(radians)
      end

      # @param arcseconds [Numeric] the angle in arcseconds
      # @return [Astronoby::Angle] a new Angle
      def from_degree_arcseconds(arcseconds)
        from_dms(0, 0, arcseconds)
      end

      # @param hours [Numeric] the angle in hour-angle hours
      # @return [Astronoby::Angle] a new Angle
      def from_hours(hours)
        radians = hours * Constants::RADIAN_PER_HOUR
        from_radians(radians)
      end

      # @param hour [Numeric] hours component
      # @param minute [Numeric] minutes component
      # @param second [Numeric] seconds component
      # @return [Astronoby::Angle] a new Angle
      def from_hms(hour, minute, second)
        hours = hour +
          minute / Constants::MINUTES_PER_HOUR +
          second / Constants::SECONDS_PER_HOUR
        from_hours(hours)
      end

      # @param degree [Numeric] degrees component (sign determines overall sign)
      # @param minute [Numeric] arcminutes component
      # @param second [Numeric] arcseconds component
      # @return [Astronoby::Angle] a new Angle
      def from_dms(degree, minute, second)
        sign = degree.negative? ? -1 : 1
        degrees = degree.abs +
          minute / Constants::ARCMINUTES_PER_DEGREE +
          second / Constants::ARCSECONDS_PER_DEGREE
        from_degrees(sign * degrees)
      end

      # @param ratio [Numeric] the sine value (-1..1)
      # @return [Astronoby::Angle] the arcsine
      def asin(ratio)
        radians = Math.asin(ratio)
        from_radians(radians)
      end

      # @param ratio [Numeric] the cosine value (-1..1)
      # @return [Astronoby::Angle] the arccosine
      def acos(ratio)
        radians = Math.acos(ratio)
        from_radians(radians)
      end

      # @param ratio [Numeric] the tangent value
      # @return [Astronoby::Angle] the arctangent
      def atan(ratio)
        radians = Math.atan(ratio)
        from_radians(radians)
      end
    end

    # @return [Numeric] the angle in radians
    attr_reader :radians

    # @param radians [Numeric] the angle in radians
    def initialize(radians)
      @radians = radians
      freeze
    end

    # @return [Float] the angle in degrees
    def degrees
      @radians * Constants::PI_IN_DEGREES / Math::PI
    end

    # @return [Float] the angle in milliarcseconds
    def degree_milliarcseconds
      degrees * Constants::MILLIARCSECONDS_PER_DEGREE
    end

    # @return [Float] the angle in hour-angle hours
    def hours
      @radians / Constants::RADIAN_PER_HOUR
    end

    # @param other [Astronoby::Angle] angle to add
    # @return [Astronoby::Angle] the sum
    def +(other)
      self.class.from_radians(radians + other.radians)
    end

    # @param other [Astronoby::Angle] angle to subtract
    # @return [Astronoby::Angle] the difference
    def -(other)
      self.class.from_radians(@radians - other.radians)
    end

    # @return [Astronoby::Angle] the negated angle
    def -@
      self.class.from_radians(-@radians)
    end

    # @return [Float] the sine of the angle
    def sin
      Math.sin(radians)
    end

    # @return [Float] the cosine of the angle
    def cos
      Math.cos(radians)
    end

    # @return [Float] the tangent of the angle
    def tan
      Math.tan(radians)
    end

    # @return [Boolean] true if the angle is positive
    def positive?
      radians > 0
    end

    # @return [Boolean] true if the angle is negative
    def negative?
      radians < 0
    end

    # @return [Boolean] true if the angle is zero
    def zero?
      radians.zero?
    end

    # @return [Integer] hash value
    def hash
      [radians, self.class].hash
    end

    # @param other [Astronoby::Angle] angle to compare with
    # @return [Integer, nil] -1, 0, or 1; nil if not comparable
    def <=>(other)
      return unless other.is_a?(self.class)

      radians <=> other.radians
    end
    alias_method :eql?, :==

    # Formats the angle as a string in the given format.
    #
    # @param format [Symbol] :dms or :hms
    # @param precision [Integer] decimal places for seconds
    # @return [String] the formatted angle
    # @raise [Astronoby::UnsupportedFormatError] if format is not :dms or :hms
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

    # @return [Astronoby::Dms] the angle in degrees, arcminutes, arcseconds
    def to_dms
      sign = degrees.negative? ? "-" : "+"
      absolute_degrees = degrees.abs
      deg = absolute_degrees.floor
      decimal_minutes = Constants::ARCMINUTES_PER_DEGREE *
        (absolute_degrees - deg)
      absolute_decimal_minutes = (
        Constants::ARCMINUTES_PER_DEGREE * (absolute_degrees - deg)
      ).abs
      minutes = decimal_minutes.floor
      seconds = Constants::SECONDS_PER_MINUTE * (
        absolute_decimal_minutes - absolute_decimal_minutes.floor
      )

      Dms.new(sign, deg, minutes, seconds)
    end

    # @return [Astronoby::Hms] the angle in hours, minutes, seconds
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
