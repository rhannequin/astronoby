# frozen_string_literal: true

module Astronoby
  class Center
    BARYCENTRIC = :barycentric
    GEOCENTRIC = :geocentric
    TOPOCENTRIC = :topocentric

    class << self
      # @return [Astronoby::Center] the Solar System barycenter
      def barycentric
        @barycentric ||= new(kind: BARYCENTRIC)
      end

      # @return [Astronoby::Center] the Earth's center
      def geocentric
        @geocentric ||= new(kind: GEOCENTRIC)
      end

      # @param observer [Astronoby::Observer] the observer
      # @return [Astronoby::Center] a center at the observer's location
      def topocentric(observer)
        new(kind: TOPOCENTRIC, observer: observer)
      end
    end

    # @return [Symbol] the kind of center
    attr_reader :kind

    # @return [Astronoby::Observer, nil] the observer, for topocentric centers
    attr_reader :observer

    # @param kind [Symbol] one of BARYCENTRIC, GEOCENTRIC, TOPOCENTRIC
    # @param observer [Astronoby::Observer, nil] the observer, for topocentric
    def initialize(kind:, observer: nil)
      @kind = kind
      @observer = observer
      freeze
    end

    # @return [Boolean] true if the center is the Solar System barycenter
    def barycentric?
      @kind == BARYCENTRIC
    end

    # @return [Boolean] true if the center is the Earth's center
    def geocentric?
      @kind == GEOCENTRIC
    end

    # @return [Boolean] true if the center is at an observer's location
    def topocentric?
      @kind == TOPOCENTRIC
    end

    # @return [Boolean] true if the center depends on a specific observer
    def observer_dependent?
      topocentric?
    end

    # @param other [Astronoby::Center] center to compare with
    # @return [Boolean] true if both centers are equivalent
    def ==(other)
      other.is_a?(self.class) &&
        kind == other.kind &&
        location_key == other.location_key
    end
    alias_method :eql?, :==

    # @return [Integer] hash value
    def hash
      [self.class, @kind, location_key].hash
    end

    protected

    # @return [Array, nil] the geometric location key, or nil if not topocentric
    def location_key
      return unless @observer

      [@observer.latitude, @observer.longitude, @observer.elevation]
    end
  end
end
