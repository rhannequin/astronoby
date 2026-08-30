# frozen_string_literal: true

module Astronoby
  # A lunar eclipse: a geocentric passage of the Moon through Earth's shadow.
  # Immutable; built by LunarEclipseCalculator.
  #
  # The penumbral phase is always present. The partial phase is present for
  # partial and total eclipses, and the total phase only for total eclipses.
  class LunarEclipse
    PENUMBRAL = :penumbral
    PARTIAL = :partial
    TOTAL = :total

    # @return [Astronoby::Instant] greatest eclipse, when the Moon's centre is
    #   least distant from the axis of Earth's shadow
    attr_reader :instant
    alias_method :greatest_eclipse_instant, :instant

    # @return [Symbol] +PENUMBRAL+, +PARTIAL+ or +TOTAL+
    attr_reader :kind

    # @return [Astronoby::LunarEclipseGeometry] the geometry of Earth's shadow
    #   and the Moon's place in it at greatest eclipse. The geometry at each
    #   contact is on the phases.
    attr_reader :geometry

    # @return [Astronoby::LunarEclipsePhase] the penumbral phase (always present)
    attr_reader :penumbral

    # @return [Astronoby::LunarEclipsePhase, nil] the partial phase, present for
    #   partial and total eclipses
    attr_reader :partial

    # @return [Astronoby::LunarEclipsePhase, nil] the total phase (totality),
    #   present only for total eclipses
    attr_reader :total

    # @param instant [Astronoby::Instant] greatest eclipse
    # @param kind [Symbol] +PENUMBRAL+, +PARTIAL+ or +TOTAL+
    # @param geometry [Astronoby::LunarEclipseGeometry] the shadow geometry at
    #   greatest eclipse
    # @param penumbral [Astronoby::LunarEclipsePhase] the penumbral phase
    # @param partial [Astronoby::LunarEclipsePhase, nil] the partial phase
    # @param total [Astronoby::LunarEclipsePhase, nil] the total phase
    def initialize(
      instant:,
      kind:,
      geometry:,
      penumbral:,
      partial: nil,
      total: nil
    )
      @instant = instant
      @kind = kind
      @geometry = geometry
      @penumbral = penumbral
      @partial = partial
      @total = total
      freeze
    end

    # @return [Float] least distance of the Moon's centre from the axis of
    #   Earth's shadow at greatest eclipse, in Earth radii, positive when the
    #   Moon passes north of the axis
    def gamma
      sign = @geometry.north_of_axis? ? 1 : -1
      sign * @geometry.axis_distance.m /
        Constants::WGS84_EARTH_EQUATORIAL_RADIUS_IN_METERS
    end

    # @return [Float] fraction of the Moon's diameter immersed in the umbra at
    #   greatest eclipse (negative when the Moon misses the umbra)
    def umbral_magnitude
      @geometry.umbral_magnitude
    end

    # @return [Float] fraction of the Moon's diameter immersed in the penumbra
    #   at greatest eclipse
    def penumbral_magnitude
      @geometry.penumbral_magnitude
    end

    # @return [Astronoby::Distance] least distance of the Moon's centre from the
    #   axis of Earth's shadow at greatest eclipse. This is the unsigned length
    #   of which gamma is the value in Earth radii.
    def shadow_axis_distance
      @geometry.axis_distance
    end

    # @return [Boolean] true for a penumbral eclipse (the Moon misses the umbra)
    def penumbral?
      @kind == PENUMBRAL
    end

    # @return [Boolean] true for a partial eclipse
    def partial?
      @kind == PARTIAL
    end

    # @return [Boolean] true for a total eclipse
    def total?
      @kind == TOTAL
    end

    # @param observer [Astronoby::Observer] the observer
    # @return [Astronoby::LunarEclipseVisibility] the local circumstances
    def visibility_from(observer)
      LunarEclipseVisibility.new(eclipse: self, observer: observer)
    end
  end
end
