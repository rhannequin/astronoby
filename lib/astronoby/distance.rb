# frozen_string_literal: true

module Astronoby
  class Distance
    include Comparable

    class << self
      def zero
        new(0)
      end

      def from_meters(meters)
        new(meters)
      end
      alias_method :from_m, :from_meters

      def from_kilometers(kilometers)
        meters = kilometers * Constants::KILOMETER_IN_METERS
        from_meters(meters)
      end
      alias_method :from_km, :from_kilometers

      def from_astronomical_units(astronomical_units)
        meters = astronomical_units * Constants::ASTRONOMICAL_UNIT_IN_METERS
        from_meters(meters)
      end
      alias_method :from_au, :from_astronomical_units
    end

    attr_reader :meters
    alias_method :m, :meters

    def initialize(meters)
      @meters = meters
      freeze
    end

    def kilometers
      @meters / Constants::KILOMETER_IN_METERS
    end
    alias_method :km, :kilometers

    def astronomical_units
      @meters / Constants::ASTRONOMICAL_UNIT_IN_METERS
    end
    alias_method :au, :astronomical_units

    def +(other)
      self.class.from_meters(meters + other.meters)
    end

    def -(other)
      self.class.from_meters(@meters - other.meters)
    end

    def -@
      self.class.from_meters(-@meters)
    end

    def positive?
      meters > 0
    end

    def negative?
      meters < 0
    end

    def zero?
      meters.zero?
    end

    def hash
      [meters, self.class].hash
    end

    def <=>(other)
      return unless other.is_a?(self.class)

      meters <=> other.meters
    end
    alias_method :eql?, :==
  end
end
