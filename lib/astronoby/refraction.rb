# frozen_string_literal: true

module Astronoby
  class Refraction
    LOW_ALTITUDE_BODY_ANGLE = Angle.from_degrees(15)
    ZENITH = Angle.from_degrees(90)

    def self.angle(coordinates:)
      new(coordinates).refraction_angle
    end

    def self.correct_horizontal_coordinates(coordinates:)
      new(coordinates).refract
    end

    def initialize(coordinates)
      @coordinates = coordinates
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 37 - Refraction
    def refract
      Coordinates::Horizontal.new(
        azimuth: @coordinates.azimuth,
        altitude: @coordinates.altitude + refraction_angle,
        observer: @coordinates.observer
      )
    end

    def refraction_angle
      if @coordinates.altitude > LOW_ALTITUDE_BODY_ANGLE
        high_altitude_angle
      else
        low_altitude_angle
      end
    end

    private

    def pressure
      @_pressure ||= @coordinates.observer.pressure
    end

    def temperature
      @_temperature ||= @coordinates.observer.temperature
    end

    def altitude_in_degrees
      @_altitude_in_degrees ||= @coordinates.altitude.degrees
    end

    def high_altitude_angle
      zenith_angle = ZENITH - @coordinates.altitude
      Angle.from_degrees(0.00452 * pressure * zenith_angle.tan / temperature)
    end

    def low_altitude_angle
      term1 = pressure * (
        0.1594 + 0.0196 * altitude_in_degrees + 0.00002 * altitude_in_degrees**2
      )
      term2 = temperature * (
        1 + 0.505 * altitude_in_degrees + 0.0845 * altitude_in_degrees**2
      )

      Angle.from_degrees(term1 / term2)
    end
  end
end
