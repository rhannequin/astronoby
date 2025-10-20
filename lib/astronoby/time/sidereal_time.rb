# frozen_string_literal: true

module Astronoby
  class SiderealTime
    TYPES = [
      MEAN = :mean,
      APPARENT = :apparent
    ].freeze

    attr_reader :date, :time, :type

    def self.normalize_time(time)
      time += Constants::HOURS_PER_DAY if time.negative?
      time -= Constants::HOURS_PER_DAY if time > Constants::HOURS_PER_DAY
      time
    end

    def self.validate_type!(type)
      unless TYPES.include?(type)
        raise ArgumentError, "Invalid type: #{type}. Must be one of #{TYPES}"
      end
    end

    def initialize(date:, time:, type: MEAN)
      @date = date
      @time = time
      @type = type
    end

    def mean?
      @type == MEAN
    end

    def apparent?
      @type == APPARENT
    end

    def normalize_time(time)
      self.class.normalize_time(time)
    end
  end
end
