# frozen_string_literal: true

module Astronoby
  module Coordinates
    # Horizontal coordinate system (azimuth and altitude) for a specific
    # observer.
    class Horizontal
      # @return [Astronoby::Angle] azimuth (measured from north, clockwise)
      attr_reader :azimuth

      # @return [Astronoby::Angle] altitude above the horizon, true or
      #   apparent depending on {#refracted?}
      attr_reader :altitude

      # @return [Astronoby::Observer] the observer
      attr_reader :observer

      # @param azimuth [Astronoby::Angle] azimuth
      # @param altitude [Astronoby::Angle] altitude
      # @param observer [Astronoby::Observer] the observer
      # @param refracted [Boolean] whether the altitude includes atmospheric
      #   refraction
      def initialize(
        azimuth:,
        altitude:,
        observer:,
        refracted: false
      )
        @azimuth = azimuth
        @altitude = altitude
        @observer = observer
        @refracted = refracted
      end

      # @return [Boolean] true if the altitude is the apparent one, with
      #   atmospheric refraction, false if it is the true, geometric one
      def refracted?
        @refracted
      end

      # Returns the same coordinates as seen through the atmosphere, with the
      # refraction for the observer's temperature and pressure added to the
      # altitude.
      #
      # @return [Astronoby::Coordinates::Horizontal] refracted coordinates
      # @raise [Astronoby::IncompatibleArgumentsError] if the coordinates are
      #   already refracted
      def refract
        if refracted?
          raise IncompatibleArgumentsError,
            "The horizontal coordinates are already refracted"
        end

        self.class.new(
          azimuth: @azimuth,
          altitude: @altitude +
            Refraction.angle(altitude: @altitude, observer: @observer),
          observer: @observer,
          refracted: true
        )
      end
    end
  end
end
