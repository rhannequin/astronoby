# frozen_string_literal: true

module Astronoby
  class JulianDate
    BESSELIAN_EPOCH_STARTING_YEAR = 1900
    JULIAN_EPOCH_STARTING_YEAR = 2000

    B1900 = 2415020.3135
    J1950 = 2433282.5
    J2000 = 2451545.0

    DEFAULT_EPOCH = J2000
    JULIAN_DAY_NUMBER_OFFSET = 0.5

    def self.from_time(time)
      time.to_datetime.ajd
    end

    def self.from_julian_year(julian_year)
      J2000 + Constants::DAYS_PER_JULIAN_YEAR *
        (julian_year - JULIAN_EPOCH_STARTING_YEAR)
    end

    def self.from_besselian_year(besselian_year)
      B1900 + Constants::TROPICAL_YEAR_AT_B1900 *
        (besselian_year - BESSELIAN_EPOCH_STARTING_YEAR)
    end

    def self.to_utc(epoch)
      DateTime.jd(epoch + JULIAN_DAY_NUMBER_OFFSET).to_time.utc
    end
  end
end
