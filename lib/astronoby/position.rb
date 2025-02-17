# frozen_string_literal: true

module Astronoby
  class Position
    attr_reader :position,
      :velocity,
      :instant,
      :center_identifier,
      :target_body

    def initialize(
      position:,
      velocity:,
      instant:,
      center_identifier:,
      target_body:
    )
      @position = position
      @velocity = velocity
      @instant = instant
      @center_identifier = center_identifier
      @target_body = target_body
    end
  end
end
