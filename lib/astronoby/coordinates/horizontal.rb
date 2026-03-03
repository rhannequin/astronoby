# frozen_string_literal: true

module Astronoby
  module Coordinates
    # Horizontal coordinate system (azimuth and altitude) for a specific
    # observer.
    class Horizontal
      # @return [Astronoby::Angle] azimuth (measured from north, clockwise)
      attr_reader :azimuth

      # @return [Astronoby::Angle] altitude above the horizon
      attr_reader :altitude

      # @return [Astronoby::Observer] the observer
      attr_reader :observer

      # @param azimuth [Astronoby::Angle] azimuth
      # @param altitude [Astronoby::Angle] altitude
      # @param observer [Astronoby::Observer] the observer
      def initialize(
        azimuth:,
        altitude:,
        observer:
      )
        @azimuth = azimuth
        @altitude = altitude
        @observer = observer
      end
    end
  end
end
