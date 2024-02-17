# frozen_string_literal: true

module Astronoby
  class Epoch
    B1900 = 2415020.3135
    J1900 = 2415020.0
    B1950 = 2433282.4235
    J1950 = 2433282.5
    J2000 = 2451545.0

    DEFAULT_EPOCH = J2000
    DAYS_PER_JULIAN_CENTURY = 36525.0

    JULIAN_DAY_NUMBER_OFFSET = 0.5

    def self.from_time(time)
      time.to_datetime.ajd
    end

    def self.to_utc(epoch)
      DateTime.jd(epoch + JULIAN_DAY_NUMBER_OFFSET).to_time.utc
    end
  end
end
