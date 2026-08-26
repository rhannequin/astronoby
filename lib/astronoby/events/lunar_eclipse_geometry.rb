# frozen_string_literal: true

module Astronoby
  # The geometry of Earth's shadow and the Moon's place in it at one instant of
  # a lunar eclipse.
  #
  # The shadow cones are cut by the plane perpendicular to the shadow axis at
  # the Moon's distance, which is where their radii are published. Earth's
  # radius is enlarged by its atmosphere before the cones are built, so these
  # are the enlarged, observable radii.
  class LunarEclipseGeometry
    # @return [Astronoby::Distance] distance of the Moon's centre from the axis
    #   of Earth's shadow
    attr_reader :axis_distance

    # @return [Astronoby::Angle] position angle of the contact point on the
    #   Moon's limb, seen from the Moon's centre, from celestial north through
    #   east. This is the quantity IMCCE and NASA publish. At greatest eclipse,
    #   where there is no contact point, it is the direction from the shadow
    #   axis to the Moon, which is what they report there.
    attr_reader :position_angle

    # @return [Astronoby::Distance] radius of the umbra, the inner and total
    #   shadow, at the Moon's distance
    attr_reader :umbra_radius

    # @return [Astronoby::Distance] radius of the penumbra, the outer and
    #   partial shadow, at the Moon's distance
    attr_reader :penumbra_radius

    # @return [Astronoby::Distance] geocentric distance of the Moon, the
    #   distance of the plane the radii are measured in
    attr_reader :moon_distance

    # @param axis_distance [Astronoby::Distance] distance from the shadow axis
    # @param position_angle [Astronoby::Angle] position angle of the contact
    #   point on the Moon's limb, from celestial north through east
    # @param umbra_radius [Astronoby::Distance] umbra radius
    # @param penumbra_radius [Astronoby::Distance] penumbra radius
    # @param moon_distance [Astronoby::Distance] geocentric distance of the Moon
    def initialize(
      axis_distance:,
      position_angle:,
      umbra_radius:,
      penumbra_radius:,
      moon_distance:
    )
      @axis_distance = axis_distance
      @position_angle = position_angle
      @umbra_radius = umbra_radius
      @penumbra_radius = penumbra_radius
      @moon_distance = moon_distance
      freeze
    end

    # @return [Astronoby::Angle] angular distance of the Moon's centre from the
    #   axis of Earth's shadow
    def angular_axis_distance
      angular_radius_of(@axis_distance)
    end

    # @return [Astronoby::Angle] angular radius of the umbra
    def umbra_angular_radius
      angular_radius_of(@umbra_radius)
    end

    # @return [Astronoby::Angle] angular radius of the penumbra
    def penumbra_angular_radius
      angular_radius_of(@penumbra_radius)
    end

    # @return [Float] fraction of the Moon's diameter immersed in the umbra,
    #   negative when the Moon is clear of the umbra
    def umbral_magnitude
      magnitude_for(@umbra_radius)
    end

    # @return [Float] fraction of the Moon's diameter immersed in the penumbra,
    #   negative when the Moon is clear of the penumbra
    def penumbral_magnitude
      magnitude_for(@penumbra_radius)
    end

    private

    def angular_radius_of(distance)
      Angle.from_radians(Math.asin(distance.km / @moon_distance.km))
    end

    def magnitude_for(shadow_radius)
      moon_radius = Constants::IAU_MOON_RADIUS_IN_METERS / 1000.0
      (
        shadow_radius.km + moon_radius - @axis_distance.km
      ) / (2 * moon_radius)
    end
  end
end
