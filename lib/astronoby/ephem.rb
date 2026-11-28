# frozen_string_literal: true

require "ephem"

module Astronoby
  # Loads and downloads SPK kernels. An instance reads several loaded kernels
  # as one ephemeris, so that a body missing from one kernel is found in
  # another.
  class Ephem
    LIGHT_TIME_MARGIN_IN_DAYS = 0.25
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

    # @api private
    def coverage
      @coverage ||= begin
        first, last = read_pairs
          .map { |pair| spans_of(@pairs[pair]) }
          .reduce { |spans, others| intersect(spans, others) }
          &.max_by { |first, last| last - first }
        unless first
          raise EphemerisError,
            "The kernels have no dates at which they cover every body they hold"
        end

        [first + LIGHT_TIME_MARGIN_IN_DAYS, last]
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

    def read_pairs
      Sky::BODIES.values
        .flat_map { |body| body.ephemeris_segments(@type) }
        .uniq
        .select { |pair| @pairs.key?(pair) }
    end

    def spans_of(source)
      segments = source.respond_to?(:segments) ? source.segments : [source]
      segments
        .map { |segment| [segment.start_jd, segment.end_jd] }
        .sort
        .each_with_object([]) do |(first, last), spans|
          if spans.any? && first <= spans.last[1]
            spans.last[1] = [spans.last[1], last].max
          else
            spans << [first, last]
          end
        end
    end

    def intersect(spans, others)
      spans.product(others).filter_map do |(a, b), (c, d)|
        first = [a, c].max
        last = [b, d].min
        [first, last] if first < last
      end
    end

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
