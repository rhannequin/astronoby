# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Ecliptic
      attr_reader :latitude, :longitude

      def initialize(latitude:, longitude:)
        @latitude = latitude
        @longitude = longitude
      end

      def self.zero
        new(latitude: Angle.zero, longitude: Angle.zero)
      end
    end
  end
end
