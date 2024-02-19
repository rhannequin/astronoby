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
          return angle if y.degrees.positive? && x.degrees.positive?

          if y.degrees.negative? && x.degrees.positive?
            return Astronoby::Angle.as_degrees(angle.degrees + 360)
          end

          Astronoby::Angle.as_degrees(angle.degrees + 180)
        end
      end
    end
  end
end
