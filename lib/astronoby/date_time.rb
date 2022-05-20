# frozen_string_literal: true

require "date"

module Astronoby
  class DateTime
    attr_reader :year, :month, :day, :hour, :min, :sec

    def initialize(year, month, day, hour = nil, min = nil, sec = nil)
      @year = year
      @month = month
      @day = day
      @hour = hour
      @min = min
      @sec = sec

      if year.nil? || month.nil? || day.nil?
        raise IncompatibleArgumentsError, "A full date with year, month and day must be provided."
      end

      if date_time? && (@min.nil? || @sec.nil?)
        raise IncompatibleArgumentsError, "When a time is specified, min and sec arguments must be provided."
      end
    end

    def date?
      @hour.nil?
    end

    def date_time?
      !date?
    end

    def julian_day
      julian_day_number + time_of_day
    end

    private

    def julian_day_number
      if @month > 2
        m = @month
        y = @year
      else
        m = @month + 12
        y = @year - 1
      end

      if @year > 1582 || (@year == 1582 && @month > 10) || (@year == 1582 && @month == 10 && @day >= 15)
        a = y / 100
        b = 2 - a + a / 4
      else
        b = 0
      end

      (365.25 * (y + 4716)).floor + (30.6001 * (m + 1)).floor + @day + b - 1524.5
    end

    def time_of_day
      return 0 unless date_time?

      @hour / 24.0 + @min / 1440.0 + @sec / 86400.0
    end
  end
end
