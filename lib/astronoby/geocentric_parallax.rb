# frozen_string_literal: true

module Astronoby
  class GeocentricParallax
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax

    # Equatorial horizontal parallax
    # @param distance [Numeric] Distance of the body from the center of the
    #   Earth, in meters
    # @return [Astronoby::Angle] Equatorial horizontal parallax angle
    def self.angle(distance:)
      distance_in_au = distance / Constants::ASTRONOMICAL_UNIT_IN_METERS
      Angle.from_radians(Angle.from_dms(0, 0, 8.794).sin / distance_in_au)
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
      term1 = Angle.atan(Constants::EARTH_FLATTENING_CORRECTION * @latitude.tan)
      quantity1 = term1.cos + elevation_ratio * @latitude.cos
      quantity2 = Constants::EARTH_FLATTENING_CORRECTION * term1.sin +
        elevation_ratio * @latitude.sin

      term1 = -quantity1 * equatorial_horizontal_parallax.sin * hour_angle.sin
      term2 = declination.cos - quantity1 * equatorial_horizontal_parallax.sin * hour_angle.cos
      delta_right_ascension = Angle.atan(term1 / term2)

      term1 = (declination.sin - quantity2 * equatorial_horizontal_parallax.sin) * delta_right_ascension.cos
      term2 = declination.cos - quantity1 * equatorial_horizontal_parallax.sin * hour_angle.cos
      new_declination = Angle.atan(term1 / term2)

      Coordinates::Equatorial.new(
        right_ascension: delta_right_ascension + right_ascension,
        declination: new_declination,
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
      @elevation / Constants::EARTH_EQUATORIAL_RADIUS_IN_METERS
    end

    def equatorial_horizontal_parallax
      self.class.angle(distance: @distance)
    end
  end
end
