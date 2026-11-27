# frozen_string_literal: true

require "ephem"

module Astronoby
  # Loads and downloads SPK kernels. An instance reads several loaded kernels
  # as one ephemeris, so that a body missing from one kernel is found in
  # another.
  class Ephem
    # Download an ephemeris file.
    #
    # @param name [String] Name of the ephemeris file, supported by the Ephem
    #   gem
    # @param target [String] Location where to store the file
    # @return [Boolean] true once the file is written
    # @raise [::Ephem::DownloadError] if the server answers with an error or
    #   the archive does not contain the file
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

    # @api private
    #
    # @param kernels [Array<::Ephem::SPK>] loaded kernels; at a date covered
    #   by several of them, the first one wins
    # @raise [ArgumentError] without kernels, or with kernels of different
    #   types, whose bodies are not split into the same segments
    # @raise [Astronoby::EphemerisError] if no kernel is of a supported type
    def initialize(*kernels)
      raise ArgumentError, "At least one kernel is required" if kernels.empty?

      types = kernels.filter_map(&:type).uniq
      if types.size > 1
        raise ArgumentError,
          "Kernels of different types cannot be combined: #{types.join(", ")}"
      end
      if types.empty?
        raise EphemerisError,
          "No kernel is of a supported type. Accepted: " \
          "#{::Ephem::SPK::TYPES.join(", ")}"
      end

      @type = types.first
      @kernels = kernels
      @pairs = pairs_across(kernels)
    end

    # @return [String] the kernels' type, IMCCE INPOP or JPL DE
    attr_reader :type

    # Same contract as ::Ephem::SPK#[], looking across every kernel.
    #
    # @param center [Integer] NAIF ID of the center body
    # @param target [Integer] NAIF ID of the target body
    # @return [::Ephem::Segments::Segment, ::Ephem::Segments::PositionGroup]
    # @raise [KeyError] if no kernel has a segment for the pair
    def [](center, target)
      @pairs.fetch([center, target]) do
        raise KeyError,
          "No kernel has a segment for center: #{center}, target: #{target}"
      end
    end

    # Closes every kernel.
    #
    # @return [void]
    def close
      @kernels.each(&:close)
    end

    def inspect
      kernels = (@kernels.size == 1) ? "1 kernel" : "#{@kernels.size} kernels"
      "#<#{self.class} #{@type}, #{kernels}>"
    end

    private

    # Each pair routes a date to the segment covering it. Segments of the first
    # kernel come last, as the group picks the last segment covering the date.
    def pairs_across(kernels)
      kernels
        .reverse
        .flat_map(&:segments)
        .group_by { |segment| [segment.center, segment.target] }
        .transform_values do |segments|
          ::Ephem::Segments::PositionGroup.wrap(segments)
        end
    end
  end
end
