# frozen_string_literal: true

module Astronoby
  # Transforms equatorial coordinates at J2000.0 into horizontal coordinates
  # for one observer at one instant.
  #
  # Everything that depends only on the observer and the instant is computed
  # once at construction: the rotation from the ICRS to the true equator and
  # equinox of date (nutation * precession, with the ICRS frame bias), and the
  # local apparent sidereal time. Converting a point then costs a matrix
  # product and a few trigonometric functions, instead of rebuilding the
  # reference frame chain for each point. It is meant for converting many
  # points for the same observer and instant, such as the stars of a catalogue
  # for a sky chart.
  #
  # It plays the role of the "star-independent astrometry parameters" of SOFA
  # and ERFA, restricted to what Astronoby applies without an ephemeris. The
  # result is the same as
  # `DeepSkyObject#at(instant).observed_by(observer).horizontal`, but the
  # points are treated as fixed directions: no aberration, no proper motion and
  # no parallax. The topocentric correction is not applied either, as it is
  # nil for objects at stellar distances. Atmospheric refraction is optional.
  #
  # @example Convert the stars of a catalogue for one observer and instant
  #   transformation = Astronoby::HorizontalTransformation.new(
  #     observer: observer,
  #     instant: instant
  #   )
  #   horizontals = catalogue.map { |star| transformation.apply(star) }
  class HorizontalTransformation
    # @return [Astronoby::Observer] the observer
    attr_reader :observer

    # @return [Astronoby::Instant] the instant
    attr_reader :instant

    # @param observer [Astronoby::Observer] the observer
    # @param instant [Astronoby::Instant] the instant of the observation
    def initialize(observer:, instant:)
      @observer = observer
      @instant = instant
      @rotation_rows = (
        Nutation.matrix_for(instant) * Precession.matrix_for(instant)
      ).to_a.freeze
      @local_apparent_sidereal_time = LocalApparentSiderealTime.from_utc(
        instant.to_time,
        longitude: observer.longitude
      ).time
      freeze
    end

    # @param equatorial_coordinates [Astronoby::Coordinates::Equatorial]
    #   equatorial coordinates at epoch J2000.0
    # @param refraction [Boolean] whether to apply atmospheric refraction
    #   correction (default: false)
    # @return [Astronoby::Coordinates::Horizontal] horizontal coordinates
    # @raise [Astronoby::IncompatibleArgumentsError] if the coordinates are not
    #   referred to epoch J2000.0
    def apply(equatorial_coordinates, refraction: false)
      ensure_j2000!(equatorial_coordinates)

      horizontal = apparent_equatorial(equatorial_coordinates).to_horizontal(
        time: @instant.to_time,
        observer: @observer
      )

      if refraction
        Refraction.correct_horizontal_coordinates(coordinates: horizontal)
      else
        horizontal
      end
    end

    private

    # Equatorial coordinates of date, with the hour angle already known so that
    # the sidereal time is not computed again.
    def apparent_equatorial(coordinates)
      declination = coordinates.declination
      right_ascension = coordinates.right_ascension
      cos_declination = declination.cos
      x = cos_declination * right_ascension.cos
      y = cos_declination * right_ascension.sin
      z = declination.sin

      row_x, row_y, row_z = @rotation_rows
      apparent_x = row_x[0] * x + row_x[1] * y + row_x[2] * z
      apparent_y = row_y[0] * x + row_y[1] * y + row_y[2] * z
      apparent_z = row_z[0] * x + row_z[1] * y + row_z[2] * z

      apparent_right_ascension =
        Angle.from_radians(Math.atan2(apparent_y, apparent_x))

      Coordinates::Equatorial.new(
        right_ascension: apparent_right_ascension,
        declination: Angle.asin(apparent_z.clamp(-1.0, 1.0)),
        hour_angle:
          Angle.from_hours(@local_apparent_sidereal_time) -
            apparent_right_ascension,
        epoch: @instant.tt
      )
    end

    def ensure_j2000!(coordinates)
      return if coordinates.epoch == JulianDate::J2000

      raise IncompatibleArgumentsError,
        "Expected equatorial coordinates at epoch J2000.0, got epoch " \
        "#{coordinates.epoch}"
    end
  end
end
