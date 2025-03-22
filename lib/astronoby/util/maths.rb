# frozen_string_literal: true

module Astronoby
  module Util
    module Maths
      module_function

      def dot_product(a, b)
        a.zip(b).sum { |x, y| x * y }
      end

      # Find maximum altitude using quadratic interpolation
      # @param t1, t2, t3 [Time] Three consecutive times
      # @param alt1, alt2, alt3 [Float] Corresponding altitudes
      # @return [::Time] Time of maximum altitude
      def quadratic_maximum(t1, t2, t3, alt1, alt2, alt3)
        # Convert to float seconds for arithmetic
        x1, x2, x3 = t1.to_f, t2.to_f, t3.to_f
        y1, y2, y3 = alt1, alt2, alt3

        # Quadratic interpolation formula
        denom = (x1 - x2) * (x1 - x3) * (x2 - x3)
        a = (x3 * (y2 - y1) + x2 * (y1 - y3) + x1 * (y3 - y2)) / denom
        b = (x3 * x3 * (y1 - y2) +
          x2 * x2 * (y3 - y1) +
          x1 * x1 * (y2 - y3)) / denom

        # Maximum is at -b/2a
        max_t = -b / (2 * a)

        ::Time.at(max_t)
      end

      # Linear interpolation between two points
      # @param x1 [Numeric] First x value
      # @param x2 [Numeric] Second x value
      # @param y1 [Numeric] First y value
      # @param y2 [Numeric] Second y value
      # @param target_y [Numeric] Target y value (default: 0)
      # @return [Numeric] Interpolated x value where y=target_y
      def self.linear_interpolate(x1, x2, y1, y2, target_y = 0)
        # Handle horizontal line case (avoid division by zero)
        if (y2 - y1).abs < 1e-10
          # If target_y matches the line's y-value (within precision), return
          # midpoint. Otherwise, return one of the endpoints (no unique solution
          # exists)
          return ((target_y - y1).abs < 1e-10) ? (x1 + x2) / 2.0 : x1
        end

        # Handle vertical line case
        if (x2 - x1).abs < 1e-10
          # For a vertical line, there's only one x-value possible
          return x1
        end

        # Standard linear interpolation formula
        x1 + (target_y - y1) * (x2 - x1) / (y2 - y1)
      end
    end
  end
end
