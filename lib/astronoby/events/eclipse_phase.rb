# frozen_string_literal: true

module Astronoby
  # A bounded phase of an eclipse, delimited by its two boundary instants.
  class EclipsePhase
    # @return [Astronoby::Instant] when the phase begins
    attr_reader :starting_instant

    # @return [Astronoby::Instant] when the phase ends
    attr_reader :ending_instant

    # @param starting_instant [Astronoby::Instant] when the phase begins
    # @param ending_instant [Astronoby::Instant] when the phase ends
    def initialize(starting_instant:, ending_instant:)
      @starting_instant = starting_instant
      @ending_instant = ending_instant
      freeze
    end

    # @return [Integer] phase duration in seconds
    def duration
      (@ending_instant.to_time - @starting_instant.to_time).round
    end
  end
end
