# frozen_string_literal: true

require "bigdecimal/math"

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
            return Angle.as_degrees(angle.degrees + 360)
          end

          Angle.as_degrees(angle.degrees + 180)
        end
      end
    end
  end
end
