# frozen_string_literal: true

module Astronoby
  # Represents a temperature with kelvins as its internal representation.
  #
  # @example Create a temperature from degrees Celsius
  #   temperature = Astronoby::Temperature.from_celsius(10)
  #   temperature.kelvins  # => 283.15
  #
  class Temperature
    include Comparable

    ZERO_CELSIUS_IN_KELVINS = 273.15

    class << self
      # @param kelvins [Numeric] the temperature in kelvins
      # @return [Astronoby::Temperature] a new Temperature
      def from_kelvins(kelvins)
        new(kelvins)
      end

      # @param celsius [Numeric] the temperature in degrees Celsius
      # @return [Astronoby::Temperature] a new Temperature
      def from_celsius(celsius)
        new(celsius + ZERO_CELSIUS_IN_KELVINS)
      end
    end

    # @return [Numeric] the temperature in kelvins
    attr_reader :kelvins

    # @param kelvins [Numeric] the temperature in kelvins
    # @raise [Astronoby::IncompatibleArgumentsError] if the temperature is not
    #   above absolute zero
    def initialize(kelvins)
      unless kelvins.positive?
        raise IncompatibleArgumentsError,
          "Expected a temperature above absolute zero, got #{kelvins} K"
      end

      @kelvins = kelvins
      freeze
    end

    # @return [Numeric] the temperature in degrees Celsius
    def celsius
      @kelvins - ZERO_CELSIUS_IN_KELVINS
    end

    # @return [Integer] hash value
    def hash
      [kelvins.to_f, self.class].hash
    end

    # @param other [Astronoby::Temperature] temperature to compare with
    # @return [Integer, nil] -1, 0, or 1; nil if not comparable
    def <=>(other)
      return unless other.is_a?(self.class)

      kelvins <=> other.kelvins
    end
    alias_method :eql?, :==
  end
end
