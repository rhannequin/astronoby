# frozen_string_literal: true

module Astronoby
  class Sun
    SEMI_MAJOR_AXIS_IN_METERS = 149_598_500_000
    ANGULAR_DIAMETER = Angle.from_degrees(0.533128)
    INTERPOLATION_FACTOR = 24.07

    TWILIGHTS = [
      CIVIL = :civil,
      NAUTICAL = :nautical,
      ASTRONOMICAL = :astronomical
    ].freeze

    TWILIGHT_ANGLES = {
      CIVIL => Angle.from_degrees(96),
      NAUTICAL => Angle.from_degrees(102),
      ASTRONOMICAL => Angle.from_degrees(108)
    }.freeze

    PERIODS_OF_THE_DAY = [
      MORNING = :morning,
      EVENING = :evening
    ].freeze

    attr_reader :time

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 28 - Equation of Time

    # @param date_or_time [Date, Time] Requested date
    # @return [Integer] Equation of time in seconds
    def self.equation_of_time(date_or_time:)
      noon = Time.utc(date_or_time.year, date_or_time.month, date_or_time.day, 12)
      time = date_or_time.is_a?(Time) ? date_or_time : noon
      epoch = Epoch.from_time(time)
      sun = new(time: time)
      right_ascension = sun
        .apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: epoch)
        .right_ascension
      t = (epoch - Epoch::J2000) / Constants::DAYS_PER_JULIAN_MILLENIA
      l0 = (280.4664567 +
        360_007.6982779 * t +
        0.03032028 * t**2 +
        t**3 / 49_931 -
        t**4 / 15_300 -
        t**5 / 2_000_000) % Constants::DEGREES_PER_CIRCLE
      nutation = Nutation.for_ecliptic_longitude(epoch: epoch)
      obliquity = TrueObliquity.for_epoch(epoch)

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

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun

    # @param time [Time] Considered time
    def initialize(time:)
      @time = time
    end

    def epoch
      @epoch ||= Epoch.from_time(@time)
    end

    def true_ecliptic_coordinates
      Coordinates::Ecliptic.new(
        latitude: Angle.zero,
        longitude: true_longitude
      )
    end

    def apparent_ecliptic_coordinates
      nutation = Nutation.for_ecliptic_longitude(epoch: epoch)
      longitude_with_aberration = Aberration.for_ecliptic_coordinates(
        coordinates: true_ecliptic_coordinates,
        epoch: epoch
      ).longitude
      apparent_longitude = nutation + longitude_with_aberration

      Coordinates::Ecliptic.new(
        latitude: Angle.zero,
        longitude: apparent_longitude
      )
    end

    # Computes the Sun's horizontal coordinates
    #
    # @param latitude [Astronoby::Angle] Latitude of the observer
    # @param longitude [Astronoby::Angle] Longitude of the observer
    # @return [Astronoby::Coordinates::Horizontal] Sun's horizontal coordinates
    def horizontal_coordinates(latitude:, longitude:)
      apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: epoch)
        .to_horizontal(time: @time, latitude: latitude, longitude: longitude)
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Astronoby::Events::ObservationEvents] Sun's observation events
    def observation_events(observer:)
      today = @time.to_date
      yesterday = today.prev_day
      yesterday_epoch = Epoch.from_time(yesterday)
      today_epoch = Epoch.from_time(today)
      tomorrow = today.next_day
      tomorrow_epoch = Epoch.from_time(tomorrow)

      coordinates_of_the_previous_day = self.class
        .new(time: yesterday)
        .apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: yesterday_epoch)
      coordinates_of_the_day = self.class
        .new(time: today)
        .apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: today_epoch)
      coordinates_of_the_next_day = self.class
        .new(time: tomorrow)
        .apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: tomorrow_epoch)

      Events::ObservationEvents.new(
        observer: observer,
        date: today,
        coordinates_of_the_previous_day: coordinates_of_the_previous_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_next_day,
        additional_altitude: Angle.from_degrees(angular_size.degrees / 2)
      )
    end

    # @param observer [Astronoby::Observer] Observer of the events
    # @return [Astronoby::Events::TwilightEvents] Sun's twilight events
    def twilight_events(observer:)
      Events::TwilightEvents.new(sun: self, observer: observer)
    end

    # @return [Numeric] Earth-Sun distance in meters
    def earth_distance
      SEMI_MAJOR_AXIS_IN_METERS / distance_angular_size_factor
    end

    # @return [Astronoby::Angle] Apparent Sun's angular size
    def angular_size
      Angle.from_degrees(
        ANGULAR_DIAMETER.degrees * distance_angular_size_factor
      )
    end

    # @return [Astronoby::Angle] Sun's true anomaly
    def true_anomaly
      eccentric_anomaly = Util::Astrodynamics.eccentric_anomaly_newton_raphson(
        mean_anomaly,
        orbital_eccentricity.degrees,
        2e-06,
        10
      )

      tan = Math.sqrt(
        (1 + orbital_eccentricity.degrees) / (1 - orbital_eccentricity.degrees)
      ) * Math.tan(eccentric_anomaly.radians / 2)

      Angle.from_degrees(
        (Angle.atan(tan).degrees * 2) % Constants::DEGREES_PER_CIRCLE
      )
    end

    # @return [Astronoby::Angle] Sun's longitude at perigee
    def longitude_at_perigee
      Angle.from_degrees(
        (281.2208444 + 1.719175 * centuries + 0.000452778 * centuries**2) %
          Constants::DEGREES_PER_CIRCLE
      )
    end

    # @return [Astronoby::Angle] Sun's orbital eccentricity
    def orbital_eccentricity
      Angle.from_degrees(
        (0.01675104 - 0.0000418 * centuries - 0.000000126 * centuries**2) %
          Constants::DEGREES_PER_CIRCLE
      )
    end

    private

    def true_longitude
      Angle.from_degrees(
        (true_anomaly + longitude_at_perigee).degrees %
          Constants::DEGREES_PER_CIRCLE
      )
    end

    def mean_anomaly
      Angle.from_degrees(
        (longitude_at_base_epoch - longitude_at_perigee).degrees %
          Constants::DEGREES_PER_CIRCLE
      )
    end

    def days_since_epoch
      Epoch::DEFAULT_EPOCH - epoch
    end

    def centuries
      @centuries ||= (epoch - Epoch::J1900) / Constants::DAYS_PER_JULIAN_CENTURY
    end

    def longitude_at_base_epoch
      Angle.from_degrees(
        (279.6966778 + 36000.76892 * centuries + 0.0003025 * centuries**2) %
          Constants::DEGREES_PER_CIRCLE
      )
    end

    def distance_angular_size_factor
      term1 = 1 + orbital_eccentricity.degrees * true_anomaly.cos
      term2 = 1 - orbital_eccentricity.degrees**2

      term1 / term2
    end
  end
end
