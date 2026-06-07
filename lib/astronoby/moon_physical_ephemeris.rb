# frozen_string_literal: true

module Astronoby
  # Computes the ephemeris for physical observations of the Moon: the total
  # (optical + physical) libration in longitude and latitude, and the position
  # angle of the Moon's axis of rotation.
  #
  # Source:
  #  Title: Astronomical Algorithms
  #  Author: Jean Meeus
  #  Edition: 2nd edition
  #  Chapter: 53 - Ephemeris for Physical Observations of the Moon
  class MoonPhysicalEphemeris
    # Inclination of the mean lunar equator to the ecliptic
    INCLINATION = Angle.from_degrees(1.54242)

    # @param moon [Astronoby::Moon] the Moon at the desired instant
    def initialize(moon)
      @moon = moon
      @instant = moon.instant
    end

    # @return [Astronoby::Libration] the total libration in longitude and
    #   latitude
    def libration
      Libration.new(
        longitude: Angle.from_degrees(libration_in_longitude),
        latitude: Angle.from_degrees(libration_in_latitude)
      )
    end

    # @return [Astronoby::Angle] the position angle of the Moon's axis of
    #   rotation, measured eastward from the north point of the disk
    def position_angle_of_axis
      i_rho = INCLINATION + Angle.from_degrees(rho)
      v = ascending_node +
        nutation_in_longitude +
        Angle.from_degrees(sigma / INCLINATION.sin)

      x = i_rho.sin * v.sin
      y = i_rho.sin * v.cos * obliquity.cos - i_rho.cos * obliquity.sin
      omega = Math.atan2(x, y)

      Angle.from_radians(
        Math.asin(
          Math.sqrt(x * x + y * y) *
            Math.cos(right_ascension.radians - omega) /
            Angle.from_degrees(libration_in_latitude).cos
        )
      )
    end

    private

    # @return [Float] total libration in longitude, in degrees, in (-180, 180]
    def libration_in_longitude
      l = optical_longitude + physical_longitude
      ((l + 180) % 360) - 180
    end

    # @return [Float] total libration in latitude, in degrees
    def libration_in_latitude
      optical_latitude + physical_latitude
    end

    # Optical libration in longitude, l' = A - F (Meeus 53.1)
    # @return [Float] in degrees
    def optical_longitude
      argument_a.degrees - argument_of_latitude.degrees
    end

    # Optical libration in latitude (Meeus 53.1)
    # @return [Float] in degrees
    def optical_latitude
      Angle.from_radians(optical_latitude_radians).degrees
    end

    # Physical libration in longitude (Meeus 53.2)
    # @return [Float] in degrees
    def physical_longitude
      -tau +
        (rho * argument_a.cos + sigma * argument_a.sin) *
          Math.tan(optical_latitude_radians)
    end

    # Physical libration in latitude (Meeus 53.2)
    # @return [Float] in degrees
    def physical_latitude
      sigma * argument_a.cos - rho * argument_a.sin
    end

    # The argument "A" of the optical libration (Meeus 53.1)
    def argument_a
      @argument_a ||= Angle.from_radians(
        Math.atan2(
          w.sin * latitude.cos * INCLINATION.cos -
            latitude.sin * INCLINATION.sin,
          w.cos * latitude.cos
        )
      )
    end

    def optical_latitude_radians
      @optical_latitude_radians ||= Math.asin(
        -w.sin * latitude.cos * INCLINATION.sin - latitude.sin * INCLINATION.cos
      )
    end

    # W = λ - Δψ - Ω, the Moon's longitude referred to the mean equinox of
    # date, measured from the ascending node of the mean lunar equator
    def w
      @w ||= longitude - nutation_in_longitude - ascending_node
    end

    # @return [Float] periodic terms ρ, in degrees (Meeus 53)
    def rho
      @rho ||= trig_series([
        [-0.02752, mp.radians, :cos],
        [-0.02245, f.radians, :sin],
        [0.00684, (mp - f - f).radians, :cos],
        [-0.00293, (f + f).radians, :cos],
        [-0.00085, (f + f - d - d).radians, :cos],
        [-0.00054, (mp - d - d).radians, :cos],
        [-0.00020, (mp + f).radians, :sin],
        [-0.00020, (mp + f + f).radians, :cos],
        [-0.00020, (mp - f).radians, :cos],
        [0.00014, (mp + f + f - d - d).radians, :cos]
      ])
    end

    # @return [Float] periodic terms σ, in degrees (Meeus 53)
    def sigma
      @sigma ||= trig_series([
        [-0.02816, mp.radians, :sin],
        [0.02244, f.radians, :cos],
        [-0.00682, (mp - f - f).radians, :sin],
        [-0.00279, (f + f).radians, :sin],
        [-0.00083, (f + f - d - d).radians, :sin],
        [0.00069, (mp - d - d).radians, :sin],
        [0.00040, (mp + f).radians, :cos],
        [-0.00025, (mp + mp).radians, :sin],
        [-0.00023, (mp + f + f).radians, :sin],
        [0.00020, (mp - f).radians, :cos],
        [0.00019, (mp - f).radians, :sin],
        [0.00013, (mp + f + f - d - d).radians, :sin],
        [-0.00010, (mp - f - f - f).radians, :cos]
      ])
    end

    # @return [Float] periodic terms τ, in degrees (Meeus 53)
    def tau
      @tau ||= trig_series([
        [0.02520 * eccentricity, m.radians, :sin],
        [0.00473, (mp + mp - f - f).radians, :sin],
        [-0.00467, mp.radians, :sin],
        [0.00396, k1.radians, :sin],
        [0.00276, (mp + mp - d - d).radians, :sin],
        [0.00196, ascending_node.radians, :sin],
        [-0.00183, (mp - f).radians, :cos],
        [0.00115, (mp - d - d).radians, :sin],
        [-0.00096, (mp - d).radians, :sin],
        [0.00046, (f + f - d - d).radians, :sin],
        [-0.00039, (mp - f).radians, :sin],
        [-0.00032, (mp - m - d).radians, :sin],
        [0.00027, (mp + mp - m - d - d).radians, :sin],
        [0.00023, k2.radians, :sin],
        [-0.00014, (d + d).radians, :sin],
        [0.00014, (mp + mp - f - f).radians, :cos],
        [-0.00012, (mp - f - f).radians, :sin],
        [-0.00012, (mp + mp).radians, :sin],
        [0.00011, (mp + mp - m - m - d - d).radians, :sin]
      ])
    end

    def trig_series(terms)
      terms.sum do |coefficient, argument, fn|
        coefficient * Math.send(fn, argument)
      end
    end

    # Apparent geocentric ecliptic longitude (true equinox of date, λ)
    def longitude
      @longitude ||= @moon.apparent.ecliptic.longitude
    end

    # Apparent geocentric ecliptic latitude (β)
    def latitude
      @latitude ||= @moon.apparent.ecliptic.latitude
    end

    # Apparent geocentric right ascension (α)
    def right_ascension
      @right_ascension ||= @moon.apparent.equatorial.right_ascension
    end

    def obliquity
      @obliquity ||= TrueObliquity.at(@instant)
    end

    def nutation_in_longitude
      @nutation_in_longitude ||=
        Nutation.new(instant: @instant).nutation_in_longitude
    end

    def t
      @t ||=
        (@instant.tt - JulianDate::J2000) / Constants::DAYS_PER_JULIAN_CENTURY
    end

    # Mean elongation of the Moon (D), Meeus 47.5
    def d
      @d ||= Angle.from_degrees(
        297.8501921 + 445267.1114034 * t - 0.0018819 * t**2 +
          t**3 / 545868 - t**4 / 113065000
      )
    end

    # Sun's mean anomaly (M), Meeus 47.3
    def m
      @m ||= Angle.from_degrees(
        357.5291092 + 35999.0502909 * t - 0.0001536 * t**2 + t**3 / 24490000
      )
    end

    # Moon's mean anomaly (M'), Meeus 47.4
    def mp
      @mp ||= Angle.from_degrees(
        134.9633964 + 477198.8675055 * t + 0.0087414 * t**2 +
          t**3 / 69699 - t**4 / 14712000
      )
    end

    # Moon's argument of latitude (F), Meeus 47.5
    def f
      @f ||= Angle.from_degrees(
        93.2720950 + 483202.0175233 * t - 0.0036539 * t**2 -
          t**3 / 3526000 + t**4 / 863310000
      )
    end
    alias_method :argument_of_latitude, :f

    # Longitude of the mean ascending node (Ω), Meeus 47.7
    def ascending_node
      @ascending_node ||= Angle.from_degrees(
        125.0445479 - 1934.1362891 * t + 0.0020754 * t**2 +
          t**3 / 467441 - t**4 / 60616000
      )
    end

    # Eccentricity correction (E), Meeus 47.6
    def eccentricity
      @eccentricity ||= 1 - 0.002516 * t - 0.0000074 * t**2
    end

    def k1
      @k1 ||= Angle.from_degrees(119.75 + 131.849 * t)
    end

    def k2
      @k2 ||= Angle.from_degrees(72.56 + 20.186 * t)
    end
  end
end
