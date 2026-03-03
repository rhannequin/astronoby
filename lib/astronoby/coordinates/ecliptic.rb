# frozen_string_literal: true

module Astronoby
  module Coordinates
    # Ecliptic coordinate system (latitude and longitude relative to the
    # ecliptic plane).
    class Ecliptic
      # @return [Astronoby::Angle] ecliptic latitude
      attr_reader :latitude

      # @return [Astronoby::Angle] ecliptic longitude
      attr_reader :longitude

      # @param latitude [Astronoby::Angle] ecliptic latitude
      # @param longitude [Astronoby::Angle] ecliptic longitude
      def initialize(latitude:, longitude:)
        @latitude = latitude
        @longitude = longitude
      end

      # @return [Astronoby::Coordinates::Ecliptic] zero coordinates
      def self.zero
        new(latitude: Angle.zero, longitude: Angle.zero)
      end
    end
  end
end
