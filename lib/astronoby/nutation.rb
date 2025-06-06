# frozen_string_literal: true

module Astronoby
  class Nutation
    # IAU 2000B model corrections (in microarcseconds)
    IAU2000B_DPSI_CORRECTION = -0.000135e7
    IAU2000B_DEPS_CORRECTION = 0.000388e7

    # Nutation terms from IAU 2000B model:
    # 77 most significant terms from the IAU 2000A model
    # 0..4: fundamental argument coefficients
    # 5..7: longitude coefficients
    # 8..10: obliquity coefficients
    NUTATION_TERMS = [
      [0, 0, 0, 0, 1, -172064161, -174666, 33386, 92052331, 9086, 15377],
      [0, 0, 2, -2, 2, -13170906, -1675, -13696, 5730336, -3015, -4587],
      [0, 0, 2, 0, 2, -2276413, -234, 2796, 978459, -485, 1374],
      [0, 0, 0, 0, 2, 2074554, 207, -698, -897492, 470, -291],
      [0, 1, 0, 0, 0, 1475877, -3633, 11817, 73871, -184, -1924],
      [0, 1, 2, -2, 2, -516821, 1226, -524, 224386, -677, -174],
      [1, 0, 0, 0, 0, 711159, 73, -872, -6750, 0, 358],
      [0, 0, 2, 0, 1, -387298, -367, 380, 200728, 18, 318],
      [1, 0, 2, 0, 2, -301461, -36, 816, 129025, -63, 367],
      [0, -1, 2, -2, 2, 215829, -494, 111, -95929, 299, 132],
      [0, 0, 2, -2, 1, 128227, 137, 181, -68982, -9, 39],
      [-1, 0, 2, 0, 2, 123457, 11, 19, -53311, 32, -4],
      [-1, 0, 0, 2, 0, 156994, 10, -168, -1235, 0, 82],
      [1, 0, 0, 0, 1, 63110, 63, 27, -33228, 0, -9],
      [-1, 0, 0, 0, 1, -57976, -63, -189, 31429, 0, -75],
      [-1, 0, 2, 2, 2, -59641, -11, 149, 25543, -11, 66],
      [1, 0, 2, 0, 1, -51613, -42, 129, 26366, 0, 78],
      [-2, 0, 2, 0, 1, 45893, 50, 31, -24236, -10, 20],
      [0, 0, 0, 2, 0, 63384, 11, -150, -1220, 0, 29],
      [0, 0, 2, 2, 2, -38571, -1, 158, 16452, -11, 68],
      [0, -2, 2, -2, 2, 32481, 0, 0, -13870, 0, 0],
      [-2, 0, 0, 2, 0, -47722, 0, -18, 477, 0, -25],
      [2, 0, 2, 0, 2, -31046, -1, 131, 13238, -11, 59],
      [1, 0, 2, -2, 2, 28593, 0, -1, -12338, 10, -3],
      [-1, 0, 2, 0, 1, 20441, 21, 10, -10758, 0, -3],
      [2, 0, 0, 0, 0, 29243, 0, -74, -609, 0, 13],
      [0, 0, 2, 0, 0, 25887, 0, -66, -550, 0, 11],
      [0, 1, 0, 0, 1, -14053, -25, 79, 8551, -2, -45],
      [-1, 0, 0, 2, 1, 15164, 10, 11, -8001, 0, -1],
      [0, 2, 2, -2, 2, -15794, 72, -16, 6850, -42, -5],
      [0, 0, -2, 2, 0, 21783, 0, 13, -167, 0, 13],
      [1, 0, 0, -2, 1, -12873, -10, -37, 6953, 0, -14],
      [0, -1, 0, 0, 1, -12654, 11, 63, 6415, 0, 26],
      [-1, 0, 2, 2, 1, -10204, 0, 25, 5222, 0, 15],
      [0, 2, 0, 0, 0, 16707, -85, -10, 168, -1, 10],
      [1, 0, 2, 2, 2, -7691, 0, 44, 3268, 0, 19],
      [-2, 0, 2, 0, 0, -11024, 0, -14, 104, 0, 2],
      [0, 1, 2, 0, 2, 7566, -21, -11, -3250, 0, -5],
      [0, 0, 2, 2, 1, -6637, -11, 25, 3353, 0, 14],
      [0, -1, 2, 0, 2, -7141, 21, 8, 3070, 0, 4],
      [0, 0, 0, 2, 1, -6302, -11, 2, 3272, 0, 4],
      [1, 0, 2, -2, 1, 5800, 10, 2, -3045, 0, -1],
      [2, 0, 2, -2, 2, 6443, 0, -7, -2768, 0, -4],
      [-2, 0, 0, 2, 1, -5774, -11, -15, 3041, 0, -5],
      [2, 0, 2, 0, 1, -5350, 0, 21, 2695, 0, 12],
      [0, -1, 2, -2, 1, -4752, -11, -3, 2719, 0, -3],
      [0, 0, 0, -2, 1, -4940, -11, -21, 2720, 0, -9],
      [-1, -1, 0, 2, 0, 7350, 0, -8, -51, 0, 4],
      [2, 0, 0, -2, 1, 4065, 0, 6, -2206, 0, 1],
      [1, 0, 0, 2, 0, 6579, 0, -24, -199, 0, 2],
      [0, 1, 2, -2, 1, 3579, 0, 5, -1900, 0, 1],
      [1, -1, 0, 0, 0, 4725, 0, -6, -41, 0, 3],
      [-2, 0, 2, 0, 2, -3075, 0, -2, 1313, 0, -1],
      [3, 0, 2, 0, 2, -2904, 0, 15, 1233, 0, 7],
      [0, -1, 0, 2, 0, 4348, 0, -10, -81, 0, 2],
      [1, -1, 2, 0, 2, -2878, 0, 8, 1232, 0, 4],
      [0, 0, 0, 1, 0, -4230, 0, 5, -20, 0, -2],
      [-1, -1, 2, 2, 2, -2819, 0, 7, 1207, 0, 3],
      [-1, 0, 2, 0, 0, -4056, 0, 5, 40, 0, -2],
      [0, -1, 2, 2, 2, -2647, 0, 11, 1129, 0, 5],
      [-2, 0, 0, 0, 1, -2294, 0, -10, 1266, 0, -4],
      [1, 1, 2, 0, 2, 2481, 0, -7, -1062, 0, -3],
      [2, 0, 0, 0, 1, 2179, 0, -2, -1129, 0, -2],
      [-1, 1, 0, 1, 0, 3276, 0, 1, -9, 0, 0],
      [1, 1, 0, 0, 0, -3389, 0, 5, 35, 0, -2],
      [1, 0, 2, 0, 0, 3339, 0, -13, -107, 0, 1],
      [-1, 0, 2, -2, 1, -1987, 0, -6, 1073, 0, -2],
      [1, 0, 0, 0, 2, -1981, 0, 0, 854, 0, 0],
      [-1, 0, 0, 1, 0, 4026, 0, -353, -553, 0, -139],
      [0, 0, 2, 1, 2, 1660, 0, -5, -710, 0, -2],
      [-1, 0, 2, 4, 2, -1521, 0, 9, 647, 0, 4],
      [-1, 1, 0, 1, 1, 1314, 0, 0, -700, 0, 0],
      [0, -2, 2, -2, 1, -1283, 0, 0, 672, 0, 0],
      [1, 0, 2, 2, 1, -1331, 0, 8, 663, 0, 4],
      [-2, 0, 2, 2, 2, 1383, 0, -2, -594, 0, -2],
      [-1, 0, 0, 0, 2, 1405, 0, 4, -610, 0, 2],
      [1, 1, 2, -2, 2, 1290, 0, 0, -556, 0, 0]
    ]

    # @param instant [Astronoby::Instant] The time instant
    # @return [Matrix] The nutation matrix
    def self.matrix_for(instant)
      new(instant: instant).matrix
    end

    # @param instant [Astronoby::Instant] The time instant
    def initialize(instant:)
      @instant = instant
    end

    # @return [Matrix] The nutation matrix
    def matrix
      mean_obliquity = MeanObliquity.for_epoch(@instant.tt)
      true_obliquity = mean_obliquity + nutation_in_obliquity
      build_nutation_matrix(
        mean_obliquity: mean_obliquity,
        true_obliquity: true_obliquity,
        psi: nutation_in_longitude
      )
    end

    # @return [Astronoby::Angle] Nutation angle in longitude
    def nutation_in_longitude
      iau2000b_angles.first
    end

    # @return [Astronoby::Angle] Nutation angle in obliquity
    def nutation_in_obliquity
      iau2000b_angles.last
    end

    private

    def cache_key
      @_cache_key ||= CacheKey.generate(:nutation, @instant)
    end

    def cache
      Astronoby.cache
    end

    def iau2000a
      a = fundamental_arguments

      dpsi = 0.0
      deps = 0.0

      NUTATION_TERMS.each do |term|
        # Extract the fundamental argument coefficients
        arg_coef = term[0..4]

        # Calculate the argument
        arg = Util::Maths.dot_product(arg_coef, a.map(&:radians))

        sin_arg = Math.sin(arg)
        cos_arg = Math.cos(arg)

        # Extract longitude coefficients
        long_coef = term[5..7]

        # Extract obliquity coefficients
        obl_coef = term[8..10]

        # Update dpsi using longitude coefficients
        dpsi += long_coef[0] * sin_arg
        dpsi += long_coef[1] * sin_arg * julian_centuries
        dpsi += long_coef[2] * cos_arg

        # Update deps using obliquity coefficients
        deps += obl_coef[0] * cos_arg
        deps += obl_coef[1] * cos_arg * julian_centuries
        deps += obl_coef[2] * sin_arg
      end

      [dpsi, deps] # in microarcseconds
    end

    def iau2000b
      dpsi, deps = iau2000a

      # Apply corrections for IAU 2000B model
      dpsi += IAU2000B_DPSI_CORRECTION
      deps += IAU2000B_DEPS_CORRECTION

      [dpsi, deps]
    end

    def iau2000b_angles
      cache.fetch(cache_key) do
        dpsi, deps = iau2000b
        dpsi = Angle.from_degree_arcseconds(dpsi / 1e7)
        deps = Angle.from_degree_arcseconds(deps / 1e7)

        [dpsi, deps]
      end
    end

    def build_nutation_matrix(mean_obliquity:, true_obliquity:, psi:)
      cobm = mean_obliquity.cos
      sobm = mean_obliquity.sin
      cobt = true_obliquity.cos
      sobt = true_obliquity.sin
      cpsi = psi.cos
      spsi = psi.sin

      Matrix[
        [cpsi, -spsi * cobm, -spsi * sobm],
        [
          spsi * cobt,
          cpsi * cobm * cobt + sobm * sobt,
          cpsi * sobm * cobt - cobm * sobt
        ],
        [
          spsi * sobt,
          cpsi * cobm * sobt - sobm * cobt,
          cpsi * sobm * sobt + cobm * cobt
        ]
      ]
    end

    def julian_centuries
      @julian_centuries ||=
        (@instant.tt - Epoch::J2000) / Constants::DAYS_PER_JULIAN_CENTURY
    end

    # IAU 2006/2000A formula for the mean anomaly of the Moon
    def mean_anomaly_moon
      Angle.from_degree_arcseconds(
        485868.249036 + 1717915923.2178 * julian_centuries
      )
    end

    # IAU 2006/2000A formula for the mean anomaly of the Sun
    def mean_anomaly_sun
      Angle.from_degree_arcseconds(
        1287104.79305 + 129596581.0481 * julian_centuries
      )
    end

    # IAU 2006/2000A formula for the mean argument of latitude of the Moon
    def mean_argument_latitude_moon
      Angle.from_degree_arcseconds(
        335779.526232 + 1739527262.8478 * julian_centuries
      )
    end

    # IAU 2006/2000A formula for the mean elongation of the Moon from the Sun
    def mean_elongation_moon_sun
      Angle.from_degree_arcseconds(
        1072260.70369 + 1602961601.2090 * julian_centuries
      )
    end

    # IAU 2006/2000A formula for the mean longitude of the ascending node of the
    # Moon
    def longitude_ascending_node_moon
      Angle.from_degree_arcseconds(
        450160.398036 - 6962890.5431 * julian_centuries
      )
    end

    def fundamental_arguments
      l = mean_anomaly_moon
      lp = mean_anomaly_sun
      f = mean_argument_latitude_moon
      d = mean_elongation_moon_sun
      omega = longitude_ascending_node_moon

      [l, lp, f, d, omega]
    end
  end
end
