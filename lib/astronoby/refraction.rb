# frozen_string_literal: true

module Astronoby
  # Atmospheric refraction: how much higher a body appears than its true,
  # geometric altitude, because its light is bent through the atmosphere.
  #
  # It uses Bennett's formula, scaled for the temperature and the pressure of
  # the air at the observer's location, as the Explanatory Supplement to the
  # Astronomical Almanac and the USNO's NOVAS do. Bennett's formula
  # takes the apparent altitude, so it is inverted to start from the true one.
  #
  # The inversion starts from Saemundsson's formula, Meeus's direct inverse of
  # Bennett's, which is within a few arcseconds of it. Two Newton steps then
  # land on the exact inverse to within a microarcsecond, from -30 °C to 40 °C
  # and from 600 hPa to 1050 hPa. A fixed number of steps keeps the result a
  # smooth function of the altitude, which the search for altitude crossings
  # relies on.
  #
  # Below {LOWEST_ALTITUDE} the refraction is kept at its value there, as the
  # formulas are meaningless far below the horizon. The apparent altitude then
  # still grows with the true altitude, with no gap.
  #
  # Source:
  #  Title: Astronomical Algorithms
  #  Author: Jean Meeus
  #  Edition: 2nd edition
  #  Chapter: 16 - Atmospheric Refraction
  #
  # Source:
  #  Title: The Calculation of Astronomical Refraction in Marine Navigation
  #  Author: G. G. Bennett
  #  Edition: Journal of Navigation, 35, 1982, pp. 255-259
  module Refraction
    LOWEST_ALTITUDE = Angle.from_degrees(-1)

    REFERENCE_PRESSURE = Pressure.from_millibars(1010)
    REFERENCE_TEMPERATURE = Temperature.from_kelvins(283)

    NEWTON_STEPS = 2

    class << self
      # @param altitude [Astronoby::Angle] true, unrefracted altitude
      # @param observer [Astronoby::Observer] the observer, whose temperature
      #   and pressure scale the refraction
      # @return [Astronoby::Angle] the refraction to add to the true altitude
      #   to get the apparent one
      def angle(altitude:, observer:)
        true_altitude = [altitude.degrees, LOWEST_ALTITUDE.degrees].max
        factor = atmospheric_factor(observer)
        refraction = factor * saemundsson(true_altitude)

        NEWTON_STEPS.times do
          refraction = newton_step(refraction, true_altitude, factor)
        end

        Angle.from_degrees(refraction)
      end

      private

      # One Newton step towards the refraction R, in degrees, that solves
      # R = factor * Bennett(true altitude + R).
      def newton_step(refraction, true_altitude, factor)
        apparent_altitude = true_altitude + refraction
        shifted_altitude = apparent_altitude + 4.4
        cotangent = 1.0 / tan_of_degrees(
          apparent_altitude + 7.31 / shifted_altitude
        )
        bennett = cotangent / Constants::ARCMINUTES_PER_DEGREE
        bennett_slope = -(1 + cotangent**2) *
          (1 - 7.31 / shifted_altitude**2) *
          Math::PI / Constants::PI_IN_DEGREES /
          Constants::ARCMINUTES_PER_DEGREE

        residual = refraction - factor * bennett
        refraction - residual / (1 - factor * bennett_slope)
      end

      def saemundsson(true_altitude)
        argument = true_altitude + 10.3 / (true_altitude + 5.11)
        1.02 / tan_of_degrees(argument) / Constants::ARCMINUTES_PER_DEGREE
      end

      def tan_of_degrees(degrees)
        Math.tan(degrees * Math::PI / Constants::PI_IN_DEGREES)
      end

      def atmospheric_factor(observer)
        observer.pressure.pascals.fdiv(REFERENCE_PRESSURE.pascals) *
          REFERENCE_TEMPERATURE.kelvins.fdiv(observer.temperature.kelvins)
      end
    end
  end
end
