# frozen_string_literal: true

module Astronoby
  class MoonPhasesPeriodicTerms
    # Lunar Solution ELP 2000-82B (Chapront-Touze+, 1988)

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 49 - Phases of the Moon

    # @param julian_centuries [Float] Julian centuries
    # @param time [Float] Time
    # @param eccentricity_correction [Float] Eccentricity correction
    # @param moon_mean_anomaly [Float] Moon mean anomaly
    # @param sun_mean_anomaly [Float] Sun mean anomaly
    # @param moon_argument_of_latitude [Float] Moon argument of latitude
    # @param longitude_of_the_ascending_node [Float] Longitude of the ascending node
    def initialize(
      julian_centuries:,
      time:,
      eccentricity_correction:,
      moon_mean_anomaly:,
      sun_mean_anomaly:,
      moon_argument_of_latitude:,
      longitude_of_the_ascending_node:

    )
      @julian_centuries = julian_centuries
      @time = time
      @eccentricity_correction = eccentricity_correction
      @moon_mean_anomaly = moon_mean_anomaly
      @sun_mean_anomaly = sun_mean_anomaly
      @moon_argument_of_latitude = moon_argument_of_latitude
      @longitude_of_the_ascending_node = longitude_of_the_ascending_node
    end

    # @return [Float] New moon correction
    def new_moon_correction
      ecc = @eccentricity_correction
      mma = @moon_mean_anomaly.radians
      sma = @sun_mean_anomaly.radians
      maol = @moon_argument_of_latitude.radians
      lotan = @longitude_of_the_ascending_node.radians
      [
        [-0.40720, mma],
        [0.17241 * ecc, sma],
        [0.01608, 2 * mma],
        [0.01039, 2 * maol],
        [0.00739 * ecc, mma - sma],
        [-0.00514 * ecc, mma + sma],
        [0.00208 * ecc * ecc, 2 * sma],
        [-0.00111, mma - 2 * maol],
        [-0.00057, mma + 2 * maol],
        [0.00056 * ecc, 2 * mma + sma],
        [-0.00042, 3 * mma],
        [0.00042 * ecc, sma + 2 * maol],
        [0.00038 * ecc, sma - 2 * maol],
        [-0.00024 * ecc, 2 * mma - sma],
        [-0.00017, lotan],
        [-0.00007, mma + 2 * sma],
        [0.00004, 2 * mma - 2 * maol],
        [0.00004, 3 * sma],
        [0.00003, mma + sma - 2 * maol],
        [0.00003, 2 * mma + 2 * maol],
        [-0.00003, mma + sma + 2 * maol],
        [0.00003, mma - sma + 2 * maol],
        [-0.00002, mma - sma - 2 * maol],
        [-0.00002, 3 * mma + sma],
        [0.00002, 4 * mma]
      ].map { _1.first * Math.sin(_1.last) }.sum
    end

    # @return [Float] First quarter correction
    def first_quarter_correction
      first_and_last_quarter_correction + first_and_last_quarter_final_correction
    end

    # @return [Float] Full moon correction
    def full_moon_correction
      ecc = @eccentricity_correction
      mma = @moon_mean_anomaly.radians
      sma = @sun_mean_anomaly.radians
      maol = @moon_argument_of_latitude.radians
      lotan = @longitude_of_the_ascending_node.radians
      [
        [-0.40614, mma],
        [0.17302 * ecc, sma],
        [0.01614, 2 * mma],
        [0.01043, 2 * maol],
        [0.00734 * ecc, mma - sma],
        [-0.00515 * ecc, mma + sma],
        [0.00209 * ecc * ecc, 2 * sma],
        [-0.00111, mma - 2 * maol],
        [-0.00057, mma + 2 * maol],
        [0.00056 * ecc, 2 * mma + sma],
        [-0.00042, 3 * mma],
        [0.00042 * ecc, sma + 2 * maol],
        [0.00038 * ecc, sma - 2 * maol],
        [-0.00024 * ecc, 2 * mma - sma],
        [-0.00017, lotan],
        [-0.00007, mma + 2 * sma],
        [0.00004, 2 * mma - 2 * maol],
        [0.00004, 3 * sma],
        [0.00003, mma + sma - 2 * maol],
        [0.00003, 2 * mma + 2 * maol],
        [-0.00003, mma + sma + 2 * maol],
        [0.00003, mma - sma + 2 * maol],
        [-0.00002, mma - sma - 2 * maol],
        [-0.00002, 3 * mma + sma],
        [0.00002, 4 * mma]
      ].map { _1.first * Math.sin(_1.last) }.sum
    end

    # @return [Float] Last quarter correction
    def last_quarter_correction
      first_and_last_quarter_correction - first_and_last_quarter_final_correction
    end

    # @return [Float] Additional corrections
    def additional_corrections
      [
        [0.000325, a1],
        [0.000165, a2],
        [0.000164, a3],
        [0.000126, a4],
        [0.000110, a5],
        [0.000062, a6],
        [0.000060, a7],
        [0.000056, a8],
        [0.000047, a9],
        [0.000042, a10],
        [0.000040, a11],
        [0.000037, a12],
        [0.000035, a13],
        [0.000023, a14]
      ].map { _1.first * _1.last.sin }.sum
    end

    private

    def a1
      Angle.from_degrees(
        (
          299.77 +
            0.107408 * @time -
            0.009173 * @julian_centuries**2
        ) % 360
      )
    end

    def a2
      Angle.from_degrees (251.88 + 0.016321 * @time) % 360
    end

    def a3
      Angle.from_degrees (251.83 + 26.651886 * @time) % 360
    end

    def a4
      Angle.from_degrees (349.42 + 36.412478 * @time) % 360
    end

    def a5
      Angle.from_degrees (84.66 + 18.206239 * @time) % 360
    end

    def a6
      Angle.from_degrees (141.74 + 53.303771 * @time) % 360
    end

    def a7
      Angle.from_degrees (207.14 + 2.453732 * @time) % 360
    end

    def a8
      Angle.from_degrees (154.84 + 7.306860 * @time) % 360
    end

    def a9
      Angle.from_degrees (34.52 + 27.261239 * @time) % 360
    end

    def a10
      Angle.from_degrees (207.19 + 0.121824 * @time) % 360
    end

    def a11
      Angle.from_degrees (291.34 + 1.844379 * @time) % 360
    end

    def a12
      Angle.from_degrees (161.72 + 24.198154 * @time) % 360
    end

    def a13
      Angle.from_degrees (239.56 + 25.513099 * @time) % 360
    end

    def a14
      Angle.from_degrees (331.55 + 3.592518 * @time) % 360
    end

    def first_and_last_quarter_final_correction
      0.00306 -
        0.00038 * @eccentricity_correction * @sun_mean_anomaly.cos +
        0.00026 * @moon_mean_anomaly.cos -
        0.00002 * (@moon_mean_anomaly - @sun_mean_anomaly).cos +
        0.00002 * (@moon_mean_anomaly + @sun_mean_anomaly).cos +
        0.00002 * Math.cos(2 * @moon_argument_of_latitude.radians)
    end

    def first_and_last_quarter_correction
      ecc = @eccentricity_correction
      mma = @moon_mean_anomaly.radians
      sma = @sun_mean_anomaly.radians
      maol = @moon_argument_of_latitude.radians
      lotan = @longitude_of_the_ascending_node.radians
      [
        [-0.62801, mma],
        [0.17172 * ecc, sma],
        [-0.01183, mma + sma],
        [0.00862, 2 * mma],
        [0.00804, 2 * maol],
        [0.00454 * ecc, mma - sma],
        [0.00204 * ecc**2, 2 * sma],
        [-0.00180, mma - 2 * maol],
        [-0.00070, mma + 2 * maol],
        [-0.00040, 3 * mma],
        [-0.00034 * ecc, 2 * mma - sma],
        [0.00032 * ecc, sma + 2 * maol],
        [0.00032, sma - 2 * maol],
        [-0.00028 * ecc**2, mma + 2 * sma],
        [0.00027 * ecc, 2 * mma + sma],
        [-0.00017, lotan],
        [-0.00005, mma - sma - 2 * maol],
        [0.00004, 2 * mma + 2 * maol],
        [-0.00004, mma + sma + 2 * maol],
        [0.00004, mma - 2 * sma],
        [0.00003, mma + sma - 2 * maol],
        [0.00003, 3 * sma],
        [0.00002, 2 * mma - 2 * maol],
        [0.00002, mma - sma + 2 * maol],
        [-0.00002, 3 * mma + sma]
      ].map { _1.first * Math.sin(_1.last) }.sum
    end
  end
end
