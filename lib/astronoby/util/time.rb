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

        unless hour.between?(0, 24)
          raise IncompatibleArgumentsError, "Hour must be between 0 and 24, got #{hour}"
        end

        decimal_minute = 60 * (absolute_hour - hour)
        absolute_decimal_minute = (60 * (absolute_hour - hour)).abs
        minute = decimal_minute.floor
        second = 60 * (absolute_decimal_minute - absolute_decimal_minute.floor)

        ::Time.utc(date.year, date.month, date.day, hour, minute, second).round
      end

      # @param instant [Numeric, Time, Date, DateTime]
      # @return [Integer, Float] Number of leap seconds for the given instant
      def self.leap_seconds_for(instant)
        # Ref: IERS Rapid Service / Prediction Center

        jd = case instant
        when Numeric
          instant
        when ::Time, ::Date, ::DateTime
          Epoch.from_time(instant)
        else
          raise IncompatibleArgumentsError,
            "Expected a Numeric, Time, Date or DateTime object, got #{instant.class}"
        end

        return 37 if jd >= 2457754.5
        return 36 if jd >= 2457204.5
        return 35 if jd >= 2456109.5
        return 34 if jd >= 2454832.5
        return 33 if jd >= 2453736.5
        return 32 if jd >= 2451179.5
        return 31 if jd >= 2450630.5
        return 30 if jd >= 2450083.5
        return 29 if jd >= 2449534.5
        return 28 if jd >= 2449169.5
        return 27 if jd >= 2448804.5
        return 26 if jd >= 2448257.5
        return 25 if jd >= 2447892.5
        return 24 if jd >= 2447161.5
        return 23 if jd >= 2446247.5
        return 22 if jd >= 2445516.5
        return 21 if jd >= 2445151.5
        return 20 if jd >= 2444786.5
        return 19 if jd >= 2444239.5
        return 18 if jd >= 2443874.5
        return 17 if jd >= 2443509.5
        return 16 if jd >= 2443144.5
        return 15 if jd >= 2442778.5
        return 14 if jd >= 2442413.5
        return 13 if jd >= 2442048.5
        return 12 if jd >= 2441683.5
        return 11 if jd >= 2441499.5
        return 10 if jd >= 2441317.5
        return 4.21317 + (jd - 2439126.5) * 0.002592 if jd >= 2439887.5
        return 4.31317 + (jd - 2439126.5) * 0.002592 if jd >= 2439126.5
        return 3.84013 + (jd - 2438761.5) * 0.001296 if jd >= 2439004.5
        return 3.74013 + (jd - 2438761.5) * 0.001296 if jd >= 2438942.5
        return 3.64013 + (jd - 2438761.5) * 0.001296 if jd >= 2438820.5
        return 3.54013 + (jd - 2438761.5) * 0.001296 if jd >= 2438761.5
        return 3.44013 + (jd - 2438761.5) * 0.001296 if jd >= 2438639.5
        return 3.34013 + (jd - 2438761.5) * 0.001296 if jd >= 2438486.5
        return 3.24013 + (jd - 2438761.5) * 0.001296 if jd >= 2438395.5
        return 1.945858 + (jd - 2437665.5) * 0.0011232 if jd >= 2438334.5
        return 1.845858 + (jd - 2437665.5) * 0.0011232 if jd >= 2437665.5
        return 1.372818 + (jd - 2437300.5) * 0.001296 if jd >= 2437512.5
        return 1.422818 + (jd - 2437300.5) * 0.001296 if jd >= 2437300.5

        0.0
      end
    end
  end
end
