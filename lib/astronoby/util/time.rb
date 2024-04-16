# frozen_string_literal: true

module Astronoby
  module Util
    module Time
      # @param date [Date]
      # @param decimal [Numeric] Hour of the day, in decimal hours
      # @return [::Time] Date and time
      def self.decimal_hour_to_time(date, decimal)
        absolute_hour = decimal.abs
        hour = absolute_hour.floor

        unless hour.between?(0, Constants::HOURS_PER_DAY)
          raise(
            IncompatibleArgumentsError,
            "Hour must be between 0 and #{Constants::HOURS_PER_DAY.to_i}, got #{hour}"
          )
        end

        decimal_minute = Constants::MINUTES_PER_HOUR * (absolute_hour - hour)
        absolute_decimal_minute = (
          Constants::MINUTES_PER_HOUR * (absolute_hour - hour)
        ).abs
        minute = decimal_minute.floor
        second = Constants::SECONDS_PER_MINUTE *
          (absolute_decimal_minute - absolute_decimal_minute.floor)

        ::Time.utc(date.year, date.month, date.day, hour, minute, second).round
      end

      # @param instant [Numeric, Time, Date, DateTime]
      # @return [Integer, Float] Number of leap seconds for the given instant
      def self.terrestrial_universal_time_delta(instant)
        # Source:
        #  Title: Astronomical Algorithms
        #  Author: Jean Meeus
        #  Edition: 2nd edition
        #  Chapter: 10 - Dynamical Time and Universal Time

        jd = case instant
        when Numeric
          instant
        when ::Time, ::Date, ::DateTime
          Epoch.from_time(instant)
        else
          raise IncompatibleArgumentsError,
            "Expected a Numeric, Time, Date or DateTime object, got #{instant.class}"
        end

        return 69 if jd >= 2457754.5
        return 68 if jd >= 2457204.5
        return 67 if jd >= 2456109.5
        return 66 if jd >= 2454832.5
        return 65 if jd >= 2453736.5
        return 64 if jd >= 2451179.5
        return 63 if jd >= 2450814.5

        theta = ((jd - Epoch::J1900) / 365.25) / 100.0
        if (2415020.5...2450814.5).cover?(jd) # 1900 - 1997
          return -2.44 +
              87.24 * theta +
              815.20 * theta**2 -
              2_637.80 * theta**3 -
              18_756.33 * theta**4 +
              124_906.15 * theta**5 -
              303_191.19 * theta**6 +
              372_919.88 * theta**7 -
              232_424.66 * theta**8 +
              58_353.42 * theta**9
        elsif (2378496.5...2415020.5).cover?(jd) # 1800 - 1899
          return -2.5 +
              228.95 * theta +
              5_218.61 * theta**2 +
              56_282.84 * theta**3 +
              324_011.78 * theta**4 +
              1_061_660.75 * theta**5 +
              2_087_298.89 * theta**6 +
              2_513_807.78 * theta**7 +
              1_818_961.41 * theta**8 +
              727_058.63 * theta**9 +
              123_563.95 * theta**10
        end

        0.0
      end
    end
  end
end
