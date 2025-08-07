# frozen_string_literal: true

module Astronoby
  module Constellations
    class Data
      def self.sorted_right_ascensions
        @sorted_right_ascensions ||=
          read_file("sorted_right_ascensions.dat").map(&:to_f)
      end

      def self.sorted_declinations
        @sorted_declinations ||=
          read_file("sorted_declinations.dat").map(&:to_f)
      end

      def self.radec_to_index
        @radec_to_index ||=
          read_file("radec_to_index.dat").map do |line|
            line.split.map(&:to_i)
          end
      end

      def self.indexed_abbreviations
        @indexed_abbreviations ||=
          read_file("indexed_abbreviations.dat")
      end

      def self.constellation_names
        @constellation_names ||=
          read_file("constellation_names.dat").map(&:split)
      end

      def self.read_file(filename)
        File.readlines(data_path(filename)).map(&:strip)
      end

      def self.data_path(filename)
        File.join(__dir__, "..", "data", "constellations", filename)
      end
    end
  end
end
