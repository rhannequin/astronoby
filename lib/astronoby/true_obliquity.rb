# frozen_string_literal: true

module Astronoby
  class TrueObliquity
    def initialize(obliquity)
      @obliquity = obliquity
    end

    def self.for_epoch(epoch)
      mean_obliquity = Astronoby::MeanObliquity.for_epoch(epoch)
      nutation = Astronoby::Nutation.for_obliquity_of_the_ecliptic(epoch: epoch)

      new(
        Astronoby::Angle.as_degrees(
          mean_obliquity.value.to_degrees.value + nutation.to_degrees.value
        )
      )
    end

    def value
      @obliquity
    end
  end
end
