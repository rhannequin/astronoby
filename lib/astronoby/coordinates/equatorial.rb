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
        hour_angle = Astronoby::Util::Time.local_sidereal_time(
          time: time,
          longitude: longitude
        ) - right_ascension.to_degrees.value

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
    end
  end
end
