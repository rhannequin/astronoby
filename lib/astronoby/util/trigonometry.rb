# frozen_string_literal: true

require "bigdecimal/math"

module Astronoby
  module Util
    module Trigonometry
      PRECISION = 10
      PI = BigMath.PI(PRECISION)

      class << self
        # Source:
        #  Title: Celestial Calculations
        #  Author: J. L. Lawrence
        #  Edition: MIT Press
        #  Chapter: 4 - Orbits and Coordinate Systems
        def adjustement_for_arctangent(y, x, angle)
          return angle if y.value.positive? && x.value.positive?

          if y.value.negative? && x.value.positive?
            return Astronoby::Angle.as_degrees(angle.to_degrees.value + 360)
          end

          Astronoby::Angle.as_degrees(angle.to_degrees.value + 180)
        end
      end
    end
  end
end
