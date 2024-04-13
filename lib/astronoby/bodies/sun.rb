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

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 51 - The equation of time

    # @param date [Date] Requested date
    # @return [Integer] Equation of time in seconds
    def self.equation_of_time(date:)
      noon = Time.utc(date.year, date.month, date.day, 12)
      epoch_at_noon = Epoch.from_time(noon)
      sun_at_noon = new(epoch: epoch_at_noon)
      equatorial_hours = sun_at_noon
        .apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: epoch_at_noon)
        .right_ascension
        .hours
      gst = GreenwichSiderealTime
        .new(date: date, time: equatorial_hours)
        .to_utc

      (noon - gst).to_i
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun

    # @param epoch [Numeric] Considered epoch, in Julian days
    def initialize(epoch:)
      @epoch = epoch
    end

    def true_ecliptic_coordinates
      Coordinates::Ecliptic.new(
        latitude: Angle.zero,
        longitude: true_longitude
      )
    end

    def apparent_ecliptic_coordinates
      nutation = Nutation.for_ecliptic_longitude(epoch: @epoch)
      longitude_with_aberration = Aberration.for_ecliptic_coordinates(
        coordinates: true_ecliptic_coordinates,
        epoch: @epoch
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
      time = Epoch.to_utc(@epoch)

      apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: @epoch)
        .to_horizontal(time: time, latitude: latitude, longitude: longitude)
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Time] Time of sunrise
    def rising_time(observer:)
      rise_transit_set(observer).rising_time
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Astronoby::Angle, nil] Azimuth of sunrise
    def rising_azimuth(observer:)
      rise_transit_set(observer).rising_azimuth
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Time] Time of sunset
    def setting_time(observer:)
      rise_transit_set(observer).setting_time
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Astronoby::Angle, nil] Azimuth of sunset
    def setting_azimuth(observer:)
      rise_transit_set(observer).setting_azimuth
    end

    def transit_time(observer:)
      rise_transit_set(observer).transit_time
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Astronoby::Angle] Altitude at transit
    def transit_altitude(observer:)
      rise_transit_set(observer).transit_altitude
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Time] Time the morning civil twilight starts
    def morning_civil_twilight_time(observer:)
      twilight_time(CIVIL, MORNING, observer)
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Time, nil] Time the evening civil twilight ends
    def evening_civil_twilight_time(observer:)
      twilight_time(CIVIL, EVENING, observer)
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Time, nil] Time the morning nautical twilight starts
    def morning_nautical_twilight_time(observer:)
      twilight_time(NAUTICAL, MORNING, observer)
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Time, nil] Time the evening nautical twilight ends
    def evening_nautical_twilight_time(observer:)
      twilight_time(NAUTICAL, EVENING, observer)
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Time, nil] Time the morning astronomical twilight starts
    def morning_astronomical_twilight_time(observer:)
      twilight_time(ASTRONOMICAL, MORNING, observer)
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Time, nil] Time the evening astronomical twilight ends
    def evening_astronomical_twilight_time(observer:)
      twilight_time(ASTRONOMICAL, EVENING, observer)
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

      Angle.from_degrees((Angle.atan(tan).degrees * 2) % 360)
    end

    # @return [Astronoby::Angle] Sun's longitude at perigee
    def longitude_at_perigee
      Angle.from_degrees(
        (281.2208444 + 1.719175 * centuries + 0.000452778 * centuries**2) % 360
      )
    end

    # @return [Astronoby::Angle] Sun's orbital eccentricity
    def orbital_eccentricity
      Angle.from_degrees(
        (0.01675104 - 0.0000418 * centuries - 0.000000126 * centuries**2) % 360
      )
    end

    private

    def true_longitude
      Angle.from_degrees(
        (true_anomaly + longitude_at_perigee).degrees % 360
      )
    end

    def mean_anomaly
      Angle.from_degrees(
        (longitude_at_base_epoch - longitude_at_perigee).degrees % 360
      )
    end

    def days_since_epoch
      Epoch::DEFAULT_EPOCH - @epoch
    end

    def centuries
      @centuries ||= (@epoch - Epoch::J1900) / Epoch::DAYS_PER_JULIAN_CENTURY
    end

    def longitude_at_base_epoch
      Angle.from_degrees(
        (279.6966778 + 36000.76892 * centuries + 0.0003025 * centuries**2) % 360
      )
    end

    def distance_angular_size_factor
      term1 = 1 + orbital_eccentricity.degrees * true_anomaly.cos
      term2 = 1 - orbital_eccentricity.degrees**2

      term1 / term2
    end

    def current_date
      Epoch.to_utc(@epoch).to_date
    end

    def rise_transit_set(observer)
      @rise_transit_set ||= {}
      return @rise_transit_set[observer] if @rise_transit_set.key?(observer)

      @rise_transit_set[observer] = begin
        date = Epoch.to_utc(@epoch).to_date
        yesterday_epoch = Epoch.from_time(date.prev_day)
        tomorrow_epoch = Epoch.from_time(date.next_day)

        coordinates_of_the_previous_day = self.class
          .new(epoch: yesterday_epoch)
          .apparent_ecliptic_coordinates
          .to_apparent_equatorial(epoch: yesterday_epoch)
        coordinates_of_the_day =
          apparent_ecliptic_coordinates.to_apparent_equatorial(epoch: @epoch)
        coordinates_of_the_next_day = self.class
          .new(epoch: tomorrow_epoch)
          .apparent_ecliptic_coordinates
          .to_apparent_equatorial(epoch: tomorrow_epoch)

        Events::ObservationEvents.new(
          observer: observer,
          date: date,
          coordinates_of_the_previous_day: coordinates_of_the_previous_day,
          coordinates_of_the_day: coordinates_of_the_day,
          coordinates_of_the_next_day: coordinates_of_the_next_day,
          additional_altitude: Angle.from_degrees(angular_size.degrees / 2)
        )
      end
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 50 - Twilight
    def twilight_time(twilight, period_of_the_day, observer)
      period_time = if period_of_the_day == MORNING
        rising_time(observer: observer)
      else
        setting_time(observer: observer)
      end

      hour_angle_at_period = equatorial_coordinates_at_midday
        .compute_hour_angle(time: period_time, longitude: observer.longitude)

      zenith_angle = TWILIGHT_ANGLES[twilight]

      term1 = zenith_angle.cos -
        observer.latitude.sin *
          equatorial_coordinates_at_midday.declination.sin
      term2 = observer.latitude.cos *
        equatorial_coordinates_at_midday.declination.cos
      hour_angle_ratio_at_twilight = term1 / term2
      return nil unless hour_angle_ratio_at_twilight.between?(-1, 1)

      hour_angle_at_twilight = Angle.acos(hour_angle_ratio_at_twilight)
      time_sign = -1

      if period_of_the_day == MORNING
        hour_angle_at_twilight =
          Angle.from_degrees(360 - hour_angle_at_twilight.degrees)
        time_sign = 1
      end

      twilight_in_hours =
        time_sign * (hour_angle_at_twilight - hour_angle_at_period).hours *
        GreenwichSiderealTime::SIDEREAL_MINUTE_IN_UT_MINUTE
      twilight_in_seconds = time_sign * twilight_in_hours * 3600
      (period_time + twilight_in_seconds).round
    end

    def midday
      utc_from_epoch = Epoch.to_utc(@epoch)
      Time.utc(
        utc_from_epoch.year,
        utc_from_epoch.month,
        utc_from_epoch.day,
        12
      )
    end

    def equatorial_coordinates_at_midday
      apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: Epoch.from_time(midday))
    end
  end
end
