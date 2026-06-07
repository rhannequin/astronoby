# frozen_string_literal: true

module Astronoby
  class Opposition
    # @return [Astronoby::Instant] when the opposition occurs
    attr_reader :instant

    # @return [Astronoby::Body] the body in opposition with the Sun
    attr_reader :body

    # @param instant [Astronoby::Instant] when the opposition occurs
    # @param body [Astronoby::Body] the body in opposition with the Sun
    def initialize(instant:, body:)
      @instant = instant
      @body = body
      freeze
    end
  end
end
