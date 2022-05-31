# frozen_string_literal: true

require "date"
require "bigdecimal"

module Astronoby
  class DateTime
    attr_reader :year, :month, :day, :hour, :min, :sec

    def initialize(year, month, day, hour = 0, min = 0, sec = 0)
      @year = year
      @month = month
      @day = day
      @hour = hour
      @min = min
      @sec = sec
    end

    class << self
      def from_julian_day(julian_day)
        jd = julian_day + 0.5
        i = jd.to_i
        f = (jd - i).round(4)

        if i > 2_299_160
          a = ((i - 1_867_216.25) / 36_524.25).to_i
          b = i + 1 + a - (a / 4).to_i
        else
          b = i
        end

        c = b + 1524
        d = ((c - 122.1) / 365.25).to_i
        e = (365.25 * d).to_i
        g = ((c - e) / 30.6001).to_i

        hour = BigDecimal(f, 4) * 24
        min = (hour - hour.to_i) * 60
        sec = (min - min.to_i) * 60
        day = c - e + f - (30.6001 * g).to_i
        month = g < 13.5 ? g - 1 : g - 13
        year = month > 2.5 ? d - 4716 : d - 4715

        new(year, month, day.to_i, hour.to_i, min.to_i, sec.to_i)
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
