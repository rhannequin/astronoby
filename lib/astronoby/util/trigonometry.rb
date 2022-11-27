# frozen_string_literal: true

require "bigdecimal"

module Astronoby
  module Util
    module Trigonometry
      PRECISION = 10
      PI = BigMath.PI(PRECISION)

      class << self
        def to_radians(degrees_angle)
          degrees_angle * PI / BigDecimal("180")
        end

        def to_degrees(radians_angle)
          radians_angle * BigDecimal("180") / PI
        end
      end
    end
  end
end
