# frozen_string_literal: true

module Astronoby
  # Applies the Sun's gravitational light deflection to an astrometric
  # position.
  class Deflection
    # Source:
    #  Title: Explanatory Supplement to the Astronomical Almanac
    #  Authors: Sean E. Urban and P. Kenneth Seidelmann
    #  Edition: University Science Books
    #  Chapter: 7.2.2 - Light Deflection

    # Solar gravitational constant (m^3/s^2)
    SOLAR_GRAVITATION_CONSTANT = 1.32712440017987e+20

    LIGHT_SPEED = Velocity.light_speed.mps

    # Cosine of the Sun-observer-target angle above which the target is
    # considered in line with the Sun, where the formula becomes unstable and
    # no correction is applied
    COLINEARITY_THRESHOLD = 0.99999999999

    SUN_RADIUS = Sun::EQUATORIAL_RADIUS.meters

    # @param target_astrometric_position [Astronoby::Vector<Distance>] the
    #   astrometric position of the target, relative to the observer
    # @param observer_position [Astronoby::Vector<Distance>] barycentric
    #   position of the observer
    # @param sun_position [Astronoby::Vector<Distance>] barycentric position of
    #   the Sun at the observation instant
    def initialize(
      target_astrometric_position:,
      observer_position:,
      sun_position:
    )
      @target_astrometric_position = target_astrometric_position
      @observer_position = observer_position
      @sun_position = sun_position
    end

    # @return [Astronoby::Vector<Distance>] corrected position of the target
    def corrected_position
      px, py, pz = @target_astrometric_position.map(&:m).to_a
      distance = Math.sqrt(px * px + py * py + pz * pz)
      return @target_astrometric_position if distance.zero?

      # The Sun is taken at the observation instant rather than when the light
      # passed closest to it. Over the few minutes in between it moves by less
      # than 7 km, which changes the deflection by less than 0.0001 mas.
      ox, oy, oz = @observer_position.map(&:m).to_a
      sx, sy, sz = @sun_position.map(&:m).to_a

      # Unit vectors from observer to target (u), Sun to target (q) and Sun to
      # observer (e)
      ux = px / distance
      uy = py / distance
      uz = pz / distance

      ex = ox - sx
      ey = oy - sy
      ez = oz - sz
      sun_to_observer_distance = Math.sqrt(ex * ex + ey * ey + ez * ez)
      ex /= sun_to_observer_distance
      ey /= sun_to_observer_distance
      ez /= sun_to_observer_distance

      cos_observer = ex * ux + ey * uy + ez * uz
      return @target_astrometric_position if
        cos_observer.abs > COLINEARITY_THRESHOLD

      qx = ex * sun_to_observer_distance + px
      qy = ey * sun_to_observer_distance + py
      qz = ez * sun_to_observer_distance + pz
      sun_to_target_distance = Math.sqrt(qx * qx + qy * qy + qz * qz)
      qx /= sun_to_target_distance
      qy /= sun_to_target_distance
      qz /= sun_to_target_distance

      cos_target = ux * qx + uy * qy + uz * qz
      cos_sun = qx * ex + qy * ey + qz * ez

      factor = 2.0 * SOLAR_GRAVITATION_CONSTANT /
        (LIGHT_SPEED * LIGHT_SPEED * sun_to_observer_distance) /
        (1.0 + cos_sun) * distance

      # Light from a target behind the solar disk never reaches the observer,
      # and the formula grows without bound towards the centre of the disk.
      # Fading it to zero from the limb keeps the position continuous.
      closest_approach = -cos_observer * sun_to_observer_distance
      if closest_approach.positive? && distance > closest_approach
        impact_parameter = sun_to_observer_distance *
          Math.sqrt(1.0 - cos_observer * cos_observer)
        if impact_parameter < SUN_RADIUS
          factor *= (impact_parameter / SUN_RADIUS)**2
        end
      end

      Distance.vector_from_meters([
        px + factor * (cos_target * ex - cos_observer * qx),
        py + factor * (cos_target * ey - cos_observer * qy),
        pz + factor * (cos_target * ez - cos_observer * qz)
      ])
    end
  end
end
