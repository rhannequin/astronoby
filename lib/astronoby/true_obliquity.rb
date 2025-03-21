# frozen_string_literal: true

module Astronoby
  class TrueObliquity
    def self.for_epoch(epoch)
      instant = Instant.from_utc_julian_date(epoch)
      mean_obliquity = MeanObliquity.for_epoch(epoch)
      nutation = Nutation.new(instant: instant).nutation_in_obliquity

      mean_obliquity + nutation
    end
  end
end
