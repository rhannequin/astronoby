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
    # @param start_time [Time] Start time
    # @param end_time [Time] End time
    # @return [Array<Astronoby::ExtremumEvent>] Array of apoapsis events
    def apoapsis_events_between(start_time, end_time)
      find_extrema(
        Instant.from_time(start_time).tt,
        Instant.from_time(end_time).tt,
        type: :maximum
      )
    end

    # Finds all periapsis events between two times
    # @param start_time [Time] Start time
    # @param end_time [Time] End time
    # @return [Array<Astronoby::ExtremumEvent>] Array of periapsis events
    def periapsis_events_between(start_time, end_time)
      find_extrema(
        Instant.from_time(start_time).tt,
        Instant.from_time(end_time).tt,
        type: :minimum
      )
    end

    # Finds extrema (minima or maxima) in the distance between bodies within
    #   a time range
    # @param start_jd [Float] Start time in Julian Date (Terrestrial Time)
    # @param end_jd [Float] End time in Julian Date (Terrestrial Time)
    # @param type [Symbol] :maximum or :minimum
    # @return [Array<Astronoby::ExtremumEvent>] Array of extrema events
    def find_extrema(start_jd, end_jd, type: :maximum)
      finder.extrema(start_jd, end_jd, type: type).map do |extremum|
        ExtremumEvent.new(
          Instant.from_terrestrial_time(extremum[:jd]),
          extremum[:value]
        )
      end
    end

    private

    def finder
      @finder ||= ExtremumFinder.new(
        value_at: method(:distance_at),
        period: @body::ORBITAL_PERIOD,
        samples_per_period: @samples_per_period
      )
    end

    def distance_at(jd)
      instant = Instant.from_terrestrial_time(jd)
      body_geometric = @body.geometric(ephem: @ephem, instant: instant)
      primary_geometric = @primary_body
        .geometric(ephem: @ephem, instant: instant)

      distance_vector = body_geometric.position - primary_geometric.position
      distance_vector.magnitude
    end
  end
end
