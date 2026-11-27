# frozen_string_literal: true

module Astronoby
  class ExtremumCalculator
    # @param body [Astronoby::SolarSystemBody] the celestial body to track
    # @param primary_body [Astronoby::SolarSystemBody] the reference body
    # @param ephem [::Ephem::SPK] ephemeris data source
    # @param samples_per_period [Integer] number of samples per orbital period
    def initialize(
      body:,
      primary_body:,
      ephem:,
      samples_per_period: 60
    )
      @body = body
      @primary_body = primary_body
      @ephem = ephem
      @samples_per_period = samples_per_period
    end

    # Finds all apoapsis events between two times
    # @param start_time [Time, Astronoby::Instant] Start time
    # @param end_time [Time, Astronoby::Instant] End time
    # @return [Array<Astronoby::ExtremumEvent>] Array of apoapsis events
    # @deprecated Use {Astronoby::Sky::Target#apogees} instead
    def apoapsis_events_between(start_time, end_time)
      warn_deprecated(:apoapsis_events_between, "sky.moon.apogees")
      extrema_between(
        Instant.from(start_time).tt,
        Instant.from(end_time).tt,
        type: :maximum
      )
    end

    # Finds all periapsis events between two times
    # @param start_time [Time, Astronoby::Instant] Start time
    # @param end_time [Time, Astronoby::Instant] End time
    # @return [Array<Astronoby::ExtremumEvent>] Array of periapsis events
    # @deprecated Use {Astronoby::Sky::Target#perigees} instead
    def periapsis_events_between(start_time, end_time)
      warn_deprecated(:periapsis_events_between, "sky.moon.perigees")
      extrema_between(
        Instant.from(start_time).tt,
        Instant.from(end_time).tt,
        type: :minimum
      )
    end

    # Finds extrema (minima or maxima) in the distance between bodies within
    #   a time range
    # @param start_jd [Float] Start time in Julian Date (Terrestrial Time)
    # @param end_jd [Float] End time in Julian Date (Terrestrial Time)
    # @param type [Symbol] :maximum or :minimum
    # @return [Array<Astronoby::ExtremumEvent>] Array of extrema events
    # @deprecated Use {Astronoby::Sky::Target#apogees} or
    #   {Astronoby::Sky::Target#perigees} instead
    def find_extrema(start_jd, end_jd, type: :maximum)
      warn_deprecated(:find_extrema, "sky.moon.apogees or sky.moon.perigees")
      extrema_between(start_jd, end_jd, type: type)
    end

    private

    def warn_deprecated(method_name, replacement)
      Deprecation.warn(self.class, method_name, uplevel: 2) do
        ["Astronoby::ExtremumCalculator##{method_name}", replacement]
      end
    end

    def extrema_between(start_jd, end_jd, type:)
      finder
        .extrema_by_rate(
          start_jd,
          end_jd,
          type: type,
          rate_at: method(:rate_at)
        )
        .map do |extremum|
        ExtremumEvent.new(
          Instant.from_terrestrial_time(extremum[:jd]),
          extremum[:value]
        )
      end
    end

    def finder
      @finder ||= ExtremumFinder.new(
        value_at: method(:distance_at),
        period: @body::ORBITAL_PERIOD,
        samples_per_period: @samples_per_period
      )
    end

    def rate_at(jd)
      body, primary = geometrics_at(jd)
      position = body.position - primary.position
      velocity = body.velocity - primary.velocity
      (0..2).sum { |i| position[i].meters * velocity[i].meters_per_second }
    end

    def distance_at(jd)
      body, primary = geometrics_at(jd)
      (body.position - primary.position).magnitude
    end

    def geometrics_at(jd)
      instant = Instant.from_terrestrial_time(jd)
      [
        @body.geometric(ephem: @ephem, instant: instant),
        @primary_body.geometric(ephem: @ephem, instant: instant)
      ]
    end
  end
end
