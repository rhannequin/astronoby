# frozen_string_literal: true

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
    end
  end
end
