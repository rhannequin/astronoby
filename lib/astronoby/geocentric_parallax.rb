# frozen_string_literal: true

module Astronoby
  class GeocentricParallax
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax

    ASTRONOMICAL_UNIT_IN_METERS = 149_597_870_700
    EARTH_FLATTENING_CORRECTION = 0.996647
    EARTH_EQUATORIAL_RADIUS = 6378140.0

    # Equatorial horizontal parallax
    # @param distance [Numeric] Distance of the body from the center of the
    #   Earth, in meters
    # @return [Astronoby::Angle] Equatorial horizontal parallax angle
    def self.angle(distance:)
      distance_in_earth_radius = distance / EARTH_EQUATORIAL_RADIUS
      Angle.asin(1 / distance_in_earth_radius)
    end

    # Correct equatorial coordinates with the equatorial horizontal parallax
    # @param latitude [Astronoby::Angle] Observer's latitude
    # @param longitude [Astronoby::Angle] Observer's longitude
    # @param elevation [Numeric] Observer's elevation above sea level in meters
    # @param time [Time] Date-time of the observation
    # @param coordinates [Astronoby::Coordinates::Equatorial]
    #   Equatorial coordinates of the observed body
    # @param distance [Numeric] Distance of the observed body from the center of
    #   the Earth, in meters
    # @return [Astronoby::Coordinates::Equatorial] Apparent equatorial
    #   coordinates with equatorial horizontal parallax
    def self.for_equatorial_coordinates(
      latitude:,
      longitude:,
      elevation:,
      time:,
      coordinates:,
      distance:
    )
      new(
        latitude,
        longitude,
        elevation,
        time,
        coordinates,
        distance
      ).apply
    end

    # @param latitude [Astronoby::Angle] Observer's latitude
    # @param longitude [Astronoby::Angle] Observer's longitude
    # @param elevation [Numeric] Observer's elevation above sea level in meters
    # @param time [Time] Date-time of the observation
    # @param coordinates [Astronoby::Coordinates::Equatorial] Equatorial
    #   coordinates of the observed body
    # @param distance [Numeric] Distance of the observed body from the center of
    #   the Earth, in meters
    def initialize(
      latitude,
      longitude,
      elevation,
      time,
      coordinates,
      distance
    )
      @latitude = latitude
      @longitude = longitude
      @elevation = elevation
      @time = time
      @coordinates = coordinates
      @distance = distance
    end

    def apply
      term1 = Angle.atan(EARTH_FLATTENING_CORRECTION * @latitude.tan)
      quantity1 = term1.cos + elevation_ratio * @latitude.cos
      quantity2 = EARTH_FLATTENING_CORRECTION * term1.sin +
        elevation_ratio * @latitude.sin

      term2 = quantity1 * hour_angle.sin
      term3 = distance_in_earth_radius * declination.cos -
        quantity1 * hour_angle.cos

      delta = Angle.atan(term2 / term3)

      apparent_hour_angle = hour_angle + delta
      apparent_right_ascension = right_ascension - delta
      apparent_declination = Angle.atan(
        (
          apparent_hour_angle.cos *
            (distance_in_earth_radius * declination.sin - quantity2)
        ) / (
          distance_in_earth_radius * declination.cos * hour_angle.cos - quantity1
        )
      )

      Coordinates::Equatorial.new(
        right_ascension: apparent_right_ascension,
        declination: apparent_declination,
        epoch: @coordinates.epoch
      )
    end

    private

    def right_ascension
      @coordinates.right_ascension
    end

    def declination
      @coordinates.declination
    end

    def hour_angle
      @_hour_angle ||=
        @coordinates.compute_hour_angle(time: @time, longitude: @longitude)
    end

    def elevation_ratio
      @elevation / EARTH_EQUATORIAL_RADIUS
    end

    def distance_in_earth_radius
      @distance / EARTH_EQUATORIAL_RADIUS
    end
  end
end
