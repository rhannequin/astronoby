# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Equatorial
      attr_reader :declination, :right_ascension, :hour_angle, :epoch

      def initialize(
        declination:,
        right_ascension: nil,
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

        latitude_radians = latitude.radians
        declination_radians = @declination.radians

        t0 = Math.sin(declination_radians) * Math.sin(latitude_radians) +
          Math.cos(declination_radians) * Math.cos(latitude_radians) * Math.cos(ha.radians)
        altitude = Astronoby::Angle.as_radians(Math.asin(t0))

        t1 = Math.sin(declination_radians) -
          Math.sin(latitude_radians) * Math.sin(altitude.radians)
        t2 = t1 / (Math.cos(latitude_radians) * Math.cos(altitude.radians))
        sin_hour_angle = Math.sin(ha.radians)
        azimuth = Astronoby::Angle.as_radians(Math.acos(t2))
        if sin_hour_angle.positive?
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
        obliquity_in_radians = mean_obliquity.value.radians
        right_ascension_in_radians = @right_ascension.radians
        declination_in_radians = @declination.radians

        y = Astronoby::Angle.as_radians(
          Math.sin(right_ascension_in_radians) * Math.cos(obliquity_in_radians) +
          Math.tan(declination_in_radians) * Math.sin(obliquity_in_radians)
        )
        x = Astronoby::Angle.as_radians(Math.cos(right_ascension_in_radians))
        r = Astronoby::Angle.as_radians(Math.atan(y.radians / x.radians))
        longitude = Astronoby::Util::Trigonometry.adjustement_for_arctangent(y, x, r)

        latitude = Astronoby::Angle.as_radians(
          Math.asin(
            Math.sin(declination_in_radians) * Math.cos(obliquity_in_radians) -
            Math.cos(declination_in_radians) * Math.sin(obliquity_in_radians) * Math.sin(right_ascension_in_radians)
          )
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
