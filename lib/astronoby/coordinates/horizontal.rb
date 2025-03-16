# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Horizontal
      attr_reader :azimuth, :altitude, :observer

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
