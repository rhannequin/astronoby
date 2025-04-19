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
      ::Ephem::Download.call(name: name, target: target)
    end

    # Load an ephemeris file.
    #
    # @param target [String] Path of the ephemeris file
    # @return [::Ephem::SPK] Ephemeris object from the Ephem gem
    #
    # @example Loading previously downloaded de440t SPK from NASA JPL
    #   Astronoby::Ephem.load("tmp/de440t.bsp")
    def self.load(target)
      spk = ::Ephem::SPK.open(target)
      unless ::Ephem::SPK::TYPES.include?(spk&.type)
        raise(
          EphemerisError,
          "#{target} is not a valid type. Accepted: #{::Ephem::SPK::TYPES.join(", ")}"
        )
      end

      spk
    end
  end
end
