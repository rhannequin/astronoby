# frozen_string_literal: true

require "iers"

module Astronoby
  class GreenwichMeanSiderealTime < GreenwichSiderealTime
    JULIAN_CENTURIES_EXPONENTS = [
      6.697374558,
      2400.051336,
      0.000025862
    ].freeze

    SIDEREAL_MINUTE_IN_UT_MINUTE = 0.9972695663

    # Source:
    #  Title: IERS Conventions (2010)
    #  Chapter: 5.5.7 - ERA based expressions for Greenwich Sidereal Time
    def self.from_utc(utc)
      date = utc.to_date
      gmst_radians = IERS::GMST.at(utc)
      gmst_hours = gmst_radians * 12.0 / Math::PI
      gmst_hours = normalize_time(gmst_hours)

      new(date: date, time: gmst_hours)
    end

    def initialize(date:, time:)
      super(date: date, time: time, type: MEAN)
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

      a = normalize_time(@time - t0)

      utc = SIDEREAL_MINUTE_IN_UT_MINUTE * a

      Util::Time.decimal_hour_to_time(date, 0, utc)
    end
  end
end
