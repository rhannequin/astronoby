# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Equatorial
      attr_reader :right_ascension, :declination

      def initialize(
        right_ascension:,
        declination:
      )
        @right_ascension = right_ascension
        @declination = declination
      end

      def to_horizontal(time:, latitude:, longitude:)
        hour_angle = local_sidereal_time(time: time, longitude: longitude) -
          right_ascension.to_degrees.value

        hour_angle += 24 if hour_angle.negative?
        hour_angle -= 24 if hour_angle > 24
        hour_angle_degree = hour_angle * BigDecimal("15")
        hour_angle_radians = Astronoby::Util::Trigonometry.to_radians(hour_angle_degree)

        latitude_radians = Astronoby::Util::Trigonometry.to_radians(latitude)

        t0 = Math.sin(@declination.to_radians.value) * Math.sin(latitude_radians) +
          Math.cos(@declination.to_radians.value) * Math.cos(latitude_radians) * Math.cos(hour_angle_radians)
        altitude = Astronoby::Angle.as_radians(Math.asin(t0))

        t1 = Math.sin(@declination.to_radians.value) -
          Math.sin(latitude_radians) * Math.sin(altitude.to_radians.value)
        t2 = t1 / (Math.cos(latitude_radians) * Math.cos(altitude.to_radians.value))
        sin_hour_angle = Math.sin(hour_angle_radians)
        azimuth = Astronoby::Angle.as_radians(Math.acos(t2))
        if sin_hour_angle.positive?
          azimuth = Astronoby::Angle.as_degrees(BigDecimal("360") - azimuth.to_degrees.value)
        end

        Horizontal.new(
          azimuth: azimuth.to_degrees,
          altitude: altitude.to_degrees,
          latitude: latitude,
          longitude: longitude
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
