# frozen_string_literal: true

module Astronoby
  # Applies relativistic aberration corrections to an astrometric position based
  # on observer velocity.
  # TODO: This will be renamed into Aberration after full refactoring
  class Aberration2
    # Source:
    #  Title: Explanatory Supplement to the Astronomical Almanac
    #  Authors: Sean E. Urban and P. Kenneth Seidelmann
    #  Edition: University Science Books
    #  Chapter: 7.2.3 - Aberration

    LIGHT_SPEED = Astronoby::Velocity.light_speed.aupd

    # Initializes the aberration correction with position and observer velocity.
    #
    # @param astrometric_position [Astronoby::Vector<Astronoby::Distance>] The
    #   astrometric position vector.
    # @param observer_velocity [Astronoby::Vector<Astronoby::Velocity>] The
    #   velocity vector of the observer.
    def initialize(astrometric_position:, observer_velocity:)
      @position = astrometric_position
      @velocity = observer_velocity
      @distance_au = @position.map(&:au).norm
      @observer_speed = @velocity.map(&:aupd).norm
    end

    # Computes the aberration-corrected position.
    #
    # @return [Astronoby::Vector<Astronoby::Distance>] The corrected position
    #   vector.
    def corrected_position
      beta = @observer_speed / LIGHT_SPEED
      projected_velocity = beta * aberration_angle_cos
      lorentz_factor_inv = lorentz_factor_inverse(beta)

      velocity_correction =
        velocity_correction_factor(projected_velocity) * velocity_aupd
      normalization_factor = 1.0 + projected_velocity
      position_scaled = position_au * lorentz_factor_inv

      to_position_vector(
        (position_scaled + velocity_correction) / normalization_factor
      )
    end

    private

    def aberration_angle_cos
      dot_product = position_au.zip(velocity_aupd).sum { |p, v| p * v }
      denominator = [@distance_au * @observer_speed, 1e-20].max
      dot_product / denominator
    end

    def position_au
      @position.map(&:au)
    end

    def velocity_aupd
      @velocity.map(&:aupd)
    end

    def lorentz_factor_inverse(beta)
      Math.sqrt(1.0 - beta**2)
    end

    def velocity_correction_factor(projected_velocity)
      lorentz_inv = lorentz_factor_inverse(projected_velocity)
      (1.0 + projected_velocity / (1.0 + lorentz_inv)) * (@distance_au / LIGHT_SPEED)
    end

    def to_position_vector(vector)
      Astronoby::Vector[*vector.map { |v| Astronoby::Distance.from_au(v) }]
    end
  end
end
