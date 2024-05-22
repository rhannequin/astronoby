# frozen_string_literal: true

module Astronoby
  class Moon
    MEAN_GEOCENTRIC_DISTANCE = Astronoby::Distance.from_meters(385_000_560)

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

    def initialize(time:)
      @time = time
    end

    # @return [Astronoby::Coordinates::Ecliptic] Apparent ecliptic coordinates
    #   of the Moon
    def apparent_ecliptic_coordinates
      @ecliptic_coordinates ||= begin
        latitude = Astronoby::Angle.from_degrees(
          (latitude_terms + additive_latitude_terms) *
            EphemerideLunaireParisienne::DEGREES_UNIT
        )

        longitude = mean_longitude + Astronoby::Angle.from_degrees(
          (longitude_terms + additive_longitude_terms) *
            EphemerideLunaireParisienne::DEGREES_UNIT
        ) + nutation

        Coordinates::Ecliptic.new(
          latitude: latitude,
          longitude: longitude
        )
      end
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 47 - Position of the Moon

    # @return [Astronoby::Coordinates::Equatorial] Apparent geocentric
    #   equatorial coordinates of the Moon
    def apparent_equatorial_coordinates
      @apparent_equatorial_coordinates ||=
        apparent_ecliptic_coordinates
          .to_apparent_equatorial(epoch: Epoch.from_time(@time))
    end

    def horizontal_coordinates(observer:)
      apparent_topocentric_equatorial_coordinates =
        Astronoby::GeocentricParallax.for_equatorial_coordinates(
          observer: observer,
          time: @time,
          coordinates: apparent_equatorial_coordinates,
          distance: distance
        )

      apparent_topocentric_equatorial_coordinates.to_horizontal(
        observer: observer,
        time: @time
      )
    end

    # @return [Astronoby::Distance] Distance between the Earth and the Moon centers
    def distance
      @distance ||= Astronoby::Distance.from_meters(
        (MEAN_GEOCENTRIC_DISTANCE.meters + distance_terms).round
      )
    end

    # @return [Angle] Moon's mean longitude
    def mean_longitude
      @mean_longitude ||= begin
        degrees =
          218.3164477 +
          481267.88123421 * elapsed_centuries -
          0.0015786 * elapsed_centuries**2 +
          elapsed_centuries**3 / 538841 -
          elapsed_centuries**4 / 65194000
        degrees += Constants::DEGREES_PER_CIRCLE while degrees.negative?
        Angle.from_degrees(degrees)
      end
    end

    # @return [Angle] Moon's mean elongation
    def mean_elongation
      @mean_elongation ||= begin
        degrees =
          297.8501921 +
          445267.1114034 * elapsed_centuries -
          0.0018819 * elapsed_centuries**2 +
          elapsed_centuries**3 / 545868 -
          elapsed_centuries**4 / 113065000
        degrees += Constants::DEGREES_PER_CIRCLE while degrees.negative?
        Angle.from_degrees(degrees)
      end
    end

    # @return [Angle] Moon's mean anomaly
    def mean_anomaly
      @mean_anomaly ||= begin
        degrees =
          134.9633964 +
          477198.8675055 * elapsed_centuries +
          0.0087414 * elapsed_centuries**2 +
          elapsed_centuries**3 / 69699 -
          elapsed_centuries**4 / 14712000
        degrees += Constants::DEGREES_PER_CIRCLE while degrees.negative?
        Angle.from_degrees(degrees)
      end
    end

    # @return [Angle] Moon's argument of latitude
    def argument_of_latitude
      @argument_of_latitude ||= begin
        degrees =
          93.2720950 +
          483202.0175233 * elapsed_centuries -
          0.0036539 * elapsed_centuries**2 -
          elapsed_centuries**3 / 3526000
        degrees += Constants::DEGREES_PER_CIRCLE while degrees.negative?
        Angle.from_degrees(degrees)
      end
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 48 - Illuminated Fraction of the Moon's Disk

    # @return [Angle] Moon's phase angle
    def phase_angle
      @phase_angle ||= begin
        sun_apparent_equatorial_coordinates = sun
          .apparent_ecliptic_coordinates
          .to_apparent_equatorial(epoch: Epoch.from_time(@time))
        moon_apparent_equatorial_coordinates = apparent_equatorial_coordinates
        geocentric_elongation = Angle.acos(
          sun_apparent_equatorial_coordinates.declination.sin *
            moon_apparent_equatorial_coordinates.declination.sin +
            sun_apparent_equatorial_coordinates.declination.cos *
            moon_apparent_equatorial_coordinates.declination.cos *
            (
              sun_apparent_equatorial_coordinates.right_ascension -
              moon_apparent_equatorial_coordinates.right_ascension
            ).cos
        )

        term1 = sun.earth_distance.km * geocentric_elongation.sin
        term2 = distance.km - sun.earth_distance.km * geocentric_elongation.cos
        angle = Angle.atan(term1 / term2)
        Astronoby::Util::Trigonometry
          .adjustement_for_arctangent(term1, term2, angle)
      end
    end

    # @return [Float] Moon's illuminated fraction
    def illuminated_fraction
      @illuminated_fraction ||= (1 + phase_angle.cos) / 2
    end

    private

    def terrestrial_time
      @terrestrial_time ||= begin
        delta = Util::Time.terrestrial_universal_time_delta(@time)
        @time + delta
      end
    end

    def julian_date
      Epoch.from_time(terrestrial_time)
    end

    def elapsed_centuries
      (julian_date - Epoch::DEFAULT_EPOCH) / Constants::DAYS_PER_JULIAN_CENTURY
    end

    def sun
      @sun ||= Sun.new(time: @time)
    end

    def sun_mean_anomaly
      @sun_mean_anomaly ||= sun.mean_anomaly
    end

    def a1
      @a1 ||= begin
        degrees = 119.75 + 131.849 * elapsed_centuries
        degrees += Constants::DEGREES_PER_CIRCLE while degrees.negative?
        Angle.from_degrees(degrees)
      end
    end

    def a2
      @a2 ||= begin
        degrees = 53.09 + 479264.290 * elapsed_centuries
        degrees += Constants::DEGREES_PER_CIRCLE while degrees.negative?
        Angle.from_degrees(degrees)
      end
    end

    def a3
      @a3 ||= begin
        degrees = 313.45 + 481266.484 * elapsed_centuries
        degrees += Constants::DEGREES_PER_CIRCLE while degrees.negative?
        Angle.from_degrees(degrees)
      end
    end

    def eccentricity_correction
      @eccentricity_correction ||=
        1 - 0.002516 * elapsed_centuries - 0.0000074 * elapsed_centuries**2
    end

    def latitude_terms
      @latitude_terms ||=
        Astronoby::EphemerideLunaireParisienne
          .periodic_terms_for_moon_latitude
          .inject(0) do |sum, terms|
            value = terms[4] * Math.sin(
              terms[0] * mean_elongation.radians +
              terms[1] * sun_mean_anomaly.radians +
              terms[2] * mean_anomaly.radians +
              terms[3] * argument_of_latitude.radians
            )

            value *= eccentricity_correction if terms[1].abs == 1
            value *= eccentricity_correction**2 if terms[1].abs == 2

            sum + value
          end
    end

    def additive_latitude_terms
      @additive_latitude_terms ||=
        -2235 * mean_longitude.sin +
        382 * a3.sin +
        175 * (a1 - argument_of_latitude).sin +
        175 * (a1 + argument_of_latitude).sin +
        127 * (mean_longitude - mean_anomaly).sin -
        115 * (mean_longitude + mean_anomaly).sin
    end

    def longitude_terms
      @longitude_terms ||=
        Astronoby::EphemerideLunaireParisienne
          .periodic_terms_for_moon_longitude_and_distance
          .inject(0) do |sum, terms|
            value = terms[4] * Math.sin(
              terms[0] * mean_elongation.radians +
              terms[1] * sun_mean_anomaly.radians +
              terms[2] * mean_anomaly.radians +
              terms[3] * argument_of_latitude.radians
            )

            value *= eccentricity_correction if terms[1].abs == 1
            value *= eccentricity_correction**2 if terms[1].abs == 2

            sum + value
          end
    end

    def additive_longitude_terms
      @additive_longitude_terms ||=
        3958 * a1.sin +
        1962 * (mean_longitude - argument_of_latitude).sin +
        318 * a2.sin
    end

    def distance_terms
      @distance_terms ||=
        EphemerideLunaireParisienne
          .periodic_terms_for_moon_longitude_and_distance
          .inject(0) do |sum, terms|
            value = terms[5] * Math.cos(
              terms[0] * mean_elongation.radians +
              terms[1] * sun_mean_anomaly.radians +
              terms[2] * mean_anomaly.radians +
              terms[3] * argument_of_latitude.radians
            )

            value *= eccentricity_correction if terms[1].abs == 1
            value *= eccentricity_correction**2 if terms[1].abs == 2

            sum + value
          end
    end

    def nutation
      @nutation ||=
        Astronoby::Nutation.for_ecliptic_longitude(epoch: julian_date)
    end
  end
end
