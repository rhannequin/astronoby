# frozen_string_literal: true

module Astronoby
  # @see https://en.wikipedia.org/wiki/Julian_day
  # @see https://en.wikipedia.org/wiki/Epoch_(astronomy)
  class JulianDate
    # Starting year for Besselian epoch calculations
    # @return [Integer] 1900
    BESSELIAN_EPOCH_STARTING_YEAR = 1900

    # Starting year for Julian epoch calculations
    # @return [Integer] 2000
    JULIAN_EPOCH_STARTING_YEAR = 2000

    # Julian Date for Besselian epoch 1875.0
    # @return [Float] 2405889.258550475
    B1875 = 2405889.258550475

    # Julian Date for Besselian epoch 1900.0
    # @return [Float] 2415020.31352
    B1900 = 2415020.31352

    # Julian Date for Julian epoch 1950.0
    # @return [Float] 2433282.5
    J1950 = 2433282.5

    # Julian Date for Julian epoch 2000.0 (current standard)
    # @return [Float] 2451545.0
    J2000 = 2451545.0

    # Default epoch used by the library
    # @return [Float] 2451545.0
    DEFAULT_EPOCH = J2000

    # Converts a Time object to Julian Date
    #
    # @param time [Time] the time to convert
    # @return [Rational] the Julian Date
    #
    # @example
    #   JulianDate.from_time(Time.utc(2000, 1, 1, 12, 0, 0))
    #   # => 2451545.0
    def self.from_time(time)
      time.to_datetime.ajd
    end

    # Converts a Julian year to Julian Date
    #
    # Uses the formula: JD = J2000 + 365.25 * (year - 2000)
    #
    # @param julian_year [Float] the Julian year
    # @return [Float] the Julian Date
    #
    # @example
    #   JulianDate.from_julian_year(2025.0)
    #   # => 2460676.25
    def self.from_julian_year(julian_year)
      J2000 + Constants::DAYS_PER_JULIAN_YEAR *
        (julian_year - JULIAN_EPOCH_STARTING_YEAR)
    end

    # Converts a Besselian year to Julian Date
    #
    # Uses the formula: JD = B1900 + 365.242198781 * (year - 1900)
    # where 365.242198781 is the tropical year length at B1900.
    #
    # @param besselian_year [Float] the Besselian year
    # @return [Float] the Julian Date
    #
    # @example
    #   JulianDate.from_besselian_year(1875.0)
    #   # => 2405889.258550475
    def self.from_besselian_year(besselian_year)
      B1900 + Constants::TROPICAL_YEAR_AT_B1900 *
        (besselian_year - BESSELIAN_EPOCH_STARTING_YEAR)
    end
  end
end
