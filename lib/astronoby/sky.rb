# frozen_string_literal: true

require "astronoby/sky/target"

module Astronoby
  # The entry point to everything computed from an ephemeris. Load it once and
  # share it: loading the same file twice duplicates the segment data read
  # from it.
  #
  # Bodies taken from the same sky at the same instant share Earth's and the
  # Sun's positions, precession and nutation.
  #
  # @example
  #   sky = Astronoby::Sky.load("inpop19a.bsp")
  #   sky.saturn.at(instant).observed_by(observer).horizontal
  #   sky.mars.at(instant).elongation
  #   sky[vega].at(instant).apparent
  class Sky
    BODIES = {
      sun: Sun,
      mercury: Mercury,
      venus: Venus,
      earth: Earth,
      moon: Moon,
      mars: Mars,
      jupiter: Jupiter,
      saturn: Saturn,
      uranus: Uranus,
      neptune: Neptune
    }.freeze

    SNAPSHOTS_KEPT = 8
    private_constant :SNAPSHOTS_KEPT

    # @param paths [Array<String>] SPK kernels; the first one wins when
    #   several have a segment for the same center and target
    # @param orientation [String, nil] binary PCK lunar orientation kernel
    # @return [Astronoby::Sky]
    def self.load(*paths, orientation: nil)
      new(
        *paths.map { |path| Ephem.load(path) },
        orientation: orientation && Orientation.load(orientation)
      )
    end

    # @param kernels [Array<::Ephem::SPK>] loaded SPK kernels; the first one
    #   wins when several have a segment for the same center and target
    # @param orientation [Astronoby::Orientation, nil] lunar orientation
    #   kernel
    # @raise [ArgumentError] without kernels, or with kernels of different
    #   types
    def initialize(*kernels, orientation: nil)
      @ephem = Ephem.new(*kernels)
      @orientation = orientation
      @targets = BODIES.transform_values do |body_class|
        Target.new(sky: self, body: body_class)
      end
    end

    # @api private
    # @return [Astronoby::Ephem] the kernels read as one ephemeris
    attr_reader :ephem

    BODIES.each_key do |name|
      define_method(name) { @targets.fetch(name) }
    end

    # @return [Array<Astronoby::Sky::Target>] Mercury to Neptune, without
    #   Earth
    def planets
      @targets.values.select { |target| target.body.planet? }
    end

    # @param object [Astronoby::DeepSkyObject] an object defined outside the
    #   ephemeris
    # @return [Astronoby::Sky::Target] the object, corrected for parallax,
    #   aberration and light deflection from this sky's Earth and Sun
    # @raise [ArgumentError] if the object is not a deep-sky object
    def [](object)
      unless object.is_a?(DeepSkyObject)
        raise ArgumentError,
          "Expected an Astronoby::DeepSkyObject, got #{object.inspect}"
      end

      Target.new(sky: self, body: object)
    end

    # The snapshot of this sky at the instant. The last few are kept per
    # fiber, so that bodies asked for at the same instant share one without
    # any lock.
    #
    # @api private
    # @param instant [Astronoby::Instant]
    # @return [Astronoby::Sky::Snapshot]
    def snapshot_at(instant)
      recent = Thread.current[:astronoby_sky_snapshots] ||= {}
      recent[[self, instant]] ||= begin
        recent.shift if recent.size >= SNAPSHOTS_KEPT
        Snapshot.new(ephem: @ephem, instant: instant, orientation: @orientation)
      end
    end

    def inspect
      "#<#{self.class} #{@ephem.inspect}>"
    end
  end
end
