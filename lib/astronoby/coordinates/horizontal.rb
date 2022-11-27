# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Horizontal
      attr_reader :azimuth, :altitude, :latitude, :longitude

      def initialize(
        azimuth:,
        altitude:,
        latitude:,
        longitude:
      )
        @azimuth = azimuth
        @altitude = altitude
        @latitude = latitude
        @longitude = longitude
      end

      def to_equatorial(time:)
        latitude_radians = Astronoby::Util::Trigonometry.to_radians(@latitude)

        t0 = Math.sin(@altitude.to_radians.value) * Math.sin(latitude_radians) +
          Math.cos(@altitude.to_radians.value) * Math.cos(latitude_radians) * Math.cos(@azimuth.to_radians.value)

        declination = Astronoby::Angle.as_radians(Math.asin(t0))

        t1 = Math.sin(@altitude.to_radians.value) -
          Math.sin(latitude_radians) * Math.sin(declination.to_radians.value)

        hour_angle_degrees = Astronoby::Util::Trigonometry.to_degrees(
          Math.acos(
            t1 / (Math.cos(latitude_radians) * Math.cos(declination.to_radians.value))
          )
        )

        if Math.sin(@azimuth.to_radians.value).positive?
          hour_angle_degrees = BigDecimal("360") - hour_angle_degrees
        end

        hour_angle_hours = hour_angle_degrees / 15r
        right_ascension_decimal = local_sidereal_time(
          time: time,
          longitude: @longitude
        ) - hour_angle_hours
        right_ascension_decimal += 24 if right_ascension_decimal.negative?
        right_ascension = Astronoby::Angle.as_degrees(right_ascension_decimal)

        Equatorial.new(
          right_ascension: right_ascension.to_degrees,
          declination: declination.to_degrees
        )
      end

      private

      def local_sidereal_time(time:, longitude:)
        universal_time = time.utc

        # Julian Day
        julian_day = universal_time.to_date.ajd.to_f
        julian_day_at_beginning_of_the_year = Time.utc(universal_time.year, 1, 1, 0, 0, 0).to_date.ajd - 1
        number_of_elapsed_days_into_the_year = julian_day - julian_day_at_beginning_of_the_year

        # Source:
        #  Title: Celestial Calculations
        #  Author: J. L. Lawrence
        #  Edition: MIT Press
        #  Chapter: 3 - Time Conversions
        t = (julian_day_at_beginning_of_the_year - BigDecimal("2415020")) / BigDecimal("36525")
        r = BigDecimal("6.6460656") +
          BigDecimal("2400.051262") * t + BigDecimal("0.00002581") * t * t
        b = 24 - r + 24 * (universal_time.year - 1900)
        t0 = BigDecimal("0.0657098") * number_of_elapsed_days_into_the_year - b
        ut = universal_time.hour +
          universal_time.min / BigDecimal("60") +
          universal_time.sec / BigDecimal("3600")
        greenwich_sidereal_time = t0 + BigDecimal("1.002738") * ut

        # If greenwich_sidereal_time negative, add 24 hours to the date
        # If greenwich_sidereal_time is greater than 24, subtract 24 hours from the date

        greenwich_sidereal_time += 24 if greenwich_sidereal_time.negative?
        greenwich_sidereal_time -= 24 if greenwich_sidereal_time > 24

        adjustment = longitude / BigDecimal("15")
        greenwich_sidereal_time + adjustment
      end
    end
  end
end
