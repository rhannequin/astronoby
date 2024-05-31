# frozen_string_literal: true

module Astronoby
  module Events
    class MoonPhases
      BASE_YEAR = 2000

      # Source:
      #  Title: Astronomical Algorithms
      #  Author: Jean Meeus
      #  Edition: 2nd edition
      #  Chapter: 49 - Phases of the Moon

      # @param year [Integer] Requested year
      # @param month [Integer] Requested month
      # @return [Array<Astronoby::MoonPhase>] List of Moon phases
      def self.phases_for(year:, month:)
        [
          MoonPhase.first_quarter(new(year, month, :first_quarter, -0.75).time),
          MoonPhase.full_moon(new(year, month, :full_moon, -0.5).time),
          MoonPhase.last_quarter(new(year, month, :last_quarter, -0.25).time),
          MoonPhase.new_moon(new(year, month, :new_moon, 0).time),
          MoonPhase.first_quarter(new(year, month, :first_quarter, 0.25).time),
          MoonPhase.full_moon(new(year, month, :full_moon, 0.5).time),
          MoonPhase.last_quarter(new(year, month, :last_quarter, 0.75).time),
          MoonPhase.new_moon(new(year, month, :new_moon, 1).time)
        ].select { _1.time.month == month }
      end

      # @param year [Integer] Requested year
      # @param month [Integer] Requested month
      # @param phase [Symbol] Moon phase
      # @param phase_increment [Float] Phase increment
      def initialize(year, month, phase, phase_increment)
        @year = year
        @month = month
        @phase = phase
        @phase_increment = phase_increment
      end

      # @return [Time] Time of the Moon phase
      def time
        correction = send(:"#{@phase}_correction")
        terrestrial_time = Epoch.to_utc(
          julian_ephemeris_day + correction + additional_corrections
        )
        delta = Util::Time.terrestrial_universal_time_delta(terrestrial_time)
        (terrestrial_time - delta).round
      end

      private

      def portion_of_year
        days_in_year = Date.new(@year, 12, 31) - Date.new(@year, 1, 1)
        mid_month = Date.new(@year, @month, 15)
        mid_month.yday / days_in_year.to_f
      end

      def approximate_time
        ((@year + portion_of_year - BASE_YEAR) * 12.3685).floor + @phase_increment
      end

      def julian_centuries
        approximate_time / 1236.85
      end

      def julian_ephemeris_day
        2451550.09766 +
          29.530588861 * approximate_time +
          0.00015437 * julian_centuries**2 -
          0.000000150 * julian_centuries**3 +
          0.00000000073 * julian_centuries**4
      end

      def eccentricity_correction
        1 -
          0.002516 * julian_centuries -
          0.0000074 * julian_centuries**2
      end

      def sun_mean_anomaly
        Angle.from_degrees(
          (
            2.5534 +
            29.10535670 * approximate_time -
            0.0000014 * julian_centuries**2 -
            0.00000011 * julian_centuries**3
          ) % 360
        )
      end

      def moon_mean_anomaly
        Angle.from_degrees(
          (
            201.5643 +
            385.81693528 * approximate_time +
            0.0107582 * julian_centuries**2 +
            0.00001238 * julian_centuries**3 -
            0.000000058 * julian_centuries**4
          ) % 360
        )
      end

      def moon_argument_of_latitude
        Angle.from_degrees(
          (
            160.7108 +
            390.67050284 * approximate_time -
            0.0016118 * julian_centuries**2 -
            0.00000227 * julian_centuries**3 +
            0.000000011 * julian_centuries**4
          ) % 360
        )
      end

      def longitude_of_the_ascending_node
        Angle.from_degrees(
          (
            124.7746 -
            1.56375588 * approximate_time +
            0.0020672 * julian_centuries**2 +
            0.00000215 * julian_centuries**3
          ) % 360
        )
      end

      def a1
        Angle.from_degrees(
          (
            299.77 +
            0.107408 * approximate_time -
            0.009173 * julian_centuries**2
          ) % 360
        )
      end

      def a2
        Angle.from_degrees (251.88 + 0.016321 * approximate_time) % 360
      end

      def a3
        Angle.from_degrees (251.83 + 26.651886 * approximate_time) % 360
      end

      def a4
        Angle.from_degrees (349.42 + 36.412478 * approximate_time) % 360
      end

      def a5
        Angle.from_degrees (84.66 + 18.206239 * approximate_time) % 360
      end

      def a6
        Angle.from_degrees (141.74 + 53.303771 * approximate_time) % 360
      end

      def a7
        Angle.from_degrees (207.14 + 2.453732 * approximate_time) % 360
      end

      def a8
        Angle.from_degrees (154.84 + 7.306860 * approximate_time) % 360
      end

      def a9
        Angle.from_degrees (34.52 + 27.261239 * approximate_time) % 360
      end

      def a10
        Angle.from_degrees (207.19 + 0.121824 * approximate_time) % 360
      end

      def a11
        Angle.from_degrees (291.34 + 1.844379 * approximate_time) % 360
      end

      def a12
        Angle.from_degrees (161.72 + 24.198154 * approximate_time) % 360
      end

      def a13
        Angle.from_degrees (239.56 + 25.513099 * approximate_time) % 360
      end

      def a14
        Angle.from_degrees (331.55 + 3.592518 * approximate_time) % 360
      end

      def new_moon_correction
        ecc = eccentricity_correction
        mma = moon_mean_anomaly.radians
        sma = sun_mean_anomaly.radians
        maol = moon_argument_of_latitude.radians
        lotan = longitude_of_the_ascending_node.radians
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

      def first_quarter_correction
        first_and_last_quarter_correction + first_and_last_quarter_final_correction
      end

      def full_moon_correction
        ecc = eccentricity_correction
        mma = moon_mean_anomaly.radians
        sma = sun_mean_anomaly.radians
        maol = moon_argument_of_latitude.radians
        lotan = longitude_of_the_ascending_node.radians
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

      def last_quarter_correction
        first_and_last_quarter_correction - first_and_last_quarter_final_correction
      end

      def first_and_last_quarter_correction
        ecc = eccentricity_correction
        mma = moon_mean_anomaly.radians
        sma = sun_mean_anomaly.radians
        maol = moon_argument_of_latitude.radians
        lotan = longitude_of_the_ascending_node.radians
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

      def first_and_last_quarter_final_correction
        0.00306 -
          0.00038 * eccentricity_correction * sun_mean_anomaly.cos +
          0.00026 * moon_mean_anomaly.cos -
          0.00002 * (moon_mean_anomaly - sun_mean_anomaly).cos +
          0.00002 * (moon_mean_anomaly + sun_mean_anomaly).cos +
          0.00002 * Math.cos(2 * moon_argument_of_latitude.radians)
      end

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
    end
  end
end
