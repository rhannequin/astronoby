# frozen_string_literal: true

module Astronoby
  class GreenwichSiderealTime
    JULIAN_CENTURIES_EXPONENTS = [
      6.697374558,
      2400.051336,
      0.000025862
    ].freeze

    attr_reader :date, :time

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 12 - Conversion of UT to Greenwich sidereal time (GST)
    def self.from_utc(utc)
      date = utc.to_date
      julian_day = utc.to_date.ajd
      t = (julian_day - Epoch::J2000) / Epoch::DAYS_PER_JULIAN_CENTURY
      t0 = (
        (JULIAN_CENTURIES_EXPONENTS[0] +
          (JULIAN_CENTURIES_EXPONENTS[1] * t) +
          (JULIAN_CENTURIES_EXPONENTS[2] * t * t)) % 24
      ).abs

      ut_in_hours = utc.hour +
        utc.min / 60.0 +
        (utc.sec + utc.subsec) / 3600.0

      gmst = 1.002737909 * ut_in_hours + t0
      gmst += 24 if gmst.negative?
      gmst -= 24 if gmst > 24

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
      t = (julian_day - Epoch::J2000) / Epoch::DAYS_PER_JULIAN_CENTURY

      t0 = (
        (JULIAN_CENTURIES_EXPONENTS[0] +
          (JULIAN_CENTURIES_EXPONENTS[1] * t) +
          (JULIAN_CENTURIES_EXPONENTS[2] * t * t)) % 24
      ).abs

      a = @time - t0
      a += 24 if a.negative?
      a -= 24 if a > 24

      utc = 0.9972695663 * a

      Util::Time.decimal_hour_to_time(date, utc)
    end

    def to_lst(longitude:)
      LocalSiderealTime.from_gst(gst: self, longitude: longitude)
    end
  end
end
