# frozen_string_literal: true

module Astronoby
  class StellarPropagation
    # @return [Astronoby::Vector] Propagated position vector of
    #   Astronoby::Distance components
    def self.position_for(**kwargs)
      new(**kwargs).position
    end

    # @return [Astronoby::Vector] Propagated position vector of
    #   Astronoby::Velocity components
    def self.velocity_vector_for(**kwargs)
      new(**kwargs).velocity_vector
    end

    # @return [Astronoby::Coordinates::Equatorial] Propagated equatorial
    #   coordinates
    def self.equatorial_coordinates_for(**kwargs)
      new(**kwargs).equatorial_coordinates
    end

    # @param instant [Astronoby::Instant] Instant of the observation
    # @param equatorial_coordinates [Astronoby::Coordinates::Equatorial]
    #   Equatorial coordinates at epoch J2000.0
    # @param proper_motion_ra [Astronoby::AngularVelocity] Proper motion in
    #   right ascension
    # @param proper_motion_dec [Astronoby::AngularVelocity] Proper motion in
    #   declination
    # @param parallax [Astronoby::Angle] Parallax angle
    # @param radial_velocity [Astronoby::Velocity] Radial velocity
    # @param earth_geometric [Astronoby::ReferenceFrame::Geometric, nil]
    #   Geometric reference frame of the Earth
    def initialize(
      instant:,
      equatorial_coordinates:,
      proper_motion_ra:,
      proper_motion_dec:,
      parallax:,
      radial_velocity:,
      earth_geometric: nil
    )
      @instant = instant
      @right_ascension = equatorial_coordinates.right_ascension
      @declination = equatorial_coordinates.declination
      @initial_epoch = equatorial_coordinates.epoch
      @proper_motion_ra = proper_motion_ra
      @proper_motion_dec = proper_motion_dec
      @parallax = parallax
      @radial_velocity = radial_velocity
      @earth_geometric = earth_geometric
    end

    # @return [Astronoby::Vector] Propagated position vector of
    #   Astronoby::Distance components
    def position
      @position ||= Distance.vector_from_meters(
        initial_position_vector +
        tangential_velocity.map(&:mps) * time_elapsed_seconds
      )
    end

    # @return [Astronoby::Vector] Propagated position vector of
    #   Astronoby::Velocity components
    def velocity_vector
      @velocity_vector ||= if @earth_geometric
        @earth_geometric.velocity - tangential_velocity
      else
        tangential_velocity
      end
    end

    # @return [Astronoby::Coordinates::Equatorial] Propagated equatorial
    #   coordinates
    def equatorial_coordinates
      @equatorial_coordinates ||= begin
        right_ascension = Util::Trigonometry.adjustement_for_arctangent(
          position.y.m,
          position.x.m,
          Angle.atan(position.y.m / position.x.m)
        )
        declination = Angle.asin(position.z.m / position.magnitude.m)

        Coordinates::Equatorial.new(
          right_ascension: right_ascension,
          declination: declination,
          epoch: @instant.tt
        )
      end
    end

    private

    def distance
      @distance ||= Distance.from_parsecs(
        1 / (@parallax.degrees * Constants::ARCSECONDS_PER_DEGREE)
      )
    end

    def unit_position_vector
      @unit_position_vector ||= Vector[
        @right_ascension.cos * @declination.cos,
        @right_ascension.sin * @declination.cos,
        @declination.sin
      ]
    end

    def right_ascension_unit_vector
      @right_ascension_unit_vector ||= Vector[
        -@right_ascension.sin,
        @right_ascension.cos,
        0.0
      ]
    end

    def declination_unit_vector
      @declination_unit_vector ||= Vector[
        -@right_ascension.cos * @declination.sin,
        -@right_ascension.sin * @declination.sin,
        @declination.cos
      ]
    end

    def initial_position_vector
      @initial_position_vector ||= unit_position_vector * distance.meters
    end

    def tangential_velocity
      @tangential_velocity ||= begin
        # Doppler factor for light travel time correction
        k = 1.0 / (1.0 - @radial_velocity.kmps / Velocity.light_speed.kmps)

        proper_motion_ra_component =
          @proper_motion_ra.mas_per_year / (
            @parallax.degree_milliarcseconds * Constants::DAYS_PER_JULIAN_YEAR
          ) * k
        proper_motion_dec_component =
          @proper_motion_dec.mas_per_year / (
            @parallax.degree_milliarcseconds * Constants::DAYS_PER_JULIAN_YEAR
          ) * k
        radial_velocity_component = Velocity
          .from_kmps(@radial_velocity.kmps * k)

        Velocity.vector_from_astronomical_units_per_day([
          -proper_motion_ra_component * @right_ascension.sin -
            proper_motion_dec_component * @declination.sin * @right_ascension.cos +
            radial_velocity_component.aupd * @declination.cos * @right_ascension.cos,
          proper_motion_ra_component * @right_ascension.cos -
            proper_motion_dec_component * @declination.sin * @right_ascension.sin +
            radial_velocity_component.aupd * @declination.cos * @right_ascension.sin,
          proper_motion_dec_component * @declination.cos +
            radial_velocity_component.aupd * @declination.sin
        ])
      end
    end

    def time_elapsed_seconds
      @time_elapsed_seconds ||=
        (@instant.tt - @initial_epoch) * Constants::SECONDS_PER_DAY
    end
  end
end
