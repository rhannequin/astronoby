# frozen_string_literal: true

module Astronoby
  class GreatestElongationCalculator
    RATE_STEP_IN_DAYS = 0.01
    TOLERANCE_IN_DAYS = 1e-7
    DUPLICATE_THRESHOLD_IN_DAYS = 0.5
    MAX_REFINEMENT_ITERATIONS = 10
    # @param body [Astronoby::SolarSystemBody] the planet to track
    # @param ephem [::Ephem::SPK] ephemeris data source
    # @param samples_per_period [Integer] number of samples per synodic period
    def initialize(body:, ephem:, samples_per_period: 60)
      @body = body
      @ephem = ephem
      @samples_per_period = samples_per_period
    end

    # @param start_time [Time, Astronoby::Instant] start time
    # @param end_time [Time, Astronoby::Instant] end time
    # @return [Array<Astronoby::GreatestElongation>] greatest elongations in
    #   the range
    def greatest_elongation_events_between(start_time, end_time)
      start_jd = instant_for(start_time).tt
      end_jd = instant_for(end_time).tt

      finder
        .brackets(start_jd, end_jd, type: :maximum)
        .filter_map { |bracket| maximum_in(bracket) }
        .select { |maximum| maximum[:jd].between?(start_jd, end_jd) }
        .uniq { |maximum| (maximum[:jd] / DUPLICATE_THRESHOLD_IN_DAYS).round }
        .map { |maximum| build_event(maximum) }
    end

    private

    def instant_for(time)
      time.is_a?(Instant) ? time : Instant.from_time(time)
    end

    def finder
      @finder ||= ExtremumFinder.new(
        value_at: ->(jd) { planet_at(jd).elongation },
        period: synodic_period,
        samples_per_period: @samples_per_period
      )
    end

    def maximum_in(bracket)
      previous_jd = (bracket[:start_jd] + bracket[:end_jd]) / 2
      previous_rate = rate_at(previous_jd)
      jd = previous_jd + RATE_STEP_IN_DAYS

      MAX_REFINEMENT_ITERATIONS.times do
        rate = rate_at(jd)
        break if rate == previous_rate

        next_jd = jd - rate * (jd - previous_jd) / (rate - previous_rate)
        previous_jd, previous_rate = jd, rate
        jd = next_jd
        if (jd - previous_jd).abs < TOLERANCE_IN_DAYS
          return {jd: jd, value: planet_at(jd).elongation}
        end
      end

      finder.extrema(bracket[:start_jd], bracket[:end_jd], type: :maximum).first
    end

    def rate_at(jd)
      planet_at(jd + RATE_STEP_IN_DAYS).elongation.radians -
        planet_at(jd - RATE_STEP_IN_DAYS).elongation.radians
    end

    def build_event(extremum)
      instant = Instant.from_terrestrial_time(extremum[:jd])
      angle = extremum[:value]

      if planet_at(instant.tt).eastern?
        GreatestElongation.eastern(instant: instant, body: @body, angle: angle)
      else
        GreatestElongation.western(instant: instant, body: @body, angle: angle)
      end
    end

    def planet_at(jd)
      @body.new(instant: Instant.from_terrestrial_time(jd), ephem: @ephem)
    end

    def synodic_period
      @synodic_period ||=
        1.0 / ((1.0 / @body::ORBITAL_PERIOD) - (1.0 / Earth::ORBITAL_PERIOD)).abs
    end
  end
end
