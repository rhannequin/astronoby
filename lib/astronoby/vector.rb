# frozen_string_literal: true

require "matrix"

module Astronoby
  class Vector < ::Vector
    def initialize(...)
      super
      freeze
    end

    def x
      self[0]
    end

    def y
      self[1]
    end

    def z
      self[2]
    end

    def magnitude
      if all? { _1.is_a?(Astronoby::Distance) }
        Astronoby::Distance.new(super)
      elsif all? { _1.is_a?(Astronoby::Velocity) }
        Astronoby::Velocity.new(super)
      else
        super
      end
    end
    alias_method :norm, :magnitude
    alias_method :r, :magnitude
  end
end
