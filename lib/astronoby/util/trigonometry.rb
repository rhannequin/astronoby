# frozen_string_literal: true

module Astronoby
  module Util
    module Trigonometry
      class << self
        # Source:
        #  Title: Celestial Calculations
        #  Author: J. L. Lawrence
        #  Edition: MIT Press
        #  Chapter: 4 - Orbits and Coordinate Systems
        def adjustement_for_arctangent(y, x, angle)
          return angle if y.positive? && x.positive?

          if y.negative? && x.positive?
            return Angle.from_degrees(
              angle.degrees + Constants::DEGREES_PER_CIRCLE
            )
          end

          Angle.from_degrees(angle.degrees + Constants::DEGREES_PER_CIRCLE / 2)
        end
      end
    end
  end
end
