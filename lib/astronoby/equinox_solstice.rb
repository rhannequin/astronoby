# frozen_string_literal: true

module Astronoby
  class EquinoxSolstice
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 27 - Equinoxes and Soltices

    EVENTS = [
      MARCH_EQUINOX = 0,
      JUNE_SOLSTICE = 1,
      SEPTEMBER_EQUINOX = 2,
      DECEMBER_SOLSTICE = 3
    ].freeze

    JDE_COMPONENTS = {
      MARCH_EQUINOX => [
        2451623.80984,
        365242.37404,
        0.05169,
        -0.00411,
        -0.00057
      ],
      JUNE_SOLSTICE => [
        2451716.56767,
        365241.62603,
        0.00325,
        0.00888,
        -0.00030
      ],
      SEPTEMBER_EQUINOX => [
        2451810.21715,
        365242.01767,
        -0.11575,
        0.00337,
        0.00078
      ],
      DECEMBER_SOLSTICE => [
        2451900.05952,
        365242.74049,
        -0.06223,
        -0.00823,
        0.00032
      ]
    }

    PERIODIC_TERMS = [
      [485, 324.96, 1934.136],
      [203, 337.23, 32964.467],
      [199, 342.08, 20.186],
      [182, 27.85, 445267.112],
      [156, 73.14, 45036.886],
      [136, 171.52, 22518.443],
      [77, 222.54, 65928.934],
      [74, 296.72, 3034.906],
      [70, 243.58, 9037.513],
      [58, 119.81, 33718.147],
      [52, 297.17, 150.678],
      [50, 21.02, 2281.226],
      [45, 247.54, 29929.562],
      [44, 325.15, 31555.956],
      [29, 60.93, 4443.417],
      [18, 155.12, 67555.328],
      [17, 288.79, 4562.452],
      [16, 198.04, 62894.029],
      [14, 199.76, 31436.921],
      [12, 95.39, 14577.848],
      [12, 287.11, 31931.756],
      [12, 320.81, 34777.259],
      [9, 227.73, 1222.114],
      [8, 15.45, 16859.074]
    ].freeze

    def self.march_equinox(year)
      new(year, MARCH_EQUINOX).compute
    end

    def self.june_solstice(year)
      new(year, JUNE_SOLSTICE).compute
    end

    def self.september_equinox(year)
      new(year, SEPTEMBER_EQUINOX).compute
    end

    def self.december_solstice(year)
      new(year, DECEMBER_SOLSTICE).compute
    end

    def initialize(year, event)
      unless EVENTS.include?(event)
        raise UnsupportedEventError.new(
          "Expected a format between #{EVENTS.join(", ")}, got #{event}"
        )
      end

      @event = event
      @year = (year.to_i - 2000) / 1000.0
    end

    def compute
      t = (julian_day - Epoch::J2000) / Constants::DAYS_PER_JULIAN_CENTURY
      w = Angle.from_degrees(35999.373 * t) - Angle.from_degrees(2.47)
      delta = 1 +
        0.0334 * w.cos +
        0.0007 * Angle.from_degrees(w.degrees * 2).cos

      s = PERIODIC_TERMS.sum do |a, b, c|
        a * (Angle.from_degrees(b) + Angle.from_degrees(c * t)).cos
      end

      delta_days = 0.00001 * s / delta
      epoch = julian_day + delta_days
      epoch += correction(epoch)

      Epoch.to_utc(epoch).round
    end

    private

    def julian_day
      component = JDE_COMPONENTS[@event]
      component[0] +
        component[1] * @year +
        component[2] * @year**2 +
        component[3] * @year**3 +
        component[4] * @year**4
    end

    def correction(epoch)
      time = Epoch.to_utc(epoch)
      sun = Sun.new(time: time)
      longitude = sun.apparent_ecliptic_coordinates.longitude

      58 * Angle.from_degrees(@event * 90 - longitude.degrees).sin
    end
  end
end
