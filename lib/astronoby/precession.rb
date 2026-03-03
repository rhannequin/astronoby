# frozen_string_literal: true

module Astronoby
  # Computes precession matrices using the IAU 2006 Fukushima-Williams
  # angles with ICRS frame bias. Also provides coordinate precession
  # using the classical method.
  class Precession
    # Computes the combined precession-bias matrix for a given instant.
    #
    # @param instant [Astronoby::Instant] the time instant
    # @return [Matrix] the 3x3 precession-bias matrix PB(t)
    def self.matrix_for(instant)
      new(instant: instant).matrix
    end

    # @param instant [Astronoby::Instant] the time instant
    def initialize(instant:)
      @instant = instant
    end

    # Computes the combined precession-bias matrix PB(t) = R1(-εA) R3(-ψ̄) R1(φ̄) R3(γ̄)
    #
    # @return [Matrix] the 3x3 precession-bias matrix
    def matrix
      # Fukushima-Williams precession angles including frame bias.
      # Source:
      #  IERS Conventions 2010, Section 5.6.4
      #  Wallace & Capitaine (2006), A&A 459, 981
      #  ERFA eraPfw06 / eraFw2m
      # PB(t) = R1(−εA) R3(−ψ̄) R1(φ̄) R3(γ̄)

      cache.fetch(cache_key) do
        gamma_bar = ((((
          +0.0000000260 * t +
          -0.000002788) * t +
          -0.00031238) * t +
          +0.4932044) * t +
          +10.556378) * t +
          -0.052928

        phi_bar = ((((
          -0.0000000176 * t +
          -0.000000440) * t +
          +0.00053289) * t +
          +0.0511268) * t +
          -46.811016) * t +
          +84381.412819

        psi_bar = ((((
          -0.0000000148 * t +
          -0.000026452) * t +
          -0.00018522) * t +
          +1.5584175) * t +
          +5038.481484) * t +
          -0.041775

        gamma_bar = Angle.from_degree_arcseconds(gamma_bar)
        phi_bar = Angle.from_degree_arcseconds(phi_bar)
        psi_bar = Angle.from_degree_arcseconds(psi_bar)
        eps_a = MeanObliquity.at(@instant)

        rotation_x(-eps_a) * rotation_z(-psi_bar) *
          rotation_x(phi_bar) * rotation_z(gamma_bar)
      end
    end

    # Rotation matrix around the x-axis.
    #
    # @param angle [Astronoby::Angle] the rotation angle
    # @return [Matrix] 3x3 rotation matrix
    def rotation_x(angle)
      c, s = angle.cos, angle.sin
      Matrix[
        [1, 0, 0],
        [0, c, s],
        [0, -s, c]
      ]
    end

    # Rotation matrix around the z-axis.
    #
    # @param angle [Astronoby::Angle] the rotation angle
    # @return [Matrix] 3x3 rotation matrix
    def rotation_z(angle)
      c, s = angle.cos, angle.sin
      Matrix[
        [c, s, 0],
        [-s, c, 0],
        [0, 0, 1]
      ]
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 34 - Precession

    # Precesses equatorial coordinates from their current epoch to a new epoch.
    #
    # @param coordinates [Astronoby::Coordinates::Equatorial] coordinates to
    #   precess
    # @param epoch [Numeric] the target Julian Date epoch
    # @return [Astronoby::Coordinates::Equatorial] precessed coordinates
    def self.for_equatorial_coordinates(coordinates:, epoch:)
      precess(coordinates, epoch)
    end

    # @param coordinates [Astronoby::Coordinates::Equatorial] coordinates to
    #   precess
    # @param epoch [Numeric] the target Julian Date epoch
    # @return [Astronoby::Coordinates::Equatorial] precessed coordinates
    def self.precess(coordinates, epoch)
      matrix_a = matrix_for_epoch(coordinates.epoch)
      matrix_b = matrix_for_epoch(epoch).transpose

      vector = Vector[
        coordinates.right_ascension.cos * coordinates.declination.cos,
        coordinates.right_ascension.sin * coordinates.declination.cos,
        coordinates.declination.sin
      ]

      s = matrix_a * vector
      w = matrix_b * s

      Coordinates::Equatorial.new(
        right_ascension: Util::Trigonometry.adjustement_for_arctangent(
          Angle.from_radians(w[1]),
          Angle.from_radians(w[0]),
          Angle.atan(w[1] / w[0])
        ),
        declination: Angle.asin(w[2]),
        epoch: epoch
      )
    end

    # Computes the classical precession matrix for a given epoch.
    #
    # @param epoch [Numeric] a Julian Date epoch
    # @return [Matrix] 3x3 precession matrix
    def self.matrix_for_epoch(epoch)
      t = (epoch - JulianDate::DEFAULT_EPOCH) / Constants::DAYS_PER_JULIAN_CENTURY

      zeta = Angle.from_degrees(
        0.6406161 * t + 0.0000839 * t * t + 0.000005 * t * t * t
      )
      z = Angle.from_degrees(
        0.6406161 * t + 0.0003041 * t * t + 0.0000051 * t * t * t
      )
      theta = Angle.from_degrees(
        0.5567530 * t - 0.0001185 * t * t - 0.0000116 * t * t * t
      )

      cx = zeta.cos
      sx = zeta.sin
      cz = z.cos
      sz = z.sin
      ct = theta.cos
      st = theta.sin

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

    private

    def cache_key
      @_cache_key ||= CacheKey.generate(:precession, @instant)
    end

    def cache
      Astronoby.cache
    end

    def t
      @t ||= Rational(
        @instant.tdb - JulianDate::DEFAULT_EPOCH,
        Constants::DAYS_PER_JULIAN_CENTURY
      )
    end
  end
end
