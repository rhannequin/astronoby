# frozen_string_literal: true

require "iers"

module Astronoby
  module Util
    module Time
      # @param date [Date]
      # @param decimal [Numeric] Hour of the day, in decimal hours
      # @return [::Time] Date and time
      def self.decimal_hour_to_time(date, utc_offset, decimal)
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

        date_in_local_time = ::Time
          .utc(date.year, date.month, date.day, hour, minute, second)
          .getlocal(utc_offset)
          .to_date

        if date_in_local_time < date
          date = date.next_day
        elsif date_in_local_time > date
          date = date.prev_day
        end

        ::Time.utc(date.year, date.month, date.day, hour, minute, second).round
      end

      # @param instant [Numeric, Time, Date, DateTime]
      # @return [Numeric] Delta T (TT - UT1) in seconds for the given instant
      def self.terrestrial_universal_time_delta(instant)
        case instant
        when Numeric
          IERS::DeltaT.at(jd: instant).delta_t
        when ::Time, ::Date, ::DateTime
          IERS::DeltaT.at(instant).delta_t
        else
          raise IncompatibleArgumentsError,
            "Expected a Numeric, Time, Date or DateTime object, got #{instant.class}"
        end
      rescue IERS::OutOfRangeError => e
        if e.available_range
          IERS::DeltaT.at(mjd: e.available_range.end).delta_t
        else
          0
        end
      end
    end
  end
end
