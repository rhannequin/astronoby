# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Horizontal
      def initialize(azimuth:, horizon:)
        @azimuth = azimuth
        @horizon = horizon
      end
    end
  end
end
