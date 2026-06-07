# frozen_string_literal: true

module Astronoby
  class ConjunctionOppositionCalculator
    # @param body [Astronoby::SolarSystemBody] the planet to track
    # @param ephem [::Ephem::SPK] ephemeris data source
    # @param samples_per_period [Integer] number of samples per synodic period
    def initialize(body:, ephem:, samples_per_period: 60)
      @body = body
      @ephem = ephem
      @samples_per_period = samples_per_period
    end

    # @param start_time [Time] start time
    # @param end_time [Time] end time
    # @return [Array<Astronoby::Conjunction>] conjunctions in the range
    def conjunction_events_between(start_time, end_time)
      roots_between(start_time, end_time, accept: method(:conjunction?))
        .map { |jd| conjunction_at(Instant.from_terrestrial_time(jd)) }
    end

    # @param start_time [Time] start time
    # @param end_time [Time] end time
    # @return [Array<Astronoby::Opposition>] oppositions in the range
    def opposition_events_between(start_time, end_time)
      roots_between(start_time, end_time, accept: method(:opposition?))
        .map do |jd|
          Opposition.new(
            instant: Instant.from_terrestrial_time(jd),
            body: @body
          )
        end
    end

    private

    def roots_between(start_time, end_time, accept:)
      finder.roots(
        Instant.from_time(start_time).tt,
        Instant.from_time(end_time).tt,
        accept: accept
      )
    end

    def finder
      @finder ||= RootFinder.new(
        value_at: ->(jd) { delta_longitude_at(jd).sin },
        period: synodic_period,
        samples_per_period: @samples_per_period
      )
    end

    def conjunction?(jd)
      delta_longitude_at(jd).cos.positive?
    end

    def opposition?(jd)
      delta_longitude_at(jd).cos.negative?
    end

    def delta_longitude_at(jd)
      instant = Instant.from_terrestrial_time(jd)
      planet = @body.new(instant: instant, ephem: @ephem)
      sun = Sun.new(instant: instant, ephem: @ephem)
      planet.apparent.ecliptic.longitude - sun.apparent.ecliptic.longitude
    end

    def conjunction_at(instant)
      planet = @body.new(instant: instant, ephem: @ephem)
      sun = Sun.new(instant: instant, ephem: @ephem)

      if planet.apparent.distance < sun.apparent.distance
        Conjunction.inferior(instant: instant, body: @body)
      else
        Conjunction.superior(instant: instant, body: @body)
      end
    end

    def synodic_period
      @synodic_period ||=
        1.0 / ((1.0 / @body::ORBITAL_PERIOD) - (1.0 / Earth::ORBITAL_PERIOD)).abs
    end
  end
end
