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
        t0 = @altitude.sin * @latitude.sin +
          @altitude.cos * @latitude.cos * @azimuth.cos

        declination = Angle.asin(t0)

        t1 = @altitude.sin - @latitude.sin * declination.sin

        hour_angle_degrees = Angle
          .acos(t1 / (@latitude.cos * declination.cos))
          .degrees

        if @azimuth.sin.positive?
          hour_angle_degrees = Angle
            .from_degrees(BigDecimal("360") - hour_angle_degrees)
            .degrees
        end

        hour_angle_hours = Angle.from_degrees(hour_angle_degrees).hours
        lst = GreenwichSiderealTime
          .from_utc(time.utc)
          .to_lst(longitude: @longitude)
        right_ascension_decimal = lst.time - hour_angle_hours
        right_ascension_decimal += 24 if right_ascension_decimal.negative?
        right_ascension = Angle.from_hours(right_ascension_decimal)

        Equatorial.new(
          right_ascension: right_ascension,
          declination: declination
        )
      end
    end
  end
end
