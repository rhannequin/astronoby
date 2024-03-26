# frozen_string_literal: true

module Astronoby
  class Aberration
    def self.for_ecliptic_coordinates(coordinates:, epoch:)
      new(coordinates, epoch).apply
    end

    def initialize(coordinates, epoch)
      @coordinates = coordinates
      @epoch = epoch
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 36 - Aberration
    def apply
      delta_longitude = Angle.as_degrees(
        -20.5 * (
          sun_longitude - @coordinates.longitude
        ).cos / @coordinates.latitude.cos / 3600
      )

      delta_latitude = Angle.as_degrees(
        -20.5 *
        (sun_longitude - @coordinates.longitude).sin *
        @coordinates.latitude.sin / 3600
      )

      Coordinates::Ecliptic.new(
        latitude: @coordinates.latitude + delta_latitude,
        longitude: @coordinates.longitude + delta_longitude
      )
    end

    def sun_longitude
      @_sun_longitude ||= Sun
        .new(epoch: @epoch)
        .true_ecliptic_coordinates
        .longitude
    end
  end
end
