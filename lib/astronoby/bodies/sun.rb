# frozen_string_literal: true

module Astronoby
  class Sun
    SEMI_MAJOR_AXIS_IN_METERS = 149_598_500_000
    ANGULAR_DIAMETER = Angle.from_degrees(0.533128)
    INTERPOLATION_FACTOR = 24.07

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

    # @param observer [Astronoby::Observer] Observer of the events
    # @return [Array<Time, Time, Time>, nil] Sunrise, transit and sunset times
    def rise_transit_set_times(observer:)
      rise_transit_set(observer).times
    end

    # @param observer [Astronoby::Observer] Observer of the events
    # @return [Array<Astronoby::Angle, Astronoby::Angle>] Azimuths of sunrise
    #   and sunset
    def rise_set_azimuths(observer:)
      rise_transit_set(observer).azimuths
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Time] Time of sunrise
    def rising_time(observer:)
      rise_transit_set(observer).times[0]
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Astronoby::Angle, nil] Azimuth of sunrise
    def rising_azimuth(observer:)
      rise_transit_set(observer).azimuths[0]
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Time] Time of sunset
    def setting_time(observer:)
      rise_transit_set(observer).times[2]
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Astronoby::Angle, nil] Azimuth of sunset
    def setting_azimuth(observer:)
      rise_transit_set(observer).azimuths[1]
    end

    def transit_time(observer:)
      rise_transit_set(observer).times[1]
    end

    # @param observer [Astronoby::Observer] Observer of the event
    # @return [Astronoby::Angle] Altitude at transit
    def transit_altitude(observer:)
      rise_transit_set(observer).transit_altitude
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

        RiseTransitSet.new(
          observer: observer,
          date: date,
          coordinates_of_the_previous_day: coordinates_of_the_previous_day,
          coordinates_of_the_day: coordinates_of_the_day,
          coordinates_of_the_next_day: coordinates_of_the_next_day,
          additional_altitude: Angle.from_degrees(angular_size.degrees / 2)
        )
      end
    end
  end
end
