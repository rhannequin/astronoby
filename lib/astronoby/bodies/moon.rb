# frozen_string_literal: true

module Astronoby
  class Moon < SolarSystemBody
    SEMIDIAMETER_VARIATION = 0.7275
    EQUATORIAL_RADIUS = Distance.from_meters(1_737_400)
    ABSOLUTE_MAGNITUDE = 0.28

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

    def self.absolute_magnitude
      ABSOLUTE_MAGNITUDE
    end

    # @return [Float] Phase fraction, from 0 to 1
    def current_phase_fraction
      mean_elongation.degrees / Constants::DEGREES_PER_CIRCLE
    end

    # @return [Boolean] True if the body is approaching the primary
    #   body (Earth), false otherwise.
    def approaching_primary?
      relative_position =
        (geometric.position - @earth_geometric.position).map(&:m)
      relative_velocity =
        (geometric.velocity - @earth_geometric.velocity).map(&:mps)
      radial_velocity_component = Astronoby::Util::Maths
        .dot_product(relative_position, relative_velocity)
      distance = Math.sqrt(
        Astronoby::Util::Maths.dot_product(relative_position, relative_position)
      )
      radial_velocity_component / distance < 0
    end

    # @return [Boolean] True if the body is receding from the primary
    #   body (Earth), false otherwise.
    def receding_from_primary?
      !approaching_primary?
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

    private

    # Source:
    #  Title: Computing Apparent Planetary Magnitudes for The Astronomical
    #    Almanac (2018)
    #  Authors: Anthony Mallama and James L. Hilton
    def magnitude_correction_term
      phase_angle_degrees = phase_angle.degrees
      if phase_angle_degrees <= 150 && current_phase_fraction <= 0.5
        2.9994 * 10**-2 * phase_angle_degrees -
          1.6057 * 10**-4 * phase_angle_degrees**2 +
          3.1543 * 10**-6 * phase_angle_degrees**3 -
          2.0667 * 10**-8 * phase_angle_degrees**4 +
          6.2553 * 10**-11 * phase_angle_degrees**5
      elsif phase_angle_degrees <= 150 && current_phase_fraction > 0.5
        3.3234 * 10**-2 * phase_angle_degrees -
          3.0725 * 10**-4 * phase_angle_degrees**2 +
          6.1575 * 10**-6 * phase_angle_degrees**3 -
          4.7723 * 10**-8 * phase_angle_degrees**4 +
          1.4681 * 10**-10 * phase_angle_degrees**5
      else
        super
      end
    end
  end
end
