# frozen_string_literal: true

module Astronoby
  module Horizon
    # @return [Astronoby::Angle] altitude of the centre of a point-like body at
    #   rise and set
    REFRACTION_ANGLE = -Angle.from_dms(0, 34, 0)

    # @return [Astronoby::Angle] altitude of the Sun's centre at rise and set
    SUN_ANGLE = -Angle.from_dms(0, 50, 0)

    class << self
      # @param body [Class] the body rising or setting
      # @param distance [Astronoby::Distance] distance to the body, used for
      #   the Moon's semidiameter
      # @return [Astronoby::Angle] altitude of the body's centre at rise and set
      def angle_for(body:, distance:)
        if body == Sun
          SUN_ANGLE
        elsif body == Moon
          REFRACTION_ANGLE - moon_semidiameter(distance)
        else
          REFRACTION_ANGLE
        end
      end

      # @param distance [Astronoby::Distance] distance to the Moon
      # @return [Astronoby::Angle] the Moon's semidiameter
      def moon_semidiameter(distance)
        Angle.from_radians(moon_semidiameter_radians(distance.m))
      end

      # @param distance_in_meters [Numeric] distance to the Moon in meters
      # @return [Float] the Moon's semidiameter in radians
      def moon_semidiameter_radians(distance_in_meters)
        Moon::EQUATORIAL_RADIUS.m.to_f / distance_in_meters
      end
    end
  end
end
