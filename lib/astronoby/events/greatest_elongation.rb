# frozen_string_literal: true

module Astronoby
  class GreatestElongation
    EASTERN = :eastern
    WESTERN = :western

    # @param instant [Astronoby::Instant] when the greatest elongation occurs
    # @param body [Astronoby::Body] the body reaching greatest elongation
    # @param angle [Astronoby::Angle] the Sun-Earth-body angle at that instant
    # @return [Astronoby::GreatestElongation] a greatest eastern elongation
    def self.eastern(instant:, body:, angle:)
      new(instant: instant, body: body, angle: angle, direction: EASTERN)
    end

    # @param instant [Astronoby::Instant] when the greatest elongation occurs
    # @param body [Astronoby::Body] the body reaching greatest elongation
    # @param angle [Astronoby::Angle] the Sun-Earth-body angle at that instant
    # @return [Astronoby::GreatestElongation] a greatest western elongation
    def self.western(instant:, body:, angle:)
      new(instant: instant, body: body, angle: angle, direction: WESTERN)
    end

    # @return [Astronoby::Instant] when the greatest elongation occurs
    attr_reader :instant

    # @return [Astronoby::Body] the body reaching greatest elongation
    attr_reader :body

    # @return [Astronoby::Angle] the Sun-Earth-body angle at that instant
    attr_reader :angle

    # @return [Symbol] +EASTERN+ or +WESTERN+
    attr_reader :direction

    # @param instant [Astronoby::Instant] when the greatest elongation occurs
    # @param body [Astronoby::Body] the body reaching greatest elongation
    # @param angle [Astronoby::Angle] the Sun-Earth-body angle at that instant
    # @param direction [Symbol] +EASTERN+ or +WESTERN+
    def initialize(instant:, body:, angle:, direction:)
      @instant = instant
      @body = body
      @angle = angle
      @direction = direction
      freeze
    end

    # @return [Boolean] true for a greatest eastern elongation
    def eastern?
      @direction == EASTERN
    end

    # @return [Boolean] true for a greatest western elongation
    def western?
      @direction == WESTERN
    end
  end
end
