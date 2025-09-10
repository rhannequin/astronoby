# frozen_string_literal: true

module Astronoby
  # Represents an extremum event with its timing and value
  class ExtremumEvent
    attr_reader :instant, :value

    # @param instant [Astronoby::Instant] When the event occurs
    # @param value [Object] The extreme value
    def initialize(instant, value)
      @instant = instant
      @value = value
    end
  end
end
