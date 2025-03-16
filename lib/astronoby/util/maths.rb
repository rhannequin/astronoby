# frozen_string_literal: true

module Astronoby
  module Util
    module Maths
      class << self
        def dot_product(a, b)
          a.zip(b).sum { |x, y| x * y }
        end
      end
    end
  end
end
