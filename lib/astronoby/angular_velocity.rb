# frozen_string_literal: true

module Astronoby
  # Represents an angular velocity with radians per second as its internal
  # representation. Used primarily for stellar proper motion.
  class AngularVelocity
    include Comparable

    class << self
      # @return [Astronoby::AngularVelocity] a zero angular velocity
      def zero
        new(0)
      end

      # @param radians_per_second [Numeric] the angular velocity in rad/s
      # @return [Astronoby::AngularVelocity] a new AngularVelocity
      def from_radians_per_second(radians_per_second)
        new(radians_per_second)
      end

      # @param mas_per_year [Numeric] the angular velocity in mas/yr
      # @return [Astronoby::AngularVelocity] a new AngularVelocity
      def from_milliarcseconds_per_year(mas_per_year)
        angle = Angle.from_degree_arcseconds(mas_per_year / 1000.0)
        radians_per_second = angle.radians / Constants::SECONDS_PER_JULIAN_YEAR
        new(radians_per_second)
      end
    end

    # @return [Numeric] the angular velocity in radians per second
    attr_reader :radians_per_second
    alias_method :rps, :radians_per_second

    # @param radians_per_second [Numeric] the angular velocity in rad/s
    def initialize(radians_per_second)
      @radians_per_second = radians_per_second
      freeze
    end

    # @return [Float] the angular velocity in milliarcseconds per year
    def milliarcseconds_per_year
      angle = Angle.from_radians(@radians_per_second)
      angle.degree_milliarcseconds * Constants::SECONDS_PER_JULIAN_YEAR
    end
    alias_method :mas_per_year, :milliarcseconds_per_year

    # @param other [Astronoby::AngularVelocity] angular velocity to add
    # @return [Astronoby::AngularVelocity] the sum
    def +(other)
      self.class.from_radians_per_second(
        @radians_per_second + other.radians_per_second
      )
    end

    # @param other [Astronoby::AngularVelocity] angular velocity to subtract
    # @return [Astronoby::AngularVelocity] the difference
    def -(other)
      self.class.from_radians_per_second(
        @radians_per_second - other.radians_per_second
      )
    end

    # @return [Astronoby::AngularVelocity] the negated angular velocity
    def -@
      self.class.from_radians_per_second(-@radians_per_second)
    end

    # @return [Boolean] true if the angular velocity is positive
    def positive?
      @radians_per_second > 0
    end

    # @return [Boolean] true if the angular velocity is negative
    def negative?
      @radians_per_second < 0
    end

    # @return [Boolean] true if the angular velocity is zero
    def zero?
      @radians_per_second.zero?
    end

    # @return [Integer] hash value
    def hash
      [@radians_per_second, self.class].hash
    end

    # @param other [Astronoby::AngularVelocity] angular velocity to compare with
    # @return [Integer, nil] -1, 0, or 1; nil if not comparable
    def <=>(other)
      return unless other.is_a?(self.class)

      @radians_per_second <=> other.radians_per_second
    end
    alias_method :eql?, :==
  end
end
