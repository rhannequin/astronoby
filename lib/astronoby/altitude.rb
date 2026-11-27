# frozen_string_literal: true

module Astronoby
  # An altitude above the horizon, either apparent (as seen through the
  # atmosphere, refraction included) or true (geometric).
  class Altitude
    # @param degrees [Numeric] the altitude in degrees
    # @return [Astronoby::Altitude] an altitude as seen through the atmosphere
    def self.apparent(degrees:)
      new(Angle.from_degrees(degrees), apparent: true)
    end

    # @param degrees [Numeric] the altitude in degrees
    # @return [Astronoby::Altitude] a geometric altitude, without refraction
    def self.true(degrees:)
      new(Angle.from_degrees(degrees), apparent: false)
    end

    # @return [Astronoby::Angle] the altitude
    attr_reader :angle

    # @param angle [Astronoby::Angle] the altitude
    # @param apparent [Boolean] whether refraction is included
    def initialize(angle, apparent:)
      @angle = angle
      @apparent = apparent
      freeze
    end

    # @return [Boolean] true when refraction is included
    def apparent?
      @apparent
    end

    def ==(other)
      other.is_a?(self.class) &&
        angle == other.angle &&
        apparent? == other.apparent?
    end
    alias_method :eql?, :==

    def hash
      [self.class, angle, @apparent].hash
    end

    def inspect
      "#<#{self.class} #{@apparent ? "apparent" : "true"} #{@angle.degrees}°>"
    end
  end
end
