# frozen_string_literal: true

require "matrix"

module Astronoby
  class Precession
    def self.for_equatorial_coordinates(coordinates:, epoch:)
      new(coordinates, epoch).precess
    end

    def initialize(coordinates, epoch)
      @coordinates = coordinates
      @epoch = epoch
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 34 - Precession
    def precess
      right_ascension = @coordinates.right_ascension.to_radians.value
      declination = @coordinates.declination.to_radians.value
      matrix_a = matrix_for_epoch(@coordinates.epoch)
      matrix_b = matrix_for_epoch(@epoch).transpose

      vector = Vector[
        Math.cos(right_ascension) * Math.cos(declination),
        Math.sin(right_ascension) * Math.cos(declination),
        Math.sin(declination)
      ]

      s = matrix_a * vector
      w = matrix_b * s

      Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Util::Trigonometry.adjustement_for_arctangent(
          Astronoby::Angle.as_radians(w[1]),
          Astronoby::Angle.as_radians(w[0]),
          Astronoby::Angle.as_radians(Math.atan(w[1] / w[0]))
        ),
        declination: Astronoby::Angle.as_radians(Math.asin(w[2])).to_degrees,
        epoch: @epoch
      )
    end

    private

    def matrix_for_epoch(epoch)
      t = (epoch - Astronoby::Epoch::DEFAULT_EPOCH)./(
        Astronoby::Epoch::DAYS_PER_JULIAN_CENTURY
      )

      ζ = Astronoby::Angle.as_degrees(
        0.6406161 * t + 0.0000839 * t * t + 0.000005 * t * t * t
      ).to_radians.value
      z = Astronoby::Angle.as_degrees(
        0.6406161 * t + 0.0003041 * t * t + 0.0000051 * t * t * t
      ).to_radians.value
      θ = Astronoby::Angle.as_degrees(
        0.5567530 * t - 0.0001185 * t * t - 0.0000116 * t * t * t
      ).to_radians.value

      cx = Math.cos(ζ)
      sx = Math.sin(ζ)
      cz = Math.cos(z)
      sz = Math.sin(z)
      ct = Math.cos(θ)
      st = Math.sin(θ)

      Matrix[
        [
          cx * ct * cz - sx * sz,
          cx * ct * sz + sx * cz,
          cx * st
        ],
        [
          -sx * ct * cz - cx * sz,
          -sx * ct * sz + cx * cz,
          -sx * st
        ],
        [
          -st * cz,
          -st * sz,
          ct
        ]
      ]
    end
  end
end
