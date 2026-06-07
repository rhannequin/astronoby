# frozen_string_literal: true

module Astronoby
  # Represents the Moon. Provides phase events, apoapsis/periapsis events,
  # and phase fraction.
  class Moon < SolarSystemBody
    SEMIDIAMETER_VARIATION = 0.7275
    EQUATORIAL_RADIUS = Distance.from_meters(1_737_400)
    ABSOLUTE_MAGNITUDE = 0.28
    ORBITAL_PERIOD = 27.504339

    # @param ephem_source [Symbol] the ephemeris source type
    # @return [Array<Array>] ephemeris segment identifiers
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

    # @return [Float] absolute magnitude
    def self.absolute_magnitude
      ABSOLUTE_MAGNITUDE
    end

    # Finds all apoapsis events between two times
    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @param start_time [Time] Start time
    # @param end_time [Time] End time
    # @return [Array<Astronoby::ExtremumEvent>] Array of apoapsis events
    def self.apoapsis_events(
      ephem:,
      start_time:,
      end_time:,
      samples_per_period: 60
    )
      ExtremumCalculator.new(
        body: self,
        primary_body: Earth,
        ephem: ephem,
        samples_per_period: samples_per_period
      ).apoapsis_events_between(start_time, end_time)
    end

    # Finds all periapsis events between two times
    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @param start_time [Time] Start time
    # @param end_time [Time] End time
    # @return [Array<Astronoby::ExtremumEvent>] Array of periapsis events
    def self.periapsis_events(
      ephem:,
      start_time:,
      end_time:,
      samples_per_period: 60
    )
      ExtremumCalculator.new(
        body: self,
        primary_body: Earth,
        ephem: ephem,
        samples_per_period: samples_per_period
      ).periapsis_events_between(start_time, end_time)
    end

    # @return [Float] Phase fraction, from 0 to 1
    def current_phase_fraction
      mean_elongation.degrees / Constants::DEGREES_PER_CIRCLE
    end

    # Total (optical + physical) geocentric libration of the Moon.
    #
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 53 - Ephemeris for Physical Observations of the Moon
    # @return [Astronoby::Libration] Libration in longitude and latitude
    def libration
      physical_ephemeris.libration
    end

    # Position angle of the Moon's axis of rotation, measured eastward from the
    # north point of the disk.
    #
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 53 - Ephemeris for Physical Observations of the Moon
    # @return [Astronoby::Angle] Position angle of the axis
    def position_angle_of_axis
      physical_ephemeris.position_angle_of_axis
    end

    # Position angle of the Moon's bright limb: the position angle of the
    # midpoint of the illuminated limb, measured eastward from the north point
    # of the disk. Geocentric, from the apparent equatorial coordinates of the
    # Moon and the Sun.
    #
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 48 - Illuminated Fraction of the Moon's Disk
    # @return [Astronoby::Angle, nil] Position angle of the bright limb, between
    #   0 and 360 degrees
    def bright_limb_position_angle
      return unless sun

      @bright_limb_position_angle ||= begin
        moon = apparent.equatorial
        sun_coordinates = sun.apparent.equatorial
        delta_ra = sun_coordinates.right_ascension - moon.right_ascension

        angle = Angle.from_radians(
          Math.atan2(
            sun_coordinates.declination.cos * delta_ra.sin,
            sun_coordinates.declination.sin * moon.declination.cos -
              sun_coordinates.declination.cos * moon.declination.sin *
                delta_ra.cos
          )
        )
        Angle.from_degrees(angle.degrees % Constants::DEGREES_PER_CIRCLE)
      end
    end

    # Parallactic angle of the Moon for a given observer: the angle at the Moon
    # between the direction of the north celestial pole and the direction of
    # the observer's zenith. Computed from the topocentric place, where lunar
    # parallax is significant.
    #
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 14 - The Parallactic Angle
    # @param observer [Astronoby::Observer] Observer for whom to compute the
    #   parallactic angle
    # @return [Astronoby::Angle] Parallactic angle
    def parallactic_angle(observer:)
      equatorial = observed_by(observer).equatorial
      declination = equatorial.declination
      hour_angle = equatorial.compute_hour_angle(
        time: @instant.to_time,
        longitude: observer.longitude
      )

      Angle.from_radians(
        Math.atan2(
          hour_angle.sin,
          observer.latitude.tan * declination.cos -
            declination.sin * hour_angle.cos
        )
      )
    end

    private

    def physical_ephemeris
      @physical_ephemeris ||= MoonPhysicalEphemeris.new(self)
    end

    def primary_body_geometric
      earth_geometric
    end

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

    # Source:
    #  Title: Computing Apparent Planetary Magnitudes for The Astronomical
    #    Almanac (2018)
    #  Authors: Anthony Mallama and James L. Hilton
    def magnitude_correction_term
      phase_angle_degrees = phase_angle.degrees
      if phase_angle_degrees <= 150 && current_phase_fraction > 0.5
        waning_magnitude_correction(phase_angle_degrees)
      else
        waxing_magnitude_correction(phase_angle_degrees)
      end
    end

    def waxing_magnitude_correction(phase_angle_degrees)
      2.9994 * 10**-2 * phase_angle_degrees -
        1.6057 * 10**-4 * phase_angle_degrees**2 +
        3.1543 * 10**-6 * phase_angle_degrees**3 -
        2.0667 * 10**-8 * phase_angle_degrees**4 +
        6.2553 * 10**-11 * phase_angle_degrees**5
    end

    def waning_magnitude_correction(phase_angle_degrees)
      3.3234 * 10**-2 * phase_angle_degrees -
        3.0725 * 10**-4 * phase_angle_degrees**2 +
        6.1575 * 10**-6 * phase_angle_degrees**3 -
        4.7723 * 10**-8 * phase_angle_degrees**4 +
        1.4681 * 10**-10 * phase_angle_degrees**5
    end
  end
end
