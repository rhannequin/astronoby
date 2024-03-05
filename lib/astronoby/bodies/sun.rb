# frozen_string_literal: true

module Astronoby
  class Sun
    SEMI_MAJOR_AXIS_IN_METERS = 149_598_500_000
    ANGULAR_DIAMETER = Angle.as_degrees(0.533128)

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun

    # @param epoch [Numeric] Considered epoch, in Julian days
    def initialize(epoch:)
      @epoch = epoch
    end

    # @return [Astronoby::Coordinates::Ecliptic] Sun's ecliptic coordinates
    def ecliptic_coordinates
      Coordinates::Ecliptic.new(
        latitude: Angle.zero,
        longitude: Angle.as_degrees(
          (true_anomaly + longitude_at_perigee).degrees % 360
        )
      )
    end

    # Computes the Sun's horizontal coordinates
    #
    # @param latitude [Astronoby::Angle] Latitude of the observer
    # @param longitude [Astronoby::Angle] Longitude of the observer
    # @return [Astronoby::Coordinates::Horizontal] Sun's horizontal coordinates
    def horizontal_coordinates(latitude:, longitude:)
      time = Epoch.to_utc(@epoch)

      ecliptic_coordinates
        .to_equatorial(epoch: @epoch)
        .to_horizontal(time: time, latitude: latitude, longitude: longitude)
    end

    # @return [Numeric] Earth-Sun distance in meters
    def earth_distance
      SEMI_MAJOR_AXIS_IN_METERS / distance_angular_size_factor
    end

    # @return [Astronoby::Angle] Apparent Sun's angular size
    def angular_size
      Angle.as_degrees(ANGULAR_DIAMETER.degrees * distance_angular_size_factor)
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

      Angle.as_degrees((Angle.atan(tan).degrees * 2) % 360)
    end

    # @return [Astronoby::Angle] Sun's longitude at perigee
    def longitude_at_perigee
      Angle.as_degrees(
        (281.2208444 + 1.719175 * centuries + 0.000452778 * centuries**2) % 360
      )
    end

    # @return [Astronoby::Angle] Sun's orbital eccentricity
    def orbital_eccentricity
      Angle.as_degrees(
        (0.01675104 - 0.0000418 * centuries - 0.000000126 * centuries**2) % 360
      )
    end

    private

    def mean_anomaly
      Angle.as_degrees(
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
      Angle.as_degrees(
        (279.6966778 + 36000.76892 * centuries + 0.0003025 * centuries**2) % 360
      )
    end

    def distance_angular_size_factor
      term1 = 1 + orbital_eccentricity.degrees * true_anomaly.cos
      term2 = 1 - orbital_eccentricity.degrees**2

      term1 / term2
    end
  end
end
