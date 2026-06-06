# frozen_string_literal: true

module Astronoby
  # Represents the computed position of a deep-sky object at a specific
  # instant, providing astrometric, apparent, and topocentric reference frames.
  class DeepSkyObjectPosition
    include Position

    DEFAULT_DISTANCE = Distance.from_parsecs(1e9)

    # @return [Astronoby::Instant] the time instant
    attr_reader :instant

    # @return [Astronoby::Apparent] the apparent reference frame
    attr_reader :apparent

    # @return [Astronoby::DeepSkyObject, nil] the body definition
    attr_reader :body

    # @param instant [Astronoby::Instant] Instant of the observation
    # @param equatorial_coordinates [Astronoby::Coordinates::Equatorial]
    #   Equatorial coordinates at epoch J2000.0
    # @param ephem [::Ephem::SPK, nil] Ephemeris data source for Earth position
    # @param proper_motion_ra [Astronoby::AngularVelocity, nil] Proper motion in
    #   right ascension
    # @param proper_motion_dec [Astronoby::AngularVelocity, nil] Proper motion
    #   in declination
    # @param parallax [Astronoby::Angle, nil] Parallax angle
    # @param radial_velocity [Astronoby::Velocity, nil] Radial velocity
    # @param deep_sky_object [Astronoby::DeepSkyObject, nil] the body definition
    def initialize(
      instant:,
      equatorial_coordinates:,
      ephem: nil,
      proper_motion_ra: nil,
      proper_motion_dec: nil,
      parallax: nil,
      radial_velocity: nil,
      deep_sky_object: nil
    )
      @instant = instant
      @initial_equatorial_coordinates = equatorial_coordinates
      @proper_motion_ra = proper_motion_ra
      @proper_motion_dec = proper_motion_dec
      @parallax = parallax
      @radial_velocity = radial_velocity
      @body = deep_sky_object
      if ephem
        @earth_geometric = Earth.geometric(ephem: ephem, instant: @instant)
      end
      compute_apparent
    end

    # @return [Astronoby::Astrometric] Astrometric position of the object
    def astrometric
      @astrometric ||= Astrometric.new(
        instant: @instant,
        position: astrometric_position,
        velocity: astrometric_velocity,
        center: Center.geocentric,
        target_body: body
      )
    end

    private

    def astrometric_position
      @astrometric_position ||= if use_stellar_propagation?
        stellar_propagation.position
      else
        astronomical_distance = DEFAULT_DISTANCE.meters
        right_ascension = @initial_equatorial_coordinates.right_ascension
        declination = @initial_equatorial_coordinates.declination
        Distance.vector_from_meters([
          declination.cos * right_ascension.cos * astronomical_distance,
          declination.cos * right_ascension.sin * astronomical_distance,
          declination.sin * astronomical_distance
        ])
      end
    end

    def astrometric_velocity
      @astrometric_velocity ||= if use_stellar_propagation?
        stellar_propagation.velocity_vector
      else
        Velocity.vector_from_meters_per_second([0.0, 0.0, 0.0])
      end
    end

    def use_stellar_propagation?
      @proper_motion_ra && @proper_motion_dec && @parallax && @radial_velocity
    end

    def stellar_propagation
      @stellar_propagation ||= StellarPropagation.new(
        equatorial_coordinates: @initial_equatorial_coordinates,
        proper_motion_ra: @proper_motion_ra,
        proper_motion_dec: @proper_motion_dec,
        parallax: @parallax,
        radial_velocity: @radial_velocity,
        instant: @instant,
        earth_geometric: @earth_geometric
      )
    end

    def compute_apparent
      @apparent = if @earth_geometric
        Apparent.build_from_astrometric(
          instant: @instant,
          target_astrometric: astrometric,
          earth_geometric: @earth_geometric,
          target_body: body
        )
      else
        precession_matrix = Precession.matrix_for(@instant)
        nutation_matrix = Nutation.matrix_for(@instant)
        corrected_position = Distance.vector_from_meters(
          precession_matrix * nutation_matrix * astrometric.position.map(&:m)
        )
        corrected_velocity = Velocity.vector_from_mps(
          precession_matrix * nutation_matrix * astrometric.velocity.map(&:mps)
        )
        Apparent.new(
          position: corrected_position,
          velocity: corrected_velocity,
          instant: @instant,
          center: Center.geocentric,
          target_body: body
        )
      end
    end
  end
end
