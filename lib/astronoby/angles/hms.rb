# frozen_string_literal: true

module Astronoby
  # Represents an angle in hours, minutes, seconds (HMS) notation.
  class Hms
    # @return [Integer] hours component
    attr_reader :hours

    # @return [Integer] minutes component
    attr_reader :minutes

    # @return [Float] seconds component
    attr_reader :seconds

    # @param hours [Integer] hours component
    # @param minutes [Integer] minutes component
    # @param seconds [Float] seconds component
    def initialize(hours, minutes, seconds)
      @hours = hours
      @minutes = minutes
      @seconds = seconds
    end

    # @param precision [Integer] decimal places for the seconds component
    # @return [String] the formatted HMS string (e.g., "12h 30m 45.0000s")
    def format(precision: 4)
      "#{hours}h #{minutes}m #{seconds.floor(precision)}s"
    end
  end
end
