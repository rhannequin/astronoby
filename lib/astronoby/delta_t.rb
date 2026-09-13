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
      rescue IERS::OutOfRangeError => error
        outside_available_range(error)
      end

      private

      # IERS covers 1800 up to the end of its EOP series, and refuses anything
      # outside. Rather than propagate that, we answer with the closest value
      # we have: 0 before 1800, where ΔT is small next to the uncertainty on
      # it, and the last measured value after the series, which drifts slowly
      # enough to beat any extrapolation we could invent.
      def outside_available_range(error)
        last_measured = IERS::Data.finals_entries.last
        return 0 if last_measured.nil?
        return 0 if error.requested_mjd.nil?
        return 0 if error.requested_mjd < last_measured.mjd

        IERS::DeltaT.at(mjd: last_measured.mjd).delta_t
      end
    end
  end
end
