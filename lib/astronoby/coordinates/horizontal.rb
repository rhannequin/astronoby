# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Horizontal
      attr_reader :azimuth, :altitude, :observer

      def initialize(
        azimuth:,
        altitude:,
        observer:
      )
        @azimuth = azimuth
        @altitude = altitude
        @observer = observer
      end

      def to_equatorial(time:)
        t0 = @altitude.sin * latitude.sin +
          @altitude.cos * latitude.cos * @azimuth.cos

        declination = Angle.asin(t0)

        t1 = @altitude.sin - latitude.sin * declination.sin

        hour_angle_degrees = Angle
          .acos(t1 / (latitude.cos * declination.cos))
          .degrees

        if @azimuth.sin.positive?
          hour_angle_degrees = Angle
            .from_degrees(Constants::DEGREES_PER_CIRCLE - hour_angle_degrees)
            .degrees
        end

        hour_angle_hours = Angle.from_degrees(hour_angle_degrees).hours
        lst = GreenwichSiderealTime
          .from_utc(time.utc)
          .to_lst(longitude: longitude)
        right_ascension_decimal = lst.time - hour_angle_hours

        if right_ascension_decimal.negative?
          right_ascension_decimal += Constants::HOURS_PER_DAY
        end

        right_ascension = Angle.from_hours(right_ascension_decimal)

        Equatorial.new(
          right_ascension: right_ascension,
          declination: declination
        )
      end

      private

      def latitude
        @observer.latitude
      end

      def longitude
        @observer.longitude
      end
    end
  end
end
