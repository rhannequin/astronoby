# frozen_string_literal: true

module Astronoby
  # Computes the true obliquity of the ecliptic (mean obliquity + nutation
  # in obliquity).
  class TrueObliquity
    # @param instant [Astronoby::Instant] the time instant
    # @return [Astronoby::Angle] the true obliquity
    def self.at(instant)
      mean_obliquity = MeanObliquity.at(instant)
      nutation = Nutation.new(instant: instant).nutation_in_obliquity

      mean_obliquity + nutation
    end
  end
end
