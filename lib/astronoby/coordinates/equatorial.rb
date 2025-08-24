# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Equatorial
      attr_reader :declination, :right_ascension, :hour_angle, :epoch

      def initialize(
        declination:,
        right_ascension:,
        hour_angle: nil,
        epoch: JulianDate::DEFAULT_EPOCH
      )
        @right_ascension = right_ascension
        @declination = declination
        @hour_angle = hour_angle
        @epoch = epoch
      end

      def self.zero
        new(declination: Angle.zero, right_ascension: Angle.zero)
      end

      def self.from_position_vector(position)
        return zero if position.zero?

        term1 = position.z.m
        term2 = position.magnitude.m
        declination = Angle.asin(term1 / term2)

        term1 = position.y.m
        term2 = position.x.m
        angle = Angle.atan(term1 / term2)
        right_ascension =
          Astronoby::Util::Trigonometry.adjustement_for_arctangent(
            term1,
            term2,
            angle
          )

        new(declination: declination, right_ascension: right_ascension)
      end

      def compute_hour_angle(time:, longitude:)
        lst = GreenwichSiderealTime
          .from_utc(time.utc)
          .to_lst(longitude: longitude)

        ha = (lst.time - @right_ascension.hours)
        ha += Constants::HOURS_PER_DAY if ha.negative?

        Angle.from_hours(ha)
      end

      def to_horizontal(time:, observer:)
        latitude = observer.latitude
        longitude = observer.longitude
        ha = @hour_angle || compute_hour_angle(time: time, longitude: longitude)
        t0 = @declination.sin * latitude.sin +
          @declination.cos * latitude.cos * ha.cos
        altitude = Angle.asin(t0)

        t1 = @declination.sin - latitude.sin * altitude.sin
        t2 = t1 / (latitude.cos * altitude.cos)
        t2 = t2.clamp(-1, 1)
        azimuth = Angle.acos(t2)

        if ha.sin.positive?
          azimuth =
            Angle.from_degrees(Constants::DEGREES_PER_CIRCLE - azimuth.degrees)
        end

        Horizontal.new(
          azimuth: azimuth,
          altitude: altitude,
          observer: observer
        )
      end

      # Source:
      #  Title: Celestial Calculations
      #  Author: J. L. Lawrence
      #  Edition: MIT Press
      #  Chapter: 4 - Orbits and Coordinate Systems
      def to_ecliptic(instant:)
        mean_obliquity = MeanObliquity.at(instant)

        y = Angle.from_radians(
          @right_ascension.sin * mean_obliquity.cos +
          @declination.tan * mean_obliquity.sin
        )
        x = Angle.from_radians(@right_ascension.cos)
        r = Angle.atan(y.radians / x.radians)
        longitude = Util::Trigonometry.adjustement_for_arctangent(y, x, r)

        latitude = Angle.asin(
          @declination.sin * mean_obliquity.cos -
          @declination.cos * mean_obliquity.sin * @right_ascension.sin
        )

        Ecliptic.new(
          latitude: latitude,
          longitude: longitude
        )
      end
    end
  end
end
