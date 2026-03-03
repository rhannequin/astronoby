# frozen_string_literal: true

module Astronoby
  # Represents an IAU constellation with its full name and standard
  # three-letter abbreviation.
  class Constellation
    # @return [String] the constellation name (e.g., "Orion")
    attr_reader :name

    # @return [String] the IAU three-letter abbreviation (e.g., "Ori")
    attr_reader :abbreviation

    # @param name [String] the constellation name
    # @param abbreviation [String] the IAU abbreviation
    def initialize(name, abbreviation)
      @name = name
      @abbreviation = abbreviation
    end
  end
end
