# frozen_string_literal: true

module Astronoby
  class Moon < SolarSystemBody
    SEMIDIAMETER_VARIATION = 0.7275
    EQUATORIAL_RADIUS = Distance.from_meters(1_737_400)

    def self.ephemeris_segments(ephem_source)
      if ephem_source == ::Ephem::SPK::JPL_DE
        [
          [SOLAR_SYSTEM_BARYCENTER, EARTH_MOON_BARYCENTER],
          [EARTH_MOON_BARYCENTER, MOON]
        ]
      elsif ephem_source == ::Ephem::SPK::INPOP
        [
          [SOLAR_SYSTEM_BARYCENTER, EARTH],
          [EARTH, MOON]
        ]
      end
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 49 - Phases of the Moon

    # @param year [Integer] Requested year
    # @param month [Integer] Requested month
    # @return [Array<Astronoby::MoonPhase>] Moon phases for the requested year
    def self.monthly_phase_events(year:, month:)
      Events::MoonPhases.phases_for(year: year, month: month)
    end

    # @return [Float] Phase fraction, from 0 to 1
    def current_phase_fraction
      mean_elongation.degrees / Constants::DEGREES_PER_CIRCLE
    end

    private

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 48 - Illuminated Fraction of the Moon's Disk
    def mean_elongation
      @mean_elongation ||= Angle.from_degrees(
        (
          297.8501921 +
            445267.1114034 * elapsed_centuries -
            0.0018819 * elapsed_centuries**2 +
            elapsed_centuries**3 / 545868 -
            elapsed_centuries**4 / 113065000
        ) % 360
      )
    end

    def elapsed_centuries
      (@instant.tt - JulianDate::DEFAULT_EPOCH) / Constants::DAYS_PER_JULIAN_CENTURY
    end
  end
end
