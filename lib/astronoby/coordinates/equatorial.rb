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

        ha = (lst - @right_ascension.to_hours.value)
        ha += 24 if ha.negative?

        Astronoby::Angle.as_hours(ha)
      end

      def to_horizontal(time:, latitude:, longitude:)
        ha = @hour_angle || compute_hour_angle(time: time, longitude: longitude)

        latitude_radians = latitude.to_radians.value
        declination_radians = @declination.to_radians.value

        t0 = Math.sin(declination_radians) * Math.sin(latitude_radians) +
          Math.cos(declination_radians) * Math.cos(latitude_radians) * Math.cos(ha.to_radians.value)
        altitude = Astronoby::Angle.as_radians(Math.asin(t0))

        t1 = Math.sin(declination_radians) -
          Math.sin(latitude_radians) * Math.sin(altitude.to_radians.value)
        t2 = t1 / (Math.cos(latitude_radians) * Math.cos(altitude.to_radians.value))
        sin_hour_angle = Math.sin(ha.to_radians.value)
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

      # Source:
      #  Title: Celestial Calculations
      #  Author: J. L. Lawrence
      #  Edition: MIT Press
      #  Chapter: 4 - Orbits and Coordinate Systems
      def to_ecliptic(epoch:)
        mean_obliquity = Astronoby::MeanObliquity.for_epoch(epoch)
        obliquity_in_radians = mean_obliquity.value.to_radians.value
        right_ascension_in_radians = @right_ascension.to_radians.value
        declination_in_radians = @declination.to_radians.value

        y = Astronoby::Angle.as_radians(
          Math.sin(right_ascension_in_radians) * Math.cos(obliquity_in_radians) +
          Math.tan(declination_in_radians) * Math.sin(obliquity_in_radians)
        )
        x = Astronoby::Angle.as_radians(Math.cos(right_ascension_in_radians))
        r = Astronoby::Angle.as_radians(Math.atan(y.value / x.value))
        longitude = Astronoby::Util::Trigonometry.adjustement_for_arctangent(y, x, r)

        latitude = Astronoby::Angle.as_radians(
          Math.asin(
            Math.sin(declination_in_radians) * Math.cos(obliquity_in_radians) -
            Math.cos(declination_in_radians) * Math.sin(obliquity_in_radians) * Math.sin(right_ascension_in_radians)
          )
        )

        Ecliptic.new(
          latitude: latitude.to_degrees,
          longitude: longitude.to_degrees
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
