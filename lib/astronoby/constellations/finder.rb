# frozen_string_literal: true

module Astronoby
  module Constellations
    class Finder
      # Finds the constellation that contains the given B1875 equatorial
      #   coordinates.
      # @param equatorial_coordinates [Astronoby::Coordinates::Equatorial] The
      #   B1875 coordinates to search for.
      # @return [Astronoby::Constellation, nil] The constellation that contains
      #   the coordinates, or nil if none is found.
      def self.find(equatorial_coordinates)
        ra_hours = equatorial_coordinates.right_ascension.hours
        dec_degrees = equatorial_coordinates.declination.degrees
        ra_index = Data
          .sorted_right_ascensions
          .bsearch_index { _1 >= ra_hours }
        dec_index = Data
          .sorted_declinations
          .bsearch_index { _1 > dec_degrees }

        return if ra_index.nil? || dec_index.nil?

        abbreviation_index = Data.radec_to_index.dig(ra_index, dec_index)

        return if abbreviation_index.nil?

        constellation_abbreviation =
          Data.indexed_abbreviations[abbreviation_index]

        Repository.get(constellation_abbreviation)
      end
    end
  end
end
