# frozen_string_literal: true

module Astronoby
  # The relative airmass, the length of the path light travels through the
  # atmosphere, relative to the path at the zenith. It is 1 at the zenith and
  # about 38 for a body that appears on the horizon.
  #
  # From a true, unrefracted altitude it follows A. T. Young, "Air mass and
  # refraction", Applied Optics 33 (6), 1994. From an apparent altitude it
  # follows F. Kasten and A. T. Young, "Revised optical air mass tables and
  # approximation formula", Applied Optics 28 (22), 1989.
  #
  # @example Airmass of a body 30° above the horizon
  #   altitude = Astronoby::Angle.from_degrees(30)
  #   Astronoby::Airmass.from_true_altitude(altitude).value  # => 1.9917...
  #
  class Airmass
    include Comparable

    # Young (1994) gives the airmass as a ratio of two polynomials of s, the
    # sine of the true altitude:
    #
    #   X = (1.002432 s² + 0.148386 s + 0.0096467) /
    #       (s³ + 0.149864 s² + 0.0102963 s + 0.000303978)
    #
    # Coefficients are listed from the constant term up.
    YOUNG_NUMERATOR = [0.0096467, 0.148386, 1.002432].freeze
    YOUNG_DENOMINATOR = [0.000303978, 0.0102963, 0.149864, 1.0].freeze

    # Kasten and Young (1989) give the airmass from h, the apparent altitude in
    # degrees, with their constants a, b and c:
    #
    #   X = 1 / (sin h + a (h + b)^-c)
    KASTEN_YOUNG_A = 0.50572
    KASTEN_YOUNG_B = 6.07995
    KASTEN_YOUNG_C = 1.6364

    class << self
      # Young's formula only covers true altitudes down to the horizon, but a
      # body slightly below it is still seen above it, lifted by refraction.
      # Given an observer, such an altitude is refracted with the observer's
      # temperature and pressure and its airmass taken from the apparent
      # altitude.
      #
      # @param altitude [Astronoby::Angle] true altitude, without refraction
      # @param observer [Astronoby::Observer, nil] the observer, whose
      #   atmosphere tells whether a body below the true horizon is visible
      # @return [Astronoby::Airmass, nil] the airmass, or nil below the
      #   horizon, the apparent one when an observer is given
      def from_true_altitude(altitude, observer: nil)
        if altitude.negative?
          return unless observer

          return from_apparent_altitude(
            altitude + Refraction.angle(altitude: altitude, observer: observer)
          )
        end

        sine = altitude.sin
        new(
          polynomial(YOUNG_NUMERATOR, sine) /
            polynomial(YOUNG_DENOMINATOR, sine)
        )
      end

      # @param altitude [Astronoby::Angle] apparent altitude, with refraction
      # @return [Astronoby::Airmass, nil] the airmass, or nil below the horizon
      def from_apparent_altitude(altitude)
        return if altitude.negative?

        new(
          1.0 / (
            altitude.sin +
              KASTEN_YOUNG_A *
                (altitude.degrees + KASTEN_YOUNG_B)**-KASTEN_YOUNG_C
          )
        )
      end

      private

      def polynomial(coefficients, variable)
        coefficients.reverse.reduce(0.0) do |sum, coefficient|
          sum * variable + coefficient
        end
      end
    end

    # @return [Float] the relative airmass
    attr_reader :value

    # @param value [Numeric] the relative airmass
    # @raise [Astronoby::IncompatibleArgumentsError] if the value is not a
    #   positive number
    def initialize(value)
      unless value.is_a?(Numeric) && value.positive?
        raise IncompatibleArgumentsError,
          "Expected a positive airmass, got #{value.inspect}"
      end

      @value = value.to_f
      freeze
    end

    # @return [Integer] hash value
    def hash
      [value, self.class].hash
    end

    # @param other [Astronoby::Airmass, Numeric] airmass or plain number to
    #   compare with
    # @return [Integer, nil] -1, 0, or 1; nil if not comparable
    def <=>(other)
      case other
      when self.class then value <=> other.value
      when Numeric then value <=> other
      end
    end

    # @param other [Object] object to compare with
    # @return [Boolean] true if other is an Airmass of the same value
    def eql?(other)
      other.is_a?(self.class) && value == other.value
    end
  end
end
