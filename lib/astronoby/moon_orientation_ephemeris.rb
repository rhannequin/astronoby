# frozen_string_literal: true

module Astronoby
  # Computes the Moon's libration and the position angle of its axis from a
  # binary PCK lunar orientation kernel, as the arcsecond-accurate counterpart
  # to the analytic Meeus series in MoonPhysicalEphemeris.
  #
  # The libration is the selenographic longitude and latitude of the sub-Earth
  # point, expressed in the Moon's mean-Earth body-fixed frame.
  class MoonOrientationEphemeris
    # @param moon [Astronoby::Moon] the Moon, carrying an orientation kernel
    def initialize(moon)
      @moon = moon
      @instant = moon.instant
      @orientation = moon.orientation
    end

    # @return [Astronoby::Libration] the libration in longitude and latitude
    def libration
      sub_earth = rotation * moon_to_earth
      Libration.new(
        longitude: Angle.from_radians(Math.atan2(sub_earth[1], sub_earth[0])),
        latitude: Angle.from_radians(
          Math.asin(sub_earth[2] / sub_earth.magnitude)
        )
      )
    end

    # Position angle of the Moon's axis of rotation, measured eastward from the
    # north point of the disk.
    # @return [Astronoby::Angle] the position angle of the axis
    def position_angle_of_axis
      @moon.apparent.equatorial.position_angle_to(north_pole)
    end

    private

    def rotation
      @rotation ||= @orientation.rotation_for(retarded_instant)
    end

    def retarded_instant
      Instant.from_terrestrial_time(
        @instant.terrestrial_time - light_time_in_days
      )
    end

    def light_time_in_days
      @moon.astrometric.distance.km /
        Velocity.light_speed.kmps /
        Constants::SECONDS_PER_DAY
    end

    def moon_to_earth
      x, y, z = @moon.astrometric.position.map(&:m).to_a
      ::Vector[-x, -y, -z]
    end

    def north_pole
      @north_pole ||= Coordinates::Equatorial.from_position_vector(
        Distance.vector_from_meters(
          Nutation.matrix_for(@instant) *
            Precession.matrix_for(@instant) *
            (rotation.transpose * ::Vector[0, 0, 1])
        )
      )
    end
  end
end
