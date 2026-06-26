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
    alias_method :greatest_eclipse, :instant

    # @return [Symbol] +PENUMBRAL+, +PARTIAL+ or +TOTAL+
    attr_reader :kind

    # @return [Float] fraction of the Moon's diameter immersed in the umbra at
    #   greatest eclipse (negative when the Moon misses the umbra)
    attr_reader :umbral_magnitude

    # @return [Float] fraction of the Moon's diameter immersed in the penumbra
    #   at greatest eclipse
    attr_reader :penumbral_magnitude

    # @return [Float] least distance of the Moon's centre from the axis of
    #   Earth's shadow at greatest eclipse, in Earth radii, positive when the
    #   Moon passes north of the axis
    attr_reader :gamma

    # @return [Astronoby::Distance] least distance of the Moon's centre from the
    #   axis of Earth's shadow at greatest eclipse. This is the unsigned length
    #   of which gamma is the value in Earth radii.
    attr_reader :shadow_axis_distance

    # @return [Astronoby::EclipsePhase] the penumbral phase (always present)
    attr_reader :penumbral

    # @return [Astronoby::EclipsePhase, nil] the partial phase, present for
    #   partial and total eclipses
    attr_reader :partial

    # @return [Astronoby::EclipsePhase, nil] the total phase (totality),
    #   present only for total eclipses
    attr_reader :total

    # @param instant [Astronoby::Instant] greatest eclipse
    # @param kind [Symbol] +PENUMBRAL+, +PARTIAL+ or +TOTAL+
    # @param umbral_magnitude [Float] umbral magnitude at greatest eclipse
    # @param penumbral_magnitude [Float] penumbral magnitude at greatest eclipse
    # @param gamma [Float] least distance from the shadow axis, in Earth radii
    # @param shadow_axis_distance [Astronoby::Distance] least distance from the
    #   shadow axis
    # @param penumbral [Astronoby::EclipsePhase] the penumbral phase
    # @param partial [Astronoby::EclipsePhase, nil] the partial phase
    # @param total [Astronoby::EclipsePhase, nil] the total phase
    def initialize(
      instant:,
      kind:,
      umbral_magnitude:,
      penumbral_magnitude:,
      gamma:,
      shadow_axis_distance:,
      penumbral:,
      partial: nil,
      total: nil
    )
      @instant = instant
      @kind = kind
      @umbral_magnitude = umbral_magnitude
      @penumbral_magnitude = penumbral_magnitude
      @gamma = gamma
      @shadow_axis_distance = shadow_axis_distance
      @penumbral = penumbral
      @partial = partial
      @total = total
      freeze
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
  end
end
