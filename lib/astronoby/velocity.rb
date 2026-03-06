# frozen_string_literal: true

module Astronoby
  # Represents a velocity with meters per second as its internal
  # representation. Provides conversions between m/s, km/s, km/day,
  # and AU/day.
  #
  # @example Create a velocity from km/s
  #   velocity = Astronoby::Velocity.from_kmps(29.78)
  #   velocity.aupd  # AU per day
  #
  class Velocity
    include Comparable

    class << self
      # @return [Astronoby::Velocity] a zero velocity
      def zero
        new(0)
      end

      # @param meters_per_second [Numeric] the velocity in m/s
      # @return [Astronoby::Velocity] a new Velocity
      def from_meters_per_second(meters_per_second)
        new(meters_per_second)
      end
      alias_method :from_mps, :from_meters_per_second

      # @param kilometers_per_second [Numeric] the velocity in km/s
      # @return [Astronoby::Velocity] a new Velocity
      def from_kilometers_per_second(kilometers_per_second)
        meters_per_second = kilometers_per_second *
          Constants::KILOMETER_IN_METERS
        from_meters_per_second(meters_per_second)
      end
      alias_method :from_kmps, :from_kilometers_per_second

      # @param kilometers_per_day [Numeric] the velocity in km/day
      # @return [Astronoby::Velocity] a new Velocity
      def from_kilometers_per_day(kilometers_per_day)
        meters_per_second = kilometers_per_day *
          Constants::KILOMETER_IN_METERS / Constants::SECONDS_PER_DAY
        from_meters_per_second(meters_per_second)
      end
      alias_method :from_kmpd, :from_kilometers_per_day

      # @param astronomical_units_per_day [Numeric] the velocity in AU/day
      # @return [Astronoby::Velocity] a new Velocity
      def from_astronomical_units_per_day(astronomical_units_per_day)
        meters_per_second = astronomical_units_per_day *
          Constants::ASTRONOMICAL_UNIT_IN_METERS / Constants::SECONDS_PER_DAY
        from_meters_per_second(meters_per_second)
      end
      alias_method :from_aupd, :from_astronomical_units_per_day

      # @param array [Array<Numeric>] array of m/s values
      # @return [Astronoby::Vector<Astronoby::Velocity>] a vector of Velocities
      def vector_from_meters_per_second(array)
        Vector.elements(array.map { from_mps(_1) })
      end
      alias_method :vector_from_mps, :vector_from_meters_per_second

      # @param array [Array<Numeric>] array of AU/day values
      # @return [Astronoby::Vector<Astronoby::Velocity>] a vector of Velocities
      def vector_from_astronomical_units_per_day(array)
        Vector.elements(array.map { from_aupd(_1) })
      end
      alias_method :vector_from_aupd, :vector_from_astronomical_units_per_day

      # @return [Astronoby::Velocity] the speed of light in vacuum
      def light_speed
        from_meters_per_second(Constants::LIGHT_SPEED_M_PER_S)
      end
    end

    # @return [Numeric] the velocity in meters per second
    attr_reader :meters_per_second
    alias_method :mps, :meters_per_second

    # @param meters_per_second [Numeric] the velocity in m/s
    def initialize(meters_per_second)
      @meters_per_second = meters_per_second
      freeze
    end

    # @return [Float] the velocity in kilometers per second
    def kilometers_per_second
      @meters_per_second / Constants::KILOMETER_IN_METERS.to_f
    end
    alias_method :kmps, :kilometers_per_second

    # @return [Float] the velocity in kilometers per day
    def kilometers_per_day
      @meters_per_second * Constants::SECONDS_PER_DAY /
        Constants::KILOMETER_IN_METERS
    end
    alias_method :kmpd, :kilometers_per_day

    # @return [Float] the velocity in astronomical units per day
    def astronomical_units_per_day
      @meters_per_second * Constants::SECONDS_PER_DAY /
        Constants::ASTRONOMICAL_UNIT_IN_METERS
    end
    alias_method :aupd, :astronomical_units_per_day

    # @param other [Astronoby::Velocity] velocity to add
    # @return [Astronoby::Velocity] the sum
    def +(other)
      self.class.from_meters_per_second(
        @meters_per_second + other.meters_per_second
      )
    end

    # @param other [Astronoby::Velocity] velocity to subtract
    # @return [Astronoby::Velocity] the difference
    def -(other)
      self.class.from_meters_per_second(
        @meters_per_second - other.meters_per_second
      )
    end

    # @return [Astronoby::Velocity] the negated velocity
    def -@
      self.class.from_meters_per_second(-@meters_per_second)
    end

    # @return [Boolean] true if the velocity is positive
    def positive?
      @meters_per_second > 0
    end

    # @return [Boolean] true if the velocity is negative
    def negative?
      @meters_per_second < 0
    end

    # @return [Boolean] true if the velocity is zero
    def zero?
      @meters_per_second.zero?
    end

    # @return [Numeric] the square of the velocity in (m/s)^2
    def abs2
      @meters_per_second**2
    end

    # @return [Integer] hash value
    def hash
      [@meters_per_second, self.class].hash
    end

    # @param other [Astronoby::Velocity] velocity to compare with
    # @return [Integer, nil] -1, 0, or 1; nil if not comparable
    def <=>(other)
      return unless other.is_a?(self.class)

      meters_per_second <=> other.meters_per_second
    end
    alias_method :eql?, :==
  end
end
