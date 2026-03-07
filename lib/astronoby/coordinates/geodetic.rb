# frozen_string_literal: true

module Astronoby
  module Coordinates
    # Geodetic coordinate system (WGS-84 latitude, longitude, and elevation).
    #
    # Geodetic coordinates describe a position on or above the Earth's surface
    # using the WGS-84 reference ellipsoid, the same system used by GPS.
    #
    # The reverse conversion from ECEF (Earth-Centered Earth-Fixed) Cartesian
    # coordinates uses Bowring's iterative method, which converges in 2-3
    # iterations for typical satellite altitudes.
    class Geodetic
      SEMI_MINOR_AXIS =
        Constants::WGS84_EARTH_EQUATORIAL_RADIUS_IN_METERS *
        (1 - Constants::WGS84_FLATTENING)
      SECOND_ECCENTRICITY_SQUARED =
        (Constants::WGS84_EARTH_EQUATORIAL_RADIUS_IN_METERS**2 -
          SEMI_MINOR_AXIS**2) /
        SEMI_MINOR_AXIS**2
      MAX_ITERATIONS = 10
      CONVERGENCE_THRESHOLD = 1e-12

      # @return [Astronoby::Angle] geodetic latitude
      attr_reader :latitude

      # @return [Astronoby::Angle] geodetic longitude
      attr_reader :longitude

      # @return [Astronoby::Distance] elevation above the WGS-84 ellipsoid
      attr_reader :elevation

      # @param latitude [Astronoby::Angle] geodetic latitude
      # @param longitude [Astronoby::Angle] geodetic longitude
      # @param elevation [Astronoby::Distance] elevation above the WGS-84
      #   ellipsoid
      def initialize(latitude:, longitude:, elevation:)
        @latitude = latitude
        @longitude = longitude
        @elevation = elevation
      end

      # Converts ECEF Cartesian coordinates to geodetic coordinates using
      # Bowring's iterative method.
      #
      # Source:
      #  Title: Transformation from Spatial to Geographical Coordinates
      #  Author: B. R. Bowring
      #  Edition: Survey Review, Vol. 23, No. 181, 1976
      #
      # @param position [Astronoby::Vector<Astronoby::Distance>] ECEF position
      # @return [Astronoby::Coordinates::Geodetic] geodetic coordinates
      def self.from_ecef(position)
        x = position.x.m
        y = position.y.m
        z = position.z.m

        a = Constants::WGS84_EARTH_EQUATORIAL_RADIUS_IN_METERS
        e2 = Constants::WGS84_ECCENTICITY_SQUARED

        p = Math.sqrt(x * x + y * y)
        longitude = Math.atan2(y, x)

        theta = Math.atan2(z * a, p * SEMI_MINOR_AXIS)
        latitude = Math.atan2(
          z + SECOND_ECCENTRICITY_SQUARED * SEMI_MINOR_AXIS *
            Math.sin(theta)**3,
          p - e2 * a * Math.cos(theta)**3
        )

        MAX_ITERATIONS.times do
          prev_latitude = latitude
          theta = Math.atan2(
            (1 - Constants::WGS84_FLATTENING) * Math.sin(latitude),
            Math.cos(latitude)
          )
          latitude = Math.atan2(
            z + SECOND_ECCENTRICITY_SQUARED * SEMI_MINOR_AXIS *
              Math.sin(theta)**3,
            p - e2 * a * Math.cos(theta)**3
          )
          break if (latitude - prev_latitude).abs < CONVERGENCE_THRESHOLD
        end

        sin_lat = Math.sin(latitude)
        n = a / Math.sqrt(1 - e2 * sin_lat * sin_lat)

        elevation = if Math.cos(latitude).abs > 1e-10
          p / Math.cos(latitude) - n
        else
          z / sin_lat - n * (1 - e2)
        end

        new(
          latitude: Angle.from_radians(latitude),
          longitude: Angle.from_radians(longitude),
          elevation: Distance.from_meters(elevation)
        )
      end
    end
  end
end
