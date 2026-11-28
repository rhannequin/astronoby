# frozen_string_literal: true

module Astronoby
  # Represents a deep-sky object (star, galaxy, nebula, etc.) with optional
  # proper motion and parallax data.
  class DeepSkyObject
    include Body

    # @param equatorial_coordinates [Astronoby::Coordinates::Equatorial]
    #   Equatorial coordinates at epoch J2000.0
    # @param proper_motion_ra [Astronoby::AngularVelocity, nil] Proper motion in
    #   right ascension
    # @param proper_motion_dec [Astronoby::AngularVelocity, nil] Proper motion
    #   in declination
    # @param parallax [Astronoby::Angle, nil] Parallax angle
    # @param radial_velocity [Astronoby::Velocity, nil] Radial velocity
    def initialize(
      equatorial_coordinates:,
      proper_motion_ra: nil,
      proper_motion_dec: nil,
      parallax: nil,
      radial_velocity: nil
    )
      @initial_equatorial_coordinates = equatorial_coordinates
      @proper_motion_ra = proper_motion_ra
      @proper_motion_dec = proper_motion_dec
      @parallax = parallax
      @radial_velocity = radial_velocity
    end

    # @return [Astronoby::Coordinates::Equatorial] equatorial coordinates at
    #   epoch J2000.0
    def equatorial_coordinates
      @initial_equatorial_coordinates
    end

    # @param instant [Astronoby::Instant] Instant of the observation
    # @param ephem [Astronoby::Ephemeris, nil] Ephemeris to use for Earth
    #   position calculation, deprecated: use {Astronoby::Sky#[]} instead
    # @return [Astronoby::DeepSkyObjectPosition] Position of the deep-sky object
    #   at the given instant
    def at(instant, ephem: nil)
      if ephem
        Deprecation.warn(DeepSkyObject, :at) do
          [
            "Astronoby::DeepSkyObject#at(instant, ephem:)",
            "sky[deep_sky_object].at(instant)"
          ]
        end
      end
      position_at(instant, ephem: ephem)
    end

    # @api private
    def position_at(instant, ephem:)
      DeepSkyObjectPosition.new(
        instant: instant,
        equatorial_coordinates: @initial_equatorial_coordinates,
        ephem: ephem,
        proper_motion_ra: @proper_motion_ra,
        proper_motion_dec: @proper_motion_dec,
        parallax: @parallax,
        radial_velocity: @radial_velocity,
        deep_sky_object: self
      )
    end
  end
end
