# frozen_string_literal: true

require "bigdecimal"

module Astronoby
  module Util
    module Trigonometry
      class << self
        def to_radians(degrees_angle)
          degrees_angle * Math::PI / BigDecimal("180")
        end

        def to_degrees(radians_angle)
          radians_angle * BigDecimal("180") / Math::PI
        end
      end
    end
  end
end
