# frozen_string_literal: true

module Astronoby
  class Sun
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun

    def initialize(epoch:)
      @epoch = epoch
    end

    def ecliptic_coordinates
      Coordinates::Ecliptic.new(
        latitude: Angle.zero,
        longitude: Angle.as_degrees(
          (true_anomaly + longitude_at_perigee).degrees % 360
        )
      )
    end

    def horizontal_coordinates(latitude:, longitude:)
      time = Astronoby::Epoch.to_utc(@epoch)

      ecliptic_coordinates
        .to_equatorial(epoch: @epoch)
        .to_horizontal(time: time, latitude: latitude, longitude: longitude)
    end

    private

    def mean_anomaly
      Angle.as_degrees(
        (longitude_at_base_epoch - longitude_at_perigee).degrees % 360
      )
    end

    def true_anomaly
      eccentric_anomaly = Astronoby::Util::Astrodynamics.eccentric_anomaly_newton_raphson(
        mean_anomaly,
        orbital_eccentricity.degrees,
        2e-06,
        10
      )

      tan = Math.sqrt(
        (1 + orbital_eccentricity.degrees) / (1 - orbital_eccentricity.degrees)
      ) * Math.tan(eccentric_anomaly.radians / 2)

      Astronoby::Angle.as_degrees(
        (Astronoby::Angle.as_radians(Math.atan(tan)).degrees * 2) % 360
      )
    end

    def days_since_epoch
      Epoch::DEFAULT_EPOCH - @epoch
    end

    def t
      @t ||=
        (@epoch - Astronoby::Epoch::J1900) / Astronoby::Epoch::DAYS_PER_JULIAN_CENTURY
    end

    def longitude_at_base_epoch
      Astronoby::Angle.as_degrees(
        (279.6966778 + 36000.76892 * t + 0.0003025 * t * t) % 360
      )
    end

    def longitude_at_perigee
      Astronoby::Angle.as_degrees(
        (281.2208444 + 1.719175 * t + 0.000452778 * t * t) % 360
      )
    end

    def orbital_eccentricity
      Astronoby::Angle.as_degrees(
        (0.01675104 - 0.0000418 * t - 0.000000126 * t * t) % 360
      )
    end
  end
end
