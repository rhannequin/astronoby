# frozen_string_literal: true

module Astronoby
  class Deflection
    # Solar gravitational constant (m^3/s^2)
    SOLAR_GRAVITATION_CONSTANT = 1.32712440017987e+20

    # @param instant [Astronoby::Instant] the instant of the observation
    # @param target_astrometric_position [Astronoby::Vector<Distance>] the
    #   astrometric position of the target
    # @param ephem [Astronoby::Ephemeris] the ephemeris to use for the
    #   computation
    def initialize(instant:, target_astrometric_position:, ephem:)
      @instant = instant
      @target_astrometric_position = target_astrometric_position
      @ephem = ephem
    end

    # @return [Astronoby::Vector<Distance>] corrected position of the target
    def corrected_position
      Astronoby::Vector[
        *(target_position + deflection_vector)
          .map { |au| Astronoby::Distance.from_au(au) }
      ]
    end

    private

    def tt
      @tt ||= @instant.tt
    end

    def earth_geometric
      Earth.compute_geometric(ephem: @ephem, instant: @instant)
    end

    def sun_geometric
      Sun.compute_geometric(ephem: @ephem, instant: @instant)
    end

    def observer_position
      @observer_position ||= earth_geometric.position.map(&:au)
    end

    def target_position
      @target_position ||= @target_astrometric_position.map(&:au)
    end

    def sun_position
      @sun_position ||= sun_geometric.position.map(&:au)
    end

    def light_travel_time
      @light_travel_time ||=
        target_position.magnitude / Astronoby::Velocity.light_speed.aupd
    end

    def deflector_to_observer_position
      sun_position - observer_position
    end

    def closest_deflector_to_target_position
      observer_position + target_position - deflector_position_at_closest
    end

    def closest_deflector_to_observer_position
      @closest_deflector_to_observer_position ||=
        observer_position - deflector_position_at_closest
    end

    # Compute light-time difference for the point where light ray is closest to
    # deflector
    def closest_approach_time_diff
      @closest_approach_time_diff ||=
        Util::Maths.dot_product(
          target_position / target_position.magnitude,
          deflector_to_observer_position
        ) / Astronoby::Velocity.light_speed.aupd
    end

    # Determine time when incoming photons were closest to the deflecting body
    def time_at_closest_approach
      @time_at_closest_approach ||= if closest_approach_time_diff > 0.0
        tt - closest_approach_time_diff
      elsif light_travel_time < closest_approach_time_diff
        tt - light_travel_time
      else
        tt
      end
    end

    # Get position of deflecting body at the time of closest approach
    def deflector_position_at_closest
      @deflector_position_at_closest ||=
        Sun.compute_geometric(
          ephem: @ephem,
          instant: Instant.from_terrestrial_time(time_at_closest_approach)
        ).position.map(&:au)
    end

    def observer_to_target_distance
      @observer_to_target_distance ||= target_position.magnitude
    end

    def closest_deflector_to_target_distance
      @closest_deflector_to_target_distance ||=
        closest_deflector_to_target_position.magnitude
    end

    def closest_deflector_to_observer_distance
      @closest_deflector_to_observer_distance ||=
        closest_deflector_to_observer_position.magnitude
    end

    def observer_to_target_unit
      @observer_to_target_unit ||=
        target_position / observer_to_target_distance
    end

    def closest_deflector_to_target_unit
      @closest_deflector_to_target_unit ||=
        closest_deflector_to_target_position / closest_deflector_to_target_distance
    end

    def closest_deflector_to_observer_unit
      @closest_deflector_to_observer_unit ||=
        closest_deflector_to_observer_position / closest_deflector_to_observer_distance
    end

    def cos_angle_target
      Util::Maths.dot_product(
        observer_to_target_unit,
        closest_deflector_to_target_unit
      )
    end

    def cos_angle_deflector
      Util::Maths.dot_product(
        closest_deflector_to_target_unit,
        closest_deflector_to_observer_unit
      )
    end

    def cos_angle_observer
      @cos_angle_observer ||= Util::Maths.dot_product(
        closest_deflector_to_observer_unit,
        observer_to_target_unit
      )
    end

    # Calculate the relativistic deflection coefficient
    # This implements Einstein's light deflection formula: α = 4GM/(c²r)
    # where:
    # - G is the gravitational constant
    # - M is the mass of the deflecting body
    # - c is the speed of light
    # - r is the impact parameter (closest approach distance)
    def relativistic_factor
      2.0 * SOLAR_GRAVITATION_CONSTANT / (
        Astronoby::Velocity.light_speed.mps *
          Astronoby::Velocity.light_speed.mps *
          closest_deflector_to_observer_distance *
          Constants::ASTRONOMICAL_UNIT_IN_METERS
      )
    end

    def geometry_factor
      1.0 + cos_angle_deflector
    end

    def deflection_vector
      return 0 if colinear?

      relativistic_factor *
        (
          cos_angle_target * closest_deflector_to_observer_unit -
            cos_angle_observer * closest_deflector_to_target_unit
        ) / geometry_factor * observer_to_target_distance
    end

    # If deflector is nearly in line with target, make no correction
    # (avoids numerical instability in nearly-collinear cases)
    def colinear?
      cos_angle_observer.abs > 0.99999999999
    end
  end
end
