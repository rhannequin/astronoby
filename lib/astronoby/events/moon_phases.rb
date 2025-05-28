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
        Astronoby.cache.fetch([:moon_phases, year, month]) do
          [
            MoonPhase.first_quarter(new(year, month, :first_quarter, -0.75).time),
            MoonPhase.full_moon(new(year, month, :full_moon, -0.5).time),
            MoonPhase.last_quarter(new(year, month, :last_quarter, -0.25).time),
            MoonPhase.new_moon(new(year, month, :new_moon, 0).time),
            MoonPhase.first_quarter(new(year, month, :first_quarter, 0.25).time),
            MoonPhase.full_moon(new(year, month, :full_moon, 0.5).time),
            MoonPhase.last_quarter(new(year, month, :last_quarter, 0.75).time),
            MoonPhase.new_moon(new(year, month, :new_moon, 1).time),
            MoonPhase.first_quarter(new(year, month, :first_quarter, 1.25).time)
          ].select { _1.time.month == month }
        end
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
        correction = moon_phases_periodic_terms
          .public_send(:"#{@phase}_correction")
        terrestrial_time = Epoch.to_utc(
          julian_ephemeris_day +
            correction +
            moon_phases_periodic_terms.additional_corrections
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

      def moon_phases_periodic_terms
        MoonPhasesPeriodicTerms.new(
          julian_centuries: julian_centuries,
          time: approximate_time,
          eccentricity_correction: eccentricity_correction,
          moon_mean_anomaly: moon_mean_anomaly,
          sun_mean_anomaly: sun_mean_anomaly,
          moon_argument_of_latitude: moon_argument_of_latitude,
          longitude_of_the_ascending_node: longitude_of_the_ascending_node
        )
      end
    end
  end
end
