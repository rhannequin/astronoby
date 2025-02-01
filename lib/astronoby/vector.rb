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
  end
end
