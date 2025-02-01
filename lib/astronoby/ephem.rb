# frozen_string_literal: true

require "ephem"

module Astronoby
  class Ephem
    # Download an ephemeris file.
    #
    # @param name [String] Name of the ephemeris file, supported by the Ephem
    #   gem
    # @param target [String] Location where to store the file
    # @return [Boolean] true if the download was successful, false otherwise
    #
    # @example Downloading de440t SPK from NASA JPL
    #   Astronoby::Ephem.download(name: "de440t.bsp", target: "tmp/de440t.bsp")
    def self.download(name:, target:)
      response = ::Ephem::IO::Download.call(name: name, target: target)

      !!response&.is_a?(Net::HTTPOK)
    end

    # Load an ephemeris file.
    #
    # @param target [String] Path of the ephemeris file
    # @return [::Ephem::SPK] Ephemeris object from the Ephem gem
    #
    # @example Loading previously downloaded de440t SPK from NASA JPL
    #   Astronoby::Ephem.load("tmp/de440t.bsp")
    def self.load(target)
      ::Ephem::SPK.open(target)
    end
  end
end
