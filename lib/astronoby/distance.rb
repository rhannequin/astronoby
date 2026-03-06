# frozen_string_literal: true

module Astronoby
  # Represents a distance with meters as its internal representation.
  # Provides conversions between meters, kilometers, astronomical units,
  # and parsecs.
  #
  # @example Create a distance from astronomical units
  #   distance = Astronoby::Distance.from_au(1.0)
  #   distance.km  # => 149597870.7
  #
  class Distance
    include Comparable

    class << self
      # @return [Astronoby::Distance] a zero distance
      def zero
        new(0)
      end

      # @param meters [Numeric] the distance in meters
      # @return [Astronoby::Distance] a new Distance
      def from_meters(meters)
        new(meters)
      end
      alias_method :from_m, :from_meters

      # @param kilometers [Numeric] the distance in kilometers
      # @return [Astronoby::Distance] a new Distance
      def from_kilometers(kilometers)
        meters = kilometers * Constants::KILOMETER_IN_METERS
        from_meters(meters)
      end
      alias_method :from_km, :from_kilometers

      # @param astronomical_units [Numeric] the distance in AU
      # @return [Astronoby::Distance] a new Distance
      def from_astronomical_units(astronomical_units)
        meters = astronomical_units * Constants::ASTRONOMICAL_UNIT_IN_METERS
        from_meters(meters)
      end
      alias_method :from_au, :from_astronomical_units

      # @param parsecs [Numeric] the distance in parsecs
      # @return [Astronoby::Distance] a new Distance
      def from_parsecs(parsecs)
        meters = parsecs * Constants::PARSEC_IN_METERS
        from_meters(meters)
      end
      alias_method :from_pc, :from_parsecs

      # @param array [Array<Numeric>] array of meter values
      # @return [Astronoby::Vector<Astronoby::Distance>] a vector of Distances
      def vector_from_meters(array)
        Vector.elements(array.map { from_meters(_1) })
      end
      alias_method :vector_from_m, :vector_from_meters
    end

    # @return [Numeric] the distance in meters
    attr_reader :meters
    alias_method :m, :meters

    # @param meters [Numeric] the distance in meters
    def initialize(meters)
      @meters = meters
      freeze
    end

    # @return [Float] the distance in kilometers
    def kilometers
      @meters / Constants::KILOMETER_IN_METERS.to_f
    end
    alias_method :km, :kilometers

    # @return [Float] the distance in astronomical units
    def astronomical_units
      @meters / Constants::ASTRONOMICAL_UNIT_IN_METERS.to_f
    end
    alias_method :au, :astronomical_units

    # @param other [Astronoby::Distance] distance to add
    # @return [Astronoby::Distance] the sum
    def +(other)
      self.class.from_meters(meters + other.meters)
    end

    # @param other [Astronoby::Distance] distance to subtract
    # @return [Astronoby::Distance] the difference
    def -(other)
      self.class.from_meters(@meters - other.meters)
    end

    # @return [Astronoby::Distance] the negated distance
    def -@
      self.class.from_meters(-@meters)
    end

    # @return [Boolean] true if the distance is positive
    def positive?
      meters > 0
    end

    # @return [Boolean] true if the distance is negative
    def negative?
      meters < 0
    end

    # @return [Boolean] true if the distance is zero
    def zero?
      meters.zero?
    end

    # @return [Numeric] the square of the distance in meters
    def abs2
      meters**2
    end

    # @return [Integer] hash value
    def hash
      [meters, self.class].hash
    end

    # @param other [Astronoby::Distance] distance to compare with
    # @return [Integer, nil] -1, 0, or 1; nil if not comparable
    def <=>(other)
      return unless other.is_a?(self.class)

      meters <=> other.meters
    end
    alias_method :eql?, :==
  end
end
