# frozen_string_literal: true

require "bigdecimal/math"

module Astronoby
  class Angle
    UNITS = [
      DEGREES = :degrees,
      HOURS = :hours,
      RADIANS = :radians
    ].freeze

    UNIT_CLASS_NAMES = {
      DEGREES => "Astronoby::Degree",
      HOURS => "Astronoby::Hour",
      RADIANS => "Astronoby::Radian"
    }

    PRECISION = 14
    PI = BigMath.PI(10)

    class << self
      UNIT_CLASS_NAMES.each do |unit, class_name|
        define_method("as_#{unit}") do |angle|
          Kernel.const_get(class_name).new(angle)
        end
      end

      def as_hms(hour, minute, second)
        angle = hour + minute / 60.0 + second / 3600.0
        Kernel.const_get(UNIT_CLASS_NAMES[HOURS]).new(angle)
      end
    end

    UNITS.each do |unit|
      define_method("to_#{unit}") do
        raise NotImplementedError, "#{self.class} must implement #to_#{unit} method."
      end
    end

    def initialize(angle, unit:)
      @angle = BigDecimal(angle, PRECISION).ceil(PRECISION)
      @unit = unit
    end

    def value
      @angle
    end

    def ==(other)
      value == other.value && self.class == other.class
    end
  end
end
