# frozen_string_literal: true

module Astronoby
  class Sun < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(695_700_000)

    def self.ephemeris_segments
      [[SOLAR_SYSTEM_BARYCENTER, SUN]]
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 28 - Equation of Time

    # @return [Integer] Equation of time in seconds
    def equation_of_time
      right_ascension = apparent.equatorial.right_ascension
      t = (@instant.julian_date - Epoch::J2000) / Constants::DAYS_PER_JULIAN_MILLENIA
      l0 = (280.4664567 +
        360_007.6982779 * t +
        0.03032028 * t**2 +
        t**3 / 49_931 -
        t**4 / 15_300 -
        t**5 / 2_000_000) % Constants::DEGREES_PER_CIRCLE
      nutation = Nutation.new(instant: instant).nutation_in_longitude
      obliquity = TrueObliquity.for_epoch(@instant.julian_date)

      (
        Angle
          .from_degrees(
            l0 -
              Constants::EQUATION_OF_TIME_CONSTANT -
              right_ascension.degrees +
              nutation.degrees * obliquity.cos
          ).hours * Constants::SECONDS_PER_HOUR
      ).round
    end
  end
end
