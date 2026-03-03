# frozen_string_literal: true

module Astronoby
  # Represents an angle in degrees, arcminutes, arcseconds (DMS) notation.
  class Dms
    # @return [String] "+" or "-"
    attr_reader :sign

    # @return [Integer] degrees component
    attr_reader :degrees

    # @return [Integer] arcminutes component
    attr_reader :minutes

    # @return [Float] arcseconds component
    attr_reader :seconds

    # @param sign [String] "+" or "-"
    # @param degrees [Integer] degrees component
    # @param minutes [Integer] arcminutes component
    # @param seconds [Float] arcseconds component
    def initialize(sign, degrees, minutes, seconds)
      @sign = sign
      @degrees = degrees
      @minutes = minutes
      @seconds = seconds
    end

    # @param precision [Integer] decimal places for the seconds component
    # @return [String] the formatted DMS string (e.g., "+45° 30′ 15.0000″")
    def format(precision: 4)
      "#{sign}#{degrees}° #{minutes}′ #{seconds.floor(precision)}″"
    end
  end
end
