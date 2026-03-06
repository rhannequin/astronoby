# frozen_string_literal: true

module Astronoby
  # Base class for sidereal time representations. Sidereal time measures the
  # rotation of the Earth relative to the vernal equinox.
  class SiderealTime
    TYPES = [
      MEAN = :mean,
      APPARENT = :apparent
    ].freeze

    # @return [Date] the calendar date
    attr_reader :date

    # @return [Numeric] the sidereal time in hours
    attr_reader :time

    # @return [Symbol] :mean or :apparent
    attr_reader :type

    # Normalizes a time value to the range [0, 24) hours.
    #
    # @param time [Numeric] time in hours
    # @return [Numeric] normalized time in hours
    def self.normalize_time(time)
      time += Constants::HOURS_PER_DAY if time.negative?
      time -= Constants::HOURS_PER_DAY if time > Constants::HOURS_PER_DAY
      time
    end

    # @param type [Symbol] :mean or :apparent
    # @raise [ArgumentError] if type is invalid
    def self.validate_type!(type)
      unless TYPES.include?(type)
        raise ArgumentError, "Invalid type: #{type}. Must be one of #{TYPES}"
      end
    end

    # @param date [Date] the calendar date
    # @param time [Numeric] the sidereal time in hours
    # @param type [Symbol] :mean or :apparent
    def initialize(date:, time:, type: MEAN)
      @date = date
      @time = time
      @type = type
    end

    # @return [Boolean] true if this is mean sidereal time
    def mean?
      @type == MEAN
    end

    # @return [Boolean] true if this is apparent sidereal time
    def apparent?
      @type == APPARENT
    end

    # @param time [Numeric] time in hours
    # @return [Numeric] normalized time in hours
    def normalize_time(time)
      self.class.normalize_time(time)
    end
  end
end
