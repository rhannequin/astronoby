# frozen_string_literal: true

module Astronoby
  class TrueObliquity
    def self.at(instant)
      mean_obliquity = MeanObliquity.at(instant)
      nutation = Nutation.new(instant: instant).nutation_in_obliquity

      mean_obliquity + nutation
    end
  end
end
