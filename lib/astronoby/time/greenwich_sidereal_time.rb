# frozen_string_literal: true

module Astronoby
  class GreenwichSiderealTime
    JULIAN_CENTURIES_EXPONENTS = [
      6.697374558,
      2400.051336,
      0.000025862
    ].freeze

    SIDEREAL_MINUTE_IN_UT_MINUTE = 0.9972695663

    attr_reader :date, :time

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 12 - Conversion of UT to Greenwich sidereal time (GST)
    def self.from_utc(utc)
      date = utc.to_date
      julian_day = utc.to_date.ajd
      t = (julian_day - JulianDate::J2000) / Constants::DAYS_PER_JULIAN_CENTURY
      t0 = (
        (JULIAN_CENTURIES_EXPONENTS[0] +
          (JULIAN_CENTURIES_EXPONENTS[1] * t) +
          (JULIAN_CENTURIES_EXPONENTS[2] * t * t)) % Constants::HOURS_PER_DAY
      ).abs

      ut_in_hours = utc.hour +
        utc.min / Constants::MINUTES_PER_HOUR +
        (utc.sec + utc.subsec) / Constants::SECONDS_PER_HOUR

      gmst = 1.002737909 * ut_in_hours + t0
      gmst += Constants::HOURS_PER_DAY if gmst.negative?
      gmst -= Constants::HOURS_PER_DAY if gmst > Constants::HOURS_PER_DAY

      new(date: date, time: gmst)
    end

    def initialize(date:, time:)
      @date = date
      @time = time
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 13 - Conversion of GST to UT
    def to_utc
      date = @date
      julian_day = @date.ajd
      t = (julian_day - JulianDate::J2000) / Constants::DAYS_PER_JULIAN_CENTURY

      t0 = (
        (JULIAN_CENTURIES_EXPONENTS[0] +
          (JULIAN_CENTURIES_EXPONENTS[1] * t) +
          (JULIAN_CENTURIES_EXPONENTS[2] * t * t)) % Constants::HOURS_PER_DAY
      ).abs

      a = @time - t0
      a += Constants::HOURS_PER_DAY if a.negative?
      a -= Constants::HOURS_PER_DAY if a > Constants::HOURS_PER_DAY

      utc = SIDEREAL_MINUTE_IN_UT_MINUTE * a

      Util::Time.decimal_hour_to_time(date, 0, utc)
    end

    def to_lst(longitude:)
      LocalSiderealTime.from_gst(gst: self, longitude: longitude)
    end
  end
end
