# frozen_string_literal: true

require "date"

module Astronoby
  class MeanObliquity
    # Source:
    #  IAU resolution in 2006 in favor of the P03 astronomical model
    #  The Astronomical Almanac for 2010

    EPOCH_OF_REFERENCE = Astronoby::Epoch::DEFAULT_EPOCH
    OBLIQUITY_OF_REFERENCE = 23.4392794

    def initialize(obliquity)
      @obliquity = obliquity
    end

    def self.for_epoch(epoch)
      if epoch == EPOCH_OF_REFERENCE
        return new(obliquity_of_reference)
      end

      t = (epoch - EPOCH_OF_REFERENCE)./(
        Astronoby::Epoch::DAYS_PER_JULIAN_CENTURY
      )

      new(
        Astronoby::Angle.as_degrees(
          obliquity_of_reference.value - (
            46.815 * t -
            0.0006 * t * t +
            0.00181 * t * t * t
          ) / 3600
        )
      )
    end

    def self.obliquity_of_reference
      Astronoby::Angle.as_dms(23, 26, 21.45)
    end

    def value
      @obliquity
    end
  end
end
