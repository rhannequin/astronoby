# frozen_string_literal: true

module Astronoby
  module Constellations
    class Repository
      # Returns a constellation object for the given abbreviation.
      # @param abbreviation [String] The abbreviation of the constellation.
      # @return [Astronoby::Constellation, nil] The constellation object or nil
      #   if not found.
      def self.get(abbreviation)
        @constellations ||= Data.constellation_names.map do |abbr, name|
          constellation = Constellation.new(name, abbr)
          [abbr, constellation]
        end.to_h

        @constellations[abbreviation]
      end
    end
  end
end
