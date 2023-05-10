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
      Astronoby::Angle.as_dms(
        0,
        0,
        (
          -17.2 * Math.sin(moon_ascending_node_longitude.to_radians.value) -
          1.3 * Math.sin(2 * sun_mean_longitude.to_radians.value)
        )
      )
    end

    def for_obliquity_of_the_ecliptic
      Astronoby::Angle.as_dms(
        0,
        0,
        (
          9.2 * Math.cos(moon_ascending_node_longitude.to_radians.value) +
          0.5 * Math.cos(2 * sun_mean_longitude.to_radians.value)
        )
      )
    end

    private

    def julian_centuries
      (@epoch - Astronoby::Epoch::J1900)./(
        Astronoby::Epoch::DAYS_PER_JULIAN_CENTURY
      )
    end

    def sun_mean_longitude
      Astronoby::Angle.as_degrees((279.6967 + 360.0 * (a - a.to_i)) % 360)
    end

    def moon_ascending_node_longitude
      Astronoby::Angle.as_degrees((259.1833 - 360.0 * (b - b.to_i)) % 360)
    end

    def a
      100.002136 * julian_centuries
    end

    def b
      5.372617 * julian_centuries
    end
  end
end
