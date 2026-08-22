# frozen_string_literal: true

require "iers"

module Astronoby
  module DeltaT
    class << self
      # @param instant [Numeric, Time, Date, DateTime] a Julian Date, or a date
      #   and time. Any time scale will do.
      # @return [Numeric] ΔT in seconds
      # @raise [Astronoby::IncompatibleArgumentsError] if the instant is not a
      #   Numeric, Time, Date or DateTime
      def at(instant)
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
        outside_available_range(e)
      end

      private

      def outside_available_range(error)
        return 0 unless error.available_range

        IERS::DeltaT.at(mjd: error.available_range.end).delta_t
      end
    end
  end
end
