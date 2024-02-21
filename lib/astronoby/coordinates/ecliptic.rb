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
        mean_obliquity = MeanObliquity.for_epoch(epoch)
        obliquity = mean_obliquity.value

        y = Angle.as_radians(
          @longitude.sin * obliquity.cos - @latitude.tan * obliquity.sin
        )
        x = Angle.as_radians(@longitude.cos)
        r = Angle.atan(y.radians / x.radians)
        right_ascension = Util::Trigonometry.adjustement_for_arctangent(y, x, r)

        declination = Angle.asin(
          @latitude.sin * obliquity.cos +
          @latitude.cos * obliquity.sin * @longitude.sin
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
