# frozen_string_literal: true

module Astronoby
  # Represents an atmospheric pressure with pascals as its internal
  # representation.
  #
  # @example Create a pressure from millibars
  #   pressure = Astronoby::Pressure.from_millibars(1013.25)
  #   pressure.pascals  # => 101325.0
  #
  class Pressure
    include Comparable

    PASCALS_PER_HECTOPASCAL = 100
    STANDARD_ATMOSPHERE_IN_PASCALS = 101_325

    EARTH_GRAVITATIONAL_ACCELERATION = 9.80665
    MOLAR_MASS_OF_AIR = 0.0289644
    UNIVERSAL_GAS_CONSTANT = 8.31432

    class << self
      # @param pascals [Numeric] the pressure in pascals
      # @return [Astronoby::Pressure] a new Pressure
      def from_pascals(pascals)
        new(pascals)
      end

      # @param hectopascals [Numeric] the pressure in hectopascals
      # @return [Astronoby::Pressure] a new Pressure
      def from_hectopascals(hectopascals)
        new(hectopascals * PASCALS_PER_HECTOPASCAL)
      end
      alias_method :from_millibars, :from_hectopascals

      # @return [Astronoby::Pressure] the standard atmosphere at sea level,
      #   1013.25 hPa
      def standard_atmosphere
        new(STANDARD_ATMOSPHERE_IN_PASCALS)
      end

      # The pressure of an isothermal atmosphere at an elevation above sea
      # level, starting from the standard atmosphere.
      #
      # Source:
      #  Barometric formula
      #  https://en.wikipedia.org/wiki/Barometric_formula
      #
      # @param elevation [Astronoby::Distance] elevation above sea level
      # @param temperature [Astronoby::Temperature] temperature of the air
      # @return [Astronoby::Pressure] the pressure at that elevation
      def at_elevation(elevation, temperature:)
        exponent = -EARTH_GRAVITATIONAL_ACCELERATION *
          MOLAR_MASS_OF_AIR *
          elevation.meters /
          (UNIVERSAL_GAS_CONSTANT * temperature.kelvins)

        new(STANDARD_ATMOSPHERE_IN_PASCALS * Math.exp(exponent))
      end
    end

    # @return [Numeric] the pressure in pascals
    attr_reader :pascals

    # @param pascals [Numeric] the pressure in pascals
    # @raise [Astronoby::IncompatibleArgumentsError] if the pressure is
    #   negative
    def initialize(pascals)
      if pascals.negative?
        raise IncompatibleArgumentsError,
          "Expected a pressure of zero or more, got #{pascals} Pa"
      end

      @pascals = pascals
      freeze
    end

    # @return [Float] the pressure in hectopascals
    def hectopascals
      @pascals / PASCALS_PER_HECTOPASCAL.to_f
    end
    alias_method :millibars, :hectopascals

    # @return [Integer] hash value
    def hash
      [pascals.to_f, self.class].hash
    end

    # @param other [Astronoby::Pressure] pressure to compare with
    # @return [Integer, nil] -1, 0, or 1; nil if not comparable
    def <=>(other)
      return unless other.is_a?(self.class)

      pascals <=> other.pascals
    end
    alias_method :eql?, :==
  end
end
