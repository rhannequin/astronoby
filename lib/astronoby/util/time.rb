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

        def local_sidereal_time(time:, longitude:)
          universal_time = time.utc
          greenwich_sidereal_time = ut_to_gmst(universal_time)

          adjustment = longitude / 15.0
          greenwich_sidereal_time + adjustment
        end
      end
    end
  end
end
