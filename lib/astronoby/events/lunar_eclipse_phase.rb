# frozen_string_literal: true

module Astronoby
  class LunarEclipsePhase
    # @return [Astronoby::Instant] when the phase begins
    attr_reader :starting_instant

    # @return [Astronoby::Instant] when the phase ends
    attr_reader :ending_instant

    # @return [Astronoby::LunarEclipseGeometry] the shadow geometry when the
    #   phase begins
    attr_reader :starting_geometry

    # @return [Astronoby::LunarEclipseGeometry] the shadow geometry when the
    #   phase ends
    attr_reader :ending_geometry

    # @param starting_instant [Astronoby::Instant] when the phase begins
    # @param ending_instant [Astronoby::Instant] when the phase ends
    # @param starting_geometry [Astronoby::LunarEclipseGeometry] the geometry
    #   when the phase begins
    # @param ending_geometry [Astronoby::LunarEclipseGeometry] the geometry when
    #   the phase ends
    def initialize(
      starting_instant:,
      ending_instant:,
      starting_geometry:,
      ending_geometry:
    )
      @starting_instant = starting_instant
      @ending_instant = ending_instant
      @starting_geometry = starting_geometry
      @ending_geometry = ending_geometry
      freeze
    end

    # @return [Astronoby::Duration] phase duration
    def duration
      Duration.from_seconds(
        (@ending_instant.tt - @starting_instant.tt) * Constants::SECONDS_PER_DAY
      )
    end
  end
end
