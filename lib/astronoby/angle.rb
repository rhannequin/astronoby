# frozen_string_literal: true

require "bigdecimal/math"

module Astronoby
  class Angle
    UNITS = [
      DEGREES = :degrees,
      RADIANS = :radians
    ].freeze

    PI = ::BigMath.PI(10)

    UNITS.each do |unit|
      define_method("to_#{unit}") do
        raise NotImplementedError, "#{self.class} must implement #to_#{unit} method."
      end
    end

    def self.as_degrees(angle)
      ::Astronoby::Degree.new(angle)
    end

    def self.as_radians(angle)
      ::Astronoby::Radian.new(angle)
    end

    def initialize(angle, unit:)
      @angle = angle
      @unit = unit
    end

    def value
      @angle
    end
  end
end
