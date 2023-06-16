# frozen_string_literal: true

module Astronoby
  module Util
    module Time
      class << self
        # Source:
        #  Title: Practical Astronomy with your Calculator or Spreadsheet
        #  Authors: Peter Duffett-Smith and Jonathan Zwart
        #  Edition: Cambridge University Press
        #  Chapter: 12 - Conversion of UT to Greenwich sidereal time (GST)
        def ut_to_gmst(universal_time)
          julian_day = universal_time.to_date.ajd
          t = (julian_day - Astronoby::Epoch::J2000)./(
            Astronoby::Epoch::DAYS_PER_JULIAN_CENTURY
          )

          t0 = (
            (BigDecimal("6.697374558") +
            (BigDecimal("2400.051336") * t) +
            (BigDecimal("0.000025862") * t * t)) % 24
          ).abs

          ut_in_hours = universal_time.hour +
            universal_time.min / 60.0 +
            (universal_time.sec + universal_time.subsec) / 3600.0

          gmst = BigDecimal("1.002737909") * ut_in_hours + t0

          # If gmst negative, add 24 hours to the date
          # If gmst is greater than 24, subtract 24 hours from the date
          gmst += 24 if gmst.negative?
          gmst -= 24 if gmst > 24

          gmst
        end

        def lst_to_ut(date:, longitude:, lst:)
          gmst = lst_to_gmst(lst: lst, longitude: longitude)
          julian_day = date.ajd
          jd0 = ::DateTime.new(date.year, 1, 1, 0, 0, 0).ajd - 1
          days_into_the_year = julian_day - jd0

          t = (jd0 - Astronoby::Epoch::J1900)./(
            Astronoby::Epoch::DAYS_PER_JULIAN_CENTURY
          )
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
          decimal_minute = 60 * (absolute_hour - hour)
          absolute_decimal_minute = (60 * (absolute_hour - hour)).abs
          minute = decimal_minute.floor
          second = (
            60 * (absolute_decimal_minute - absolute_decimal_minute.floor)
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
