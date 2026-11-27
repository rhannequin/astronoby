# frozen_string_literal: true

module Astronoby
  # An equinox or a solstice: when the Sun's apparent ecliptic longitude
  # reaches 0°, 90°, 180° or 270°.
  class SeasonStart
    KINDS = [
      MARCH_EQUINOX = :march_equinox,
      JUNE_SOLSTICE = :june_solstice,
      SEPTEMBER_EQUINOX = :september_equinox,
      DECEMBER_SOLSTICE = :december_solstice
    ].freeze

    # @return [Astronoby::Instant] when it happens
    attr_reader :instant

    # @return [Symbol] +:march_equinox+, +:june_solstice+,
    #   +:september_equinox+ or +:december_solstice+
    attr_reader :kind

    # @param instant [Astronoby::Instant]
    # @param kind [Symbol] one of {KINDS}
    def initialize(instant:, kind:)
      @instant = instant
      @kind = kind
    end

    # @return [Boolean] true for the March and September equinoxes
    def equinox?
      kind == MARCH_EQUINOX || kind == SEPTEMBER_EQUINOX
    end

    # @return [Boolean] true for the June and December solstices
    def solstice?
      kind == JUNE_SOLSTICE || kind == DECEMBER_SOLSTICE
    end
  end
end
