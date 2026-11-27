# frozen_string_literal: true

require "iers"

module Astronoby
  # TAI - UTC, the seconds International Atomic Time is ahead of UTC, as IERS
  # Bulletin C publishes it.
  #
  # @api private
  module LeapSeconds
    MODIFIED_JULIAN_DATE_OFFSET = Rational("2400000.5")
    private_constant :MODIFIED_JULIAN_DATE_OFFSET

    class << self
      # @param utc_julian_date [Numeric] the Julian Date in UTC
      # @return [Integer, Rational] TAI - UTC in seconds, a whole number from
      #   1972 and a fraction while UTC drifted, from 1961 to 1972
      # @raise [IERS::OutOfRangeError] before 1961, when UTC did not run yet
      def at(utc_julian_date)
        IERS::LeapSecond.at(mjd: utc_julian_date - MODIFIED_JULIAN_DATE_OFFSET)
      end
    end
  end
end
