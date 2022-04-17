# frozen_string_literal: true

module Astronoby
  class Angle
    UNITS = [
      DEGREES = :degrees,
      RADIANS = :radians
    ].freeze

    UNITS.each do |unit|
      define_method("to_#{unit}") do
        raise NotImplementedError
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
