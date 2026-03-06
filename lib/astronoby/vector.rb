# frozen_string_literal: true

require "matrix"

module Astronoby
  # A 3D vector extending Ruby's Vector class. Provides named component
  # accessors and type-aware magnitude computation for Distance and Velocity
  # vectors.
  class Vector < ::Vector
    def initialize(...)
      super
      freeze
    end

    # @return [Object] the first component (x-axis)
    def x
      self[0]
    end

    # @return [Object] the second component (y-axis)
    def y
      self[1]
    end

    # @return [Object] the third component (z-axis)
    def z
      self[2]
    end

    # Returns the Euclidean magnitude of the vector. If all elements are
    # Distance or Velocity instances, the result is wrapped in the same type.
    #
    # @return [Astronoby::Distance, Astronoby::Velocity, Numeric] the magnitude
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
