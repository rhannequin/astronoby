# frozen_string_literal: true

module Astronoby
  module Coordinates
    # Equatorial coordinate system (right ascension and declination).
    class Equatorial
      # @return [Astronoby::Angle] declination
      attr_reader :declination

      # @return [Astronoby::Angle] right ascension
      attr_reader :right_ascension

      # @return [Astronoby::Angle, nil] hour angle, if set
      attr_reader :hour_angle

      # @return [Numeric] the Julian Date epoch
      attr_reader :epoch

      # @param declination [Astronoby::Angle] declination
      # @param right_ascension [Astronoby::Angle] right ascension
      # @param hour_angle [Astronoby::Angle, nil] hour angle
      # @param epoch [Numeric] Julian Date epoch (default: J2000.0 = 2451545.0)
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

      # @return [Astronoby::Coordinates::Equatorial] zero coordinates
      def self.zero
        new(declination: Angle.zero, right_ascension: Angle.zero)
      end

      # Derives equatorial coordinates from a position vector.
      #
      # @param position [Astronoby::Vector<Astronoby::Distance>] position vector
      # @return [Astronoby::Coordinates::Equatorial] equatorial coordinates
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

      # Computes the hour angle for a given time and observer longitude.
      #
      # @param time [Time] the UTC time
      # @param longitude [Astronoby::Angle] the observer's longitude
      # @return [Astronoby::Angle] the hour angle
      def compute_hour_angle(time:, longitude:)
        last = LocalApparentSiderealTime.from_utc(time.utc, longitude: longitude)
        ha = (last.time - @right_ascension.hours)
        ha += Constants::HOURS_PER_DAY if ha.negative?

        Angle.from_hours(ha)
      end

      # Converts to horizontal coordinates for a given observer and time.
      #
      # @param time [Time] the UTC time
      # @param observer [Astronoby::Observer] the observer
      # @return [Astronoby::Coordinates::Horizontal] horizontal coordinates
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

      # Converts to ecliptic coordinates.
      #
      # Source:
      #  Title: Celestial Calculations
      #  Author: J. L. Lawrence
      #  Edition: MIT Press
      #  Chapter: 4 - Orbits and Coordinate Systems
      #
      # @param instant [Astronoby::Instant] the time instant for the obliquity
      # @param obliquity [Astronoby::Angle] the obliquity of the ecliptic to
      #   rotate by. Defaults to the mean obliquity of date; pass the true
      #   obliquity when the equatorial coordinates already include nutation
      #   (true-of-date apparent and topocentric places).
      # @return [Astronoby::Coordinates::Ecliptic] ecliptic coordinates
      def to_ecliptic(instant:, obliquity: MeanObliquity.at(instant))
        y = Angle.from_radians(
          @right_ascension.sin * obliquity.cos +
          @declination.tan * obliquity.sin
        )
        x = Angle.from_radians(@right_ascension.cos)
        r = Angle.atan(y.radians / x.radians)
        longitude = Util::Trigonometry.adjustement_for_arctangent(y, x, r)

        latitude = Angle.asin(
          @declination.sin * obliquity.cos -
          @declination.cos * obliquity.sin * @right_ascension.sin
        )

        Ecliptic.new(
          latitude: latitude,
          longitude: longitude
        )
      end

      # Position angle of another point as seen from this one, measured
      # eastward (counterclockwise) from the direction of the north celestial
      # pole. Both points must be expressed in the same frame.
      #
      # @param other [Astronoby::Coordinates::Equatorial] the target point
      # @return [Astronoby::Angle] position angle, between -180 and 180 degrees
      def position_angle_to(other)
        delta_right_ascension = other.right_ascension - @right_ascension

        Angle.from_radians(
          Math.atan2(
            other.declination.cos * delta_right_ascension.sin,
            other.declination.sin * @declination.cos -
              other.declination.cos * @declination.sin *
                delta_right_ascension.cos
          )
        )
      end
    end
  end
end
