# frozen_string_literal: true

module Astronoby
  class Sun < SolarSystemBody
    EQUATORIAL_RADIUS = Distance.from_meters(695_700_000)
    ABSOLUTE_MAGNITUDE = -26.74

    def self.ephemeris_segments(_ephem_source)
      [[SOLAR_SYSTEM_BARYCENTER, SUN]]
    end

    def self.absolute_magnitude
      ABSOLUTE_MAGNITUDE
    end

    # @param observer [Astronoby::Observer] Observer for whom to calculate
    #   twilight events
    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @param date [Date] Date for which to calculate twilight events (optional)
    # @param start_time [Time] Start time for twilight event calculation
    #   (optional)
    # @param end_time [Time] End time for twilight event calculation (optional)
    # @param utc_offset [String] UTC offset for the given date (e.g., "+02:00")
    # @return [TwilightEvent, Array<TwilightEvent>] Twilight events for the
    #   given date or time range.
    def self.twilight_events(
      observer:,
      ephem:,
      date: nil,
      start_time: nil,
      end_time: nil,
      utc_offset: 0
    )
      calculator = TwilightCalculator.new(observer: observer, ephem: ephem)
      if date
        calculator.event_on(date, utc_offset: utc_offset)
      else
        calculator.events_between(start_time, end_time)
      end
    end

    # @param year [Integer] Year for which to calculate equinoxes and solstices
    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @return [Time] Time of the March equinox for the given year.
    def self.march_equinox(year, ephem:)
      EquinoxSolstice.march_equinox(year, ephem)
    end

    # @param year [Integer] Year for which to calculate equinoxes and solstices
    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @return [Time] Time of the June solstice for the given year.
    def self.june_solstice(year, ephem:)
      EquinoxSolstice.june_solstice(year, ephem)
    end

    # @param year [Integer] Year for which to calculate equinoxes and solstices
    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @return [Time] Time of the September equinox for the given year.
    def self.september_equinox(year, ephem:)
      EquinoxSolstice.september_equinox(year, ephem)
    end

    # @param year [Integer] Year for which to calculate equinoxes and solstices
    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @return [Time] Time of the December solstice for the given year.
    def self.december_solstice(year, ephem:)
      EquinoxSolstice.december_solstice(year, ephem)
    end

    # Source:
    #  Title: Explanatory Supplement to the Astronomical Almanac
    #  Authors: Sean E. Urban and P. Kenneth Seidelmann
    #  Edition: University Science Books
    #  Chapter: 10.3 - Phases and Magnitudes
    # Apparent magnitude of the body, as seen from Earth.
    # @return [Float] Apparent magnitude of the body.
    def apparent_magnitude
      @apparent_magnitude ||=
        self.class.absolute_magnitude + 5 * Math.log10(astrometric.distance.au)
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 28 - Equation of Time

    # @return [Integer] Equation of time in seconds
    def equation_of_time
      right_ascension = apparent.equatorial.right_ascension
      t = (@instant.julian_date - JulianDate::J2000) / Constants::DAYS_PER_JULIAN_MILLENIA
      l0 = (280.4664567 +
        360_007.6982779 * t +
        0.03032028 * t**2 +
        t**3 / 49_931 -
        t**4 / 15_300 -
        t**5 / 2_000_000) % Constants::DEGREES_PER_CIRCLE
      nutation = Nutation.new(instant: instant).nutation_in_longitude
      obliquity = TrueObliquity.at(@instant)

      (
        Angle
          .from_degrees(
            l0 -
              Constants::EQUATION_OF_TIME_CONSTANT -
              right_ascension.degrees +
              nutation.degrees * obliquity.cos
          ).hours * Constants::SECONDS_PER_HOUR
      ).round
    end

    def phase_angle
      nil
    end

    def approaching_primary?
      false
    end

    def receding_from_primary?
      false
    end

    private

    def primary_body_geometric
      nil
    end
  end
end
