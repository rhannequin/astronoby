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
        latitude_radians = @latitude.to_radians.value

        t0 = Math.sin(@altitude.to_radians.value) * Math.sin(latitude_radians) +
          Math.cos(@altitude.to_radians.value) * Math.cos(latitude_radians) * Math.cos(@azimuth.to_radians.value)

        declination = Astronoby::Angle.as_radians(Math.asin(t0))

        t1 = Math.sin(@altitude.to_radians.value) -
          Math.sin(latitude_radians) * Math.sin(declination.to_radians.value)

        hour_angle_degrees = Astronoby::Angle.as_radians(
          Math.acos(
            t1 / (Math.cos(latitude_radians) * Math.cos(declination.to_radians.value))
          )
        ).to_degrees

        if Math.sin(@azimuth.to_radians.value).positive?
          hour_angle_degrees = Astronoby::Angle.as_degrees(
            BigDecimal("360") - hour_angle_degrees.value
          )
        end

        hour_angle_hours = hour_angle_degrees.to_hours
        right_ascension_decimal = Astronoby::Util::Time.local_sidereal_time(
          time: time,
          longitude: @longitude
        ) - hour_angle_hours.value
        right_ascension_decimal += 24 if right_ascension_decimal.negative?
        right_ascension = Astronoby::Angle.as_hours(right_ascension_decimal)

        Equatorial.new(
          right_ascension: right_ascension.to_hours,
          declination: declination.to_degrees
        )
      end
    end
  end
end
