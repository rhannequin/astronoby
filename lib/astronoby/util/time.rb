# frozen_string_literal: true

module Astronoby
  module Util
    module Time
      class << self
        # Source:
        #  Title: Astronomical Algorithms
        #  Author: Jean Meeus
        #  Edition: 2nd edition
        #  Chapter: 12 - Sidereal Time at Greenwich
        def ut_to_gmst(universal_time)
          julian_day = universal_time.to_date.ajd
          t = (julian_day - BigDecimal("2451545")) / 36525
          t0_in_degrees = (
            BigDecimal("100.46061837") +
            BigDecimal("36000.770053608") * t +
            BigDecimal("0.000387933") * t * t -
            (t * t * t) / 38710000
          ) % 360

          t0_in_seconds = t0_in_degrees * 240
          ut_in_seconds =
            universal_time.hour * 3600 +
            universal_time.min * 60 +
            universal_time.sec

          gmst =
            t0_in_seconds +
            BigDecimal("1.00273790935") * ut_in_seconds

          # If gmst negative, add 24 hours to the date
          # If gmst is greater than 24, subtract 24 hours from the date
          seconds_in_a_day = 24 * 60 * 60
          gmst += seconds_in_a_day if gmst.negative?
          gmst -= seconds_in_a_day if gmst > seconds_in_a_day

          gmst / 3600.0
        end

        def lst_to_ut(date:, longitude:, lst:)
          gmst = lst_to_gmst(lst: lst, longitude: longitude)
          julian_day = date.ajd
          jd0 = ::DateTime.new(date.year, 1, 1, 0, 0, 0).ajd - 1
          days_into_the_year = julian_day - jd0

          t = (jd0 - BigDecimal("2415020")) / BigDecimal("36525")
          r = BigDecimal("6.6460656") +
            BigDecimal("2400.051262") * t +
            BigDecimal("0.00002581") * t * t
          b = 24 - r + 24 * (date.year - 1900)

          # If t0 negative, add 24 hours to the date
          # If t0 is greater than 24, subtract 24 hours from the date
          t0 = BigDecimal("0.0657098") * days_into_the_year - b
          t0 += 24 if t0.negative?

          a = gmst - t0
          a += 24 if a.negative?

          ut = BigDecimal("0.99727") * a

          absolute_hour = ut.abs
          hour = absolute_hour.floor
          decimal_minute = BigDecimal("60") * (absolute_hour - hour)
          absolute_decimal_minute = (
            BigDecimal("60") * (absolute_hour - hour)
          ).abs
          minute = decimal_minute.floor
          second = (
            BigDecimal("60") *
            (absolute_decimal_minute - absolute_decimal_minute.floor)
          ).round

          ::Time.utc(
            date.year,
            date.month,
            date.day,
            hour,
            minute,
            second
          )
        end

        def local_sidereal_time(time:, longitude:)
          ut_to_gmst(time.utc) + longitude.to_hours.value
        end

        def lst_to_gmst(lst:, longitude:)
          gmst = lst - longitude.to_hours.value

          # If gmst negative, add 24 hours to the date
          # If gmst is greater than 24, subtract 24 hours from the date
          gmst += 24 if gmst.negative?
          gmst -= 24 if gmst > 24

          gmst
        end
      end
    end
  end
end
