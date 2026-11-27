# frozen_string_literal: true

require "astronoby/sky/target"
require "astronoby/sky/target_point"

module Astronoby
  # The entry point to everything computed from an ephemeris. Load it once and
  # share it: loading the same file twice duplicates the segment data read
  # from it.
  #
  # Solar System bodies taken from the same sky at the same instant share
  # Earth's and the Sun's positions, precession and nutation.
  #
  # @example
  #   sky = Astronoby::Sky.load("inpop19a.bsp")
  #   sky.saturn.at(instant).observed_by(observer).horizontal
  #   sky.mars.at(instant).elongation
  #   sky[vega].at(instant).apparent
  #   sky.over(observer).passes(sky.saturn).on(date)
  #   sky.mars.oppositions.between(start, finish)
  #   sky.seasons.in(2026).june_solstice
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

    # @param paths [Array<String>] SPK kernels; at a date covered by several
    #   of them, the first one wins
    # @param orientation [String, nil] binary PCK lunar orientation kernel
    # @return [Astronoby::Sky]
    def self.load(*paths, orientation: nil)
      new(
        *paths.map { |path| Ephem.load(path) },
        orientation: orientation && Orientation.load(orientation)
      )
    end

    # @param kernels [Array<::Ephem::SPK>] loaded SPK kernels; at a date
    #   covered by several of them, the first one wins
    # @param orientation [Astronoby::Orientation, nil] lunar orientation
    #   kernel
    # @raise [ArgumentError] without kernels, or with kernels of different
    #   types
    # @raise [Astronoby::EphemerisError] if no kernel is of a supported type
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

    # @return [Astronoby::Seasons] the equinoxes and solstices
    def seasons
      @seasons ||= Seasons.new(ephem: @ephem)
    end

    # @param observer [Astronoby::Observer]
    # @return [Astronoby::LocalSky] the sky as seen by the observer
    def over(observer)
      LocalSky.new(sky: self, observer: observer)
    end

    # The snapshot of this sky at the instant. The last one is kept per
    # fiber, so that bodies asked for at the same instant share it without
    # any lock.
    #
    # @api private
    # @param instant [Astronoby::Instant]
    # @return [Astronoby::Sky::Snapshot]
    def snapshot_at(instant)
      sky, snapshot = Thread.current[:astronoby_sky_snapshot]
      return snapshot if sky.equal?(self) && snapshot.instant == instant

      snapshot =
        Snapshot.new(ephem: @ephem, instant: instant, orientation: @orientation)
      Thread.current[:astronoby_sky_snapshot] = [self, snapshot]
      snapshot
    end

    # Closes the kernels and forgets this fiber's snapshot of the sky. A
    # snapshot kept by another fiber holds the sky until that fiber asks a sky
    # for another one.
    #
    # @return [void]
    def close
      sky, _snapshot = Thread.current[:astronoby_sky_snapshot]
      Thread.current[:astronoby_sky_snapshot] = nil if sky.equal?(self)
      @ephem.close
    end

    def inspect
      "#<#{self.class} #{@ephem.inspect}>"
    end
  end
end
