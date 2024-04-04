# frozen_string_literal: true

module Astronoby
  class Observer
    DEFAULT_ELEVATION = 0
    DEFAULT_TEMPERATURE = 283.15
    PRESSURE_AT_SEA_LEVEL = 1013.25
    PASCAL_PER_MILLIBAR = 0.01
    EARTH_GRAVITATIONAL_ACCELERATION = 9.80665
    MOLAR_MASS_OF_AIR = 0.0289644
    UNIVERSAL_GAS_CONSTANT = 8.31432

    attr_reader :latitude, :longitude, :elevation, :temperature

    # @param latitude [Angle] geographic latitude of the observer
    # @param longitude [Angle] geographic longitude of the observer
    # @param elevation [Numeric] geographic elevation (or altitude) of the
    #   observer above sea level in meters
    # @param temperature [Numeric] temperature at the observer's location in
    #   kelvins
    # @param pressure [Numeric] atmospheric pressure at the observer's
    #   location in millibars
    def initialize(
      latitude:,
      longitude:,
      elevation: DEFAULT_ELEVATION,
      temperature: DEFAULT_TEMPERATURE,
      pressure: nil
    )
      @latitude = latitude
      @longitude = longitude
      @elevation = elevation
      @temperature = temperature
      @pressure = pressure
    end

    # Compute an estimation of the atmospheric pressure based on the elevation
    # and temperature
    #
    # @return [Float] the atmospheric pressure in millibars.
    def pressure
      @pressure ||= PRESSURE_AT_SEA_LEVEL * pressure_ratio
    end

    private

    # Source:
    # Barometric formula
    # https://en.wikipedia.org/wiki/Barometric_formula
    def pressure_ratio
      term1 = EARTH_GRAVITATIONAL_ACCELERATION * MOLAR_MASS_OF_AIR * @elevation
      term2 = UNIVERSAL_GAS_CONSTANT * @temperature

      Math.exp(-term1 / term2)
    end
  end
end
