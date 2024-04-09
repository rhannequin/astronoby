# frozen_string_literal: true

module Astronoby
  module Util
    module Maths
      class << self
        # Source:
        #  Title: Astronomical Algorithms
        #  Author: Jean Meeus
        #  Edition: 2nd edition
        #  Chapter: 3 - Interpolation

        # @param values [Array<Numeric>] First term
        # @param factor [Numeric] Interpolation factor
        # @return [Float] Interpolated value
        def interpolate(values, factor)
          unless factor.between?(0, 1)
            raise IncompatibleArgumentsError,
              "Interpolation factor must be between 0 and 1"
          end

          if values.length == 3
            return interpolate_3_terms(values, factor)
          elsif values.length == 5
            return interpolate_5_terms(values, factor)
          end

          raise IncompatibleArgumentsError,
            "Only 3 or 5 terms are supported for interpolation"
        end

        private

        # @return [Float] Interpolated value
        def interpolate_3_terms(terms, factor)
          y1, y2, y3 = terms

          a = y2 - y1
          b = y3 - y2
          c = b - a

          y2 + (factor / 2.0) * (a + b + factor * c)
        end

        # @return [Float] Interpolated value
        def interpolate_5_terms(terms, factor)
          y1, y2, y3, y4, y5 = terms

          a = y2 - y1
          b = y3 - y2
          c = y4 - y3
          d = y5 - y4

          e = b - a
          f = c - b
          g = d - c

          h = f - e
          j = g - f

          k = j - h

          y3 +
            factor * ((b + c) / 2.0 - (h + j) / 12.0) +
            factor**2 * (f / 2.0 - k / 24.0) +
            factor**3 * (h + j) / 12.0 +
            factor**4 * k / 24.0
        end
      end
    end
  end
end
