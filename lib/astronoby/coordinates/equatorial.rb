# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Equatorial
      attr_reader :declination, :right_ascension, :hour_angle, :epoch

      def initialize(
        declination:,
        right_ascension:,
        hour_angle: nil,
        epoch: Astronoby::Epoch::DEFAULT_EPOCH
      )
        @right_ascension = right_ascension
        @declination = declination
        @hour_angle = hour_angle
        @epoch = epoch
      end

      def compute_hour_angle(time:, longitude:)
        lst = Astronoby::Util::Time.local_sidereal_time(
          time: time,
          longitude: longitude
        )

        ha = (lst - @right_ascension.hours)
        ha += 24 if ha.negative?

        Astronoby::Angle.as_hours(ha)
      end

      def to_horizontal(time:, latitude:, longitude:)
        ha = @hour_angle || compute_hour_angle(time: time, longitude: longitude)
        t0 = @declination.sin * latitude.sin +
          @declination.cos * latitude.cos * ha.cos
        altitude = Astronoby::Angle.asin(t0)

        t1 = @declination.sin - latitude.sin * altitude.sin
        t2 = t1 / (latitude.cos * altitude.cos)
        azimuth = Astronoby::Angle.acos(t2)

        if ha.sin.positive?
          azimuth = Astronoby::Angle.as_degrees(BigDecimal("360") - azimuth.degrees)
        end

        Horizontal.new(
          azimuth: azimuth,
          altitude: altitude,
          latitude: latitude,
          longitude: longitude
        )
      end

      # Source:
      #  Title: Celestial Calculations
      #  Author: J. L. Lawrence
      #  Edition: MIT Press
      #  Chapter: 4 - Orbits and Coordinate Systems
      def to_ecliptic(epoch:)
        mean_obliquity = Astronoby::MeanObliquity.for_epoch(epoch)
        obliquity = mean_obliquity.value

        y = Astronoby::Angle.as_radians(
          @right_ascension.sin * obliquity.cos +
            @declination.tan * obliquity.sin
        )
        x = Astronoby::Angle.as_radians(@right_ascension.cos)
        r = Astronoby::Angle.atan(y.radians / x.radians)
        longitude = Astronoby::Util::Trigonometry.adjustement_for_arctangent(y, x, r)

        latitude = Astronoby::Angle.asin(
          @declination.sin * obliquity.cos -
          @declination.cos * obliquity.sin * @right_ascension.sin
        )

        Ecliptic.new(
          latitude: latitude,
          longitude: longitude
        )
      end

      def to_epoch(epoch)
        Astronoby::Precession.for_equatorial_coordinates(
          coordinates: self,
          epoch: epoch
        )
      end
    end
  end
end
