# frozen_string_literal: true

module Astronoby
  class Duration
    include Comparable

    class << self
      # @return [Astronoby::Duration] a zero duration
      def zero
        new(0)
      end

      # @param seconds [Numeric] the duration in seconds
      # @return [Astronoby::Duration] a new Duration
      def from_seconds(seconds)
        new(seconds)
      end

      # @param minutes [Numeric] the duration in minutes
      # @return [Astronoby::Duration] a new Duration
      def from_minutes(minutes)
        seconds = minutes * Constants::SECONDS_PER_MINUTE
        from_seconds(seconds)
      end

      # @param hours [Numeric] the duration in hours
      # @return [Astronoby::Duration] a new Duration
      def from_hours(hours)
        seconds = hours * Constants::SECONDS_PER_HOUR
        from_seconds(seconds)
      end

      # @param days [Numeric] the duration in days
      # @return [Astronoby::Duration] a new Duration
      def from_days(days)
        seconds = days * Constants::SECONDS_PER_DAY
        from_seconds(seconds)
      end
    end

    # @return [Numeric] the duration in seconds
    attr_reader :seconds

    # @param seconds [Numeric] the duration in seconds
    def initialize(seconds)
      @seconds = seconds
      freeze
    end

    # @return [Float] the duration in minutes
    def minutes
      @seconds / Constants::SECONDS_PER_MINUTE
    end

    # @return [Float] the duration in hours
    def hours
      @seconds / Constants::SECONDS_PER_HOUR
    end

    # @return [Float] the duration in days
    def days
      @seconds / Constants::SECONDS_PER_DAY
    end

    # @param other [Astronoby::Duration] duration to add
    # @return [Astronoby::Duration] the sum
    def +(other)
      self.class.from_seconds(@seconds + other.seconds)
    end

    # @param other [Astronoby::Duration] duration to subtract
    # @return [Astronoby::Duration] the difference
    def -(other)
      self.class.from_seconds(@seconds - other.seconds)
    end

    # @return [Astronoby::Duration] the negated duration
    def -@
      self.class.from_seconds(-@seconds)
    end

    # @return [Astronoby::Duration] the absolute duration
    def abs
      self.class.from_seconds(@seconds.abs)
    end

    # @return [Boolean] true if the duration is positive
    def positive?
      @seconds > 0
    end

    # @return [Boolean] true if the duration is negative
    def negative?
      @seconds < 0
    end

    # @return [Boolean] true if the duration is zero
    def zero?
      @seconds.zero?
    end

    # @return [Integer] hash value
    def hash
      [@seconds, self.class].hash
    end

    # @param other [Astronoby::Duration] duration to compare with
    # @return [Integer, nil] -1, 0, or 1; nil if not comparable
    def <=>(other)
      return unless other.is_a?(self.class)

      seconds <=> other.seconds
    end
    alias_method :eql?, :==
  end
end
