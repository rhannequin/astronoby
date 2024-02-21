# frozen_string_literal: true

module Astronoby
  class TrueObliquity
    def initialize(obliquity)
      @obliquity = obliquity
    end

    def self.for_epoch(epoch)
      mean_obliquity = MeanObliquity.for_epoch(epoch)
      nutation = Nutation.for_obliquity_of_the_ecliptic(epoch: epoch)

      new(mean_obliquity.value + nutation)
    end

    def value
      @obliquity
    end
  end
end
