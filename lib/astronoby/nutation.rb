# frozen_string_literal: true

module Astronoby
  class Nutation
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 35 - Nutation

    def initialize(epoch)
      @epoch = epoch
    end

    def self.for_ecliptic_longitude(epoch:)
      new(epoch).for_ecliptic_longitude
    end

    def self.for_obliquity_of_the_ecliptic(epoch:)
      new(epoch).for_obliquity_of_the_ecliptic
    end

    def for_ecliptic_longitude
      Angle.from_dms(
        0,
        0,
        (
          -17.2 * moon_ascending_node_longitude.sin -
          1.3 * Math.sin(2 * sun_mean_longitude.radians)
        )
      )
    end

    def for_obliquity_of_the_ecliptic
      Angle.from_dms(
        0,
        0,
        (
          9.2 * moon_ascending_node_longitude.cos +
          0.5 * Math.cos(2 * sun_mean_longitude.radians)
        )
      )
    end

    private

    def julian_centuries
      (@epoch - Epoch::J1900) / Constants::DAYS_PER_JULIAN_CENTURY
    end

    def sun_mean_longitude
      Angle.from_degrees(
        (279.6967 + Constants::DEGREES_PER_CIRCLE * (centuries_a - centuries_a.to_i)) %
          Constants::DEGREES_PER_CIRCLE
      )
    end

    def moon_ascending_node_longitude
      Angle.from_degrees(
        (259.1833 - Constants::DEGREES_PER_CIRCLE * (centuries_b - centuries_b.to_i)) %
          Constants::DEGREES_PER_CIRCLE
      )
    end

    def centuries_a
      100.002136 * julian_centuries
    end

    def centuries_b
      5.372617 * julian_centuries
    end
  end
end
