# frozen_string_literal: true

module Astronoby
  module Util
    module Astrodynamics
      class << self
        # Source:
        #  Title: Celestial Calculations
        #  Author: J. L. Lawrence
        #  Edition: MIT Press
        #  Chapter: 4 - Orbits and Coordinate Systems
        def eccentric_anomaly_newton_raphson(
          mean_anomaly,
          orbital_eccentricity,
          precision,
          maximum_iteration_count,
          current_iteration = 0,
          solution_on_previous_interation = nil
        )
          previous_solution = solution_on_previous_interation&.radians

          solution = if current_iteration == 0
            if orbital_eccentricity <= 0.75
              mean_anomaly.radians
            else
              Math::PI
            end
          else
            previous_solution - (
              (
                previous_solution -
                orbital_eccentricity * Math.sin(previous_solution) -
                mean_anomaly.radians
              ) / (
                1 - orbital_eccentricity * Math.cos(previous_solution)
              )
            )
          end

          if current_iteration >= maximum_iteration_count ||
              (
                solution_on_previous_interation &&
                (solution - previous_solution).abs <= precision
              )
            return Angle.as_radians(solution)
          end

          eccentric_anomaly_newton_raphson(
            mean_anomaly,
            orbital_eccentricity,
            precision,
            maximum_iteration_count,
            current_iteration + 1,
            Angle.as_radians(solution)
          )
        end
      end
    end
  end
end
