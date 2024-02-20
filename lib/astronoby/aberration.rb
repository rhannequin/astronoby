# frozen_string_literal: true

module Astronoby
  class Aberration
    # TODO - Replace Sun longitude with epoch and compute Sun ecliptic
    # coordinates from it
    def self.for_ecliptic_coordinates(coordinates:, sun_longitude:)
      new(coordinates, sun_longitude).apply
    end

    def initialize(coordinates, sun_longitude)
      @coordinates = coordinates
      @sun_longitude = sun_longitude
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 36 - Aberration
    def apply
      delta_longitude = Astronoby::Angle.as_degrees(
        -20.5 *
        Math.cos(
          @sun_longitude.radians - @coordinates.longitude.radians
        ) / Math.cos(@coordinates.latitude.radians) / 3600
      )

      delta_latitude = Astronoby::Angle.as_degrees(
        -20.5 *
        Math.sin(@sun_longitude.radians - @coordinates.longitude.radians) *
        Math.sin(@coordinates.latitude.radians) / 3600
      )

      Astronoby::Coordinates::Ecliptic.new(
        latitude: @coordinates.latitude + delta_latitude,
        longitude: @coordinates.longitude + delta_longitude
      )
    end
  end
end
