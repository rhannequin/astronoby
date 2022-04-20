# frozen_string_literal: true

require "bigdecimal/math"

module Astronoby
  class Angle
    UNITS = [
      DEGREES = :degrees,
      RADIANS = :radians
    ].freeze

    UNIT_CLASS_NAMES = {
      DEGREES => "Astronoby::Degree",
      RADIANS => "Astronoby::Radian"
    }

    PI = BigMath.PI(10)

    class << self
      UNIT_CLASS_NAMES.each do |unit, class_name|
        define_method("as_#{unit}") do |angle|
          Kernel.const_get(class_name).new(angle)
        end
      end
    end

    UNITS.each do |unit|
      define_method("to_#{unit}") do
        raise NotImplementedError, "#{self.class} must implement #to_#{unit} method."
      end
    end

    def initialize(angle, unit:)
      @angle = BigDecimal(angle)
      @unit = unit
    end

    def value
      @angle
    end
  end
end
