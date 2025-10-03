# frozen_string_literal: true

module Astronoby
  class AngularVelocity
    include Comparable

    class << self
      def zero
        new(0)
      end

      def from_radians_per_second(radians_per_second)
        new(radians_per_second)
      end

      def from_milliarcseconds_per_year(mas_per_year)
        angle = Angle.from_degree_arcseconds(mas_per_year / 1000.0)
        radians_per_second = angle.radians / Constants::SECONDS_PER_JULIAN_YEAR
        new(radians_per_second)
      end
    end

    attr_reader :radians_per_second
    alias_method :rps, :radians_per_second

    def initialize(radians_per_second)
      @radians_per_second = radians_per_second
      freeze
    end

    def milliarcseconds_per_year
      angle = Angle.from_radians(@radians_per_second)
      angle.degree_milliarcseconds * Constants::SECONDS_PER_JULIAN_YEAR
    end
    alias_method :mas_per_year, :milliarcseconds_per_year

    def +(other)
      self.class.from_radians_per_second(
        @radians_per_second + other.radians_per_second
      )
    end

    def -(other)
      self.class.from_radians_per_second(
        @radians_per_second - other.radians_per_second
      )
    end

    def -@
      self.class.from_radians_per_second(-@radians_per_second)
    end

    def positive?
      @radians_per_second > 0
    end

    def negative?
      @radians_per_second < 0
    end

    def zero?
      @radians_per_second.zero?
    end

    def hash
      [@radians_per_second, self.class].hash
    end

    def <=>(other)
      return unless other.is_a?(self.class)

      @radians_per_second <=> other.radians_per_second
    end
    alias_method :eql?, :==
  end
end
