# frozen_string_literal: true

require "date"

module Astronoby
  class Obliquity
    # Source:
    #  IAU resolution in 2006 in favor of the P03 astronomical model
    #  The Astronomical Almanac for 2010

    EPOCH_OF_REFERENCE = 2000
    OBLIQUITY_OF_REFERENCE = 23.4392794

    def initialize(obliquity)
      @obliquity = obliquity
    end

    def self.for_epoch(epoch)
      if epoch == EPOCH_OF_REFERENCE
        return new(Astronoby::Angle.as_degrees(OBLIQUITY_OF_REFERENCE))
      end

      epoch_julian_day_number = ::DateTime.new(epoch, 1, 1, 0, 0, 0).ajd - 1
      julian_centuries_since_reference = (epoch_julian_day_number - 2451545) / 36525.0
      t = julian_centuries_since_reference

      new(
        Astronoby::Angle.as_degrees(
          OBLIQUITY_OF_REFERENCE - (
            46.836769 * t -
            0.0001831 * t * t +
            0.00200340 * t * t * t -
            5.76e-7 * t * t * t * t -
            4.34e-8 * t * t * t * t * t
          ) / 3600
        )
      )
    end

    def value
      @obliquity
    end
  end
end
