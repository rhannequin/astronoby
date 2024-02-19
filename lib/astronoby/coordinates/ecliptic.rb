# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Ecliptic
      attr_reader :latitude, :longitude

      def initialize(latitude:, longitude:)
        @latitude = latitude
        @longitude = longitude
      end

      # Source:
      #  Title: Celestial Calculations
      #  Author: J. L. Lawrence
      #  Edition: MIT Press
      #  Chapter: 4 - Orbits and Coordinate Systems
      def to_equatorial(epoch:)
        mean_obliquity = Astronoby::MeanObliquity.for_epoch(epoch)
        obliquity_in_radians = mean_obliquity.value.radians
        longitude_in_radians = @longitude.radians
        latitude_in_radians = @latitude.radians

        y = Astronoby::Angle.as_radians(
          Math.sin(longitude_in_radians) * Math.cos(obliquity_in_radians) -
          Math.tan(latitude_in_radians) * Math.sin(obliquity_in_radians)
        )
        x = Astronoby::Angle.as_radians(Math.cos(longitude_in_radians))
        r = Astronoby::Angle.as_radians(Math.atan(y.radians / x.radians))
        right_ascension = Astronoby::Angle.as_radians(
          Astronoby::Util::Trigonometry.adjustement_for_arctangent(y, x, r).radians
        )

        declination = Astronoby::Angle.as_radians(
          Math.asin(
            Math.sin(latitude_in_radians) * Math.cos(obliquity_in_radians) +
            Math.cos(latitude_in_radians) * Math.sin(obliquity_in_radians) * Math.sin(longitude_in_radians)
          )
        )

        Equatorial.new(
          right_ascension: right_ascension,
          declination: declination,
          epoch: epoch
        )
      end
    end
  end
end
