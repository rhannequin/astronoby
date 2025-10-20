# frozen_string_literal: true

module Astronoby
  class DeepSkyObject
    DEFAULT_DISTANCE = Distance.from_parsecs(1e9)

    attr_reader :instant, :apparent

    # @param instant [Astronoby::Instant] Instant of the observation
    # @param equatorial_coordinates [Astronoby::Coordinates::Equatorial]
    #   Equatorial coordinates at epoch J2000.0
    # @param proper_motion_ra [Astronoby::AngularVelocity, nil] Proper motion in
    #   right ascension
    # @param proper_motion_dec [Astronoby::AngularVelocity, nil] Proper motion
    #   in declination
    # @param parallax [Astronoby::Angle, nil] Parallax angle
    # @param radial_velocity [Astronoby::Velocity, nil] Radial velocity
    def initialize(
      instant:,
      equatorial_coordinates:,
      ephem: nil,
      proper_motion_ra: nil,
      proper_motion_dec: nil,
      parallax: nil,
      radial_velocity: nil
    )
      @instant = instant
      @initial_equatorial_coordinates = equatorial_coordinates
      @proper_motion_ra = proper_motion_ra
      @proper_motion_dec = proper_motion_dec
      @parallax = parallax
      @radial_velocity = radial_velocity
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
        center_identifier: SolarSystemBody::EARTH,
        target_body: self
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
          target_body: self
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
          center_identifier: SolarSystemBody::EARTH,
          target_body: self
        )
      end
    end
  end
end
