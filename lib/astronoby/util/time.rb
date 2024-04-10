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
    end
  end
end
