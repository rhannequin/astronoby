# frozen_string_literal: true

module Astronoby
  class Conjunction
    INFERIOR = :inferior
    SUPERIOR = :superior

    # @param instant [Astronoby::Instant] when the conjunction occurs
    # @param body [Astronoby::Body] the body in conjunction with the Sun
    # @return [Astronoby::Conjunction] an inferior conjunction
    def self.inferior(instant:, body:)
      new(instant: instant, body: body, subtype: INFERIOR)
    end

    # @param instant [Astronoby::Instant] when the conjunction occurs
    # @param body [Astronoby::Body] the body in conjunction with the Sun
    # @return [Astronoby::Conjunction] a superior conjunction
    def self.superior(instant:, body:)
      new(instant: instant, body: body, subtype: SUPERIOR)
    end

    # @return [Astronoby::Instant] when the conjunction occurs
    attr_reader :instant

    # @return [Astronoby::Body] the body in conjunction with the Sun
    attr_reader :body

    # @return [Symbol] +INFERIOR+ or +SUPERIOR+
    attr_reader :subtype

    # @param instant [Astronoby::Instant] when the conjunction occurs
    # @param body [Astronoby::Body] the body in conjunction with the Sun
    # @param subtype [Symbol] +INFERIOR+ or +SUPERIOR+
    def initialize(instant:, body:, subtype:)
      @instant = instant
      @body = body
      @subtype = subtype
      freeze
    end

    # @return [Boolean] true for an inferior conjunction
    def inferior?
      @subtype == INFERIOR
    end

    # @return [Boolean] true for a superior conjunction
    def superior?
      @subtype == SUPERIOR
    end
  end
end
