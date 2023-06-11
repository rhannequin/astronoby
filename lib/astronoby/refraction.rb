# frozen_string_literal: true

module Astronoby
  class Refraction
    DEFAULT_PRESSURE = 1000
    DEFAULT_TEMPERATURE = 25

    def self.for_horizontal_coordinates(
      coordinates:,
      pressure: DEFAULT_PRESSURE,
      temperature: DEFAULT_TEMPERATURE
    )
      new(coordinates, pressure, temperature).refract
    end

    def initialize(coordinates, pressure, temperature)
      @coordinates = coordinates
      @pressure = pressure
      @temperature = temperature
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 37 - Refraction
    def refract
      altitude_in_degrees = @coordinates.altitude.to_degrees.value

      refraction_angle = Astronoby::Angle.as_degrees(
        if altitude_in_degrees > 15
          zenith_angle = Astronoby::Angle.as_degrees(
            90 - @coordinates.altitude.value
          )
          0.00452 * @pressure * Math.tan(zenith_angle.to_radians.value) / (273 + @temperature)
        else
          (
            @pressure *
            (
              0.1594 +
              0.0196 * altitude_in_degrees +
              0.00002 * altitude_in_degrees * altitude_in_degree
            )
          )./(
            (273 + @temperature) *
            (
              1 +
              0.505 * altitude_in_degrees +
              0.0845 * altitude_in_degrees * altitude_in_degrees
            )
          )
        end
      )

      Astronoby::Coordinates::Horizontal.new(
        azimuth: @coordinates.azimuth,
        altitude: Astronoby::Angle.as_degrees(
          @coordinates.altitude.to_degrees.value +
          refraction_angle.value
        ),
        latitude: @coordinates.latitude,
        longitude: @coordinates.longitude
      )
    end
  end
end
