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
        latitude_radians = @latitude.radians

        t0 = Math.sin(@altitude.radians) * Math.sin(latitude_radians) +
          Math.cos(@altitude.radians) * Math.cos(latitude_radians) * Math.cos(@azimuth.radians)

        declination = Astronoby::Angle.as_radians(Math.asin(t0))

        t1 = Math.sin(@altitude.radians) -
          Math.sin(latitude_radians) * Math.sin(declination.radians)

        hour_angle_degrees = Astronoby::Angle.as_radians(
          Math.acos(
            t1 / (Math.cos(latitude_radians) * Math.cos(declination.radians))
          )
        ).degrees

        if Math.sin(@azimuth.radians).positive?
          hour_angle_degrees = Astronoby::Angle.as_degrees(
            BigDecimal("360") - hour_angle_degrees
          ).degrees
        end

        hour_angle_hours = Astronoby::Angle.as_degrees(hour_angle_degrees).hours
        right_ascension_decimal = Astronoby::Util::Time.local_sidereal_time(
          time: time,
          longitude: @longitude
        ) - hour_angle_hours
        right_ascension_decimal += 24 if right_ascension_decimal.negative?
        right_ascension = Astronoby::Angle.as_hours(right_ascension_decimal)

        Equatorial.new(
          right_ascension: right_ascension,
          declination: declination
        )
      end
    end
  end
end
