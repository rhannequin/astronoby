# frozen_string_literal: true

module Astronoby
  class GreatestElongationCalculator
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
      finder.extrema(
        instant_for(start_time).tt,
        instant_for(end_time).tt,
        type: :maximum
      ).map { |extremum| build_event(extremum) }
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
