# frozen_string_literal: true

module Astronoby
  class TrueObliquity
    def self.for_epoch(epoch)
      mean_obliquity = MeanObliquity.for_epoch(epoch)
      nutation = Nutation.for_obliquity_of_the_ecliptic(epoch: epoch)

      mean_obliquity + nutation
    end
  end
end
