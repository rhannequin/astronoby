# frozen_string_literal: true

module Astronoby
  class Velocity
    include Comparable

    class << self
      def zero
        new(0)
      end

      def from_meters_per_second(meters_per_second)
        new(meters_per_second)
      end
      alias_method :from_mps, :from_meters_per_second

      def from_kilometers_per_second(kilometers_per_second)
        meters_per_second = kilometers_per_second *
          Constants::KILOMETER_IN_METERS
        from_meters_per_second(meters_per_second)
      end
      alias_method :from_kmps, :from_kilometers_per_second

      def from_kilometers_per_day(kilometers_per_day)
        meters_per_second = kilometers_per_day *
          Constants::KILOMETER_IN_METERS / Constants::SECONDS_PER_DAY
        from_meters_per_second(meters_per_second)
      end
      alias_method :from_kmpd, :from_kilometers_per_day

      def from_astronomical_units_per_day(astronomical_units_per_day)
        meters_per_second = astronomical_units_per_day *
          Constants::ASTRONOMICAL_UNIT_IN_METERS / Constants::SECONDS_PER_DAY
        from_meters_per_second(meters_per_second)
      end
      alias_method :from_aupd, :from_astronomical_units_per_day

      def vector_from_meters_per_second(array)
        Vector.elements(array.map { from_mps(_1) })
      end
      alias_method :vector_from_mps, :vector_from_meters_per_second

      def vector_from_astronomical_units_per_day(array)
        Vector.elements(array.map { from_aupd(_1) })
      end
      alias_method :vector_from_aupd, :vector_from_astronomical_units_per_day

      def light_speed
        from_meters_per_second(Constants::LIGHT_SPEED_M_PER_S)
      end
    end

    attr_reader :meters_per_second
    alias_method :mps, :meters_per_second

    def initialize(meters_per_second)
      @meters_per_second = meters_per_second
      freeze
    end

    def kilometers_per_second
      @meters_per_second / Constants::KILOMETER_IN_METERS.to_f
    end
    alias_method :kmps, :kilometers_per_second

    def kilometers_per_day
      @meters_per_second * Constants::SECONDS_PER_DAY /
        Constants::KILOMETER_IN_METERS
    end
    alias_method :kmpd, :kilometers_per_day

    def astronomical_units_per_day
      @meters_per_second * Constants::SECONDS_PER_DAY /
        Constants::ASTRONOMICAL_UNIT_IN_METERS
    end
    alias_method :aupd, :astronomical_units_per_day

    def +(other)
      self.class.from_meters_per_second(
        @meters_per_second + other.meters_per_second
      )
    end

    def -(other)
      self.class.from_meters_per_second(
        @meters_per_second - other.meters_per_second
      )
    end

    def -@
      self.class.from_meters_per_second(-@meters_per_second)
    end

    def positive?
      @meters_per_second > 0
    end

    def negative?
      @meters_per_second < 0
    end

    def zero?
      @meters_per_second.zero?
    end

    def abs2
      @meters_per_second**2
    end

    def hash
      [@meters_per_second, self.class].hash
    end

    def <=>(other)
      return unless other.is_a?(self.class)

      meters_per_second <=> other.meters_per_second
    end
    alias_method :eql?, :==
  end
end
