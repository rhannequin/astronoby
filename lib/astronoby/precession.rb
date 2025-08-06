# frozen_string_literal: true

module Astronoby
  class Precession
    def self.matrix_for(instant)
      new(instant: instant).matrix
    end

    def initialize(instant:)
      @instant = instant
    end

    def matrix
      # Source:
      #  IAU resolution in 2006 in favor of the P03 astronomical model
      #  https://syrte.obspm.fr/iau2006/aa03_412_P03.pdf
      # P(t) = R3(χA) R1(−ωA) R3(−ψA) R1(ϵ0)

      cache.fetch(cache_key) do
        # Precession in right ascension
        psi_a = ((((
            -0.0000000951 * t +
            +0.000132851) * t +
            -0.00114045) * t +
            -1.0790069) * t +
            +5038.481507) * t

        # Precession in declination
        omega_a = ((((
          +0.0000003337 * t +
          -0.000000467) * t +
          -0.00772503) * t +
          +0.0512623) * t +
          -0.025754) * t +
          eps0

        # Precession of the ecliptic
        chi_a = ((((
          -0.0000000560 * t +
          +0.000170663) * t +
          -0.00121197) * t +
          -2.3814292) * t +
          +10.556403) * t

        psi_a = Angle.from_degree_arcseconds(psi_a)
        omega_a = Angle.from_degree_arcseconds(omega_a)
        chi_a = Angle.from_degree_arcseconds(chi_a)

        r3_psi = rotation_z(-psi_a)
        r1_omega = rotation_x(-omega_a)
        r3_chi = rotation_z(chi_a)
        r1_eps0 = rotation_x(MeanObliquity.obliquity_of_reference)

        r3_chi * r1_omega * r3_psi * r1_eps0
      end
    end

    def rotation_x(angle)
      c, s = angle.cos, angle.sin
      Matrix[
        [1, 0, 0],
        [0, c, s],
        [0, -s, c]
      ]
    end

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

    def self.for_equatorial_coordinates(coordinates:, epoch:)
      precess(coordinates, epoch)
    end

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

    def eps0
      @eps0 ||= MeanObliquity.obliquity_of_reference_in_milliarcseconds
    end
  end
end
