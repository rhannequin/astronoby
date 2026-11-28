# frozen_string_literal: true

module Astronoby
  class GreatestElongationCalculator
    RATE_STEP_IN_DAYS = 0.01

    # @param body [Astronoby::SolarSystemBody] the planet to track
    # @param ephem [::Ephem::SPK] ephemeris data source
    # @param samples_per_period [Integer] number of samples per synodic period
    def initialize(body:, ephem:, samples_per_period: 60)
      @body = body
      @ephem = ephem
      @samples_per_period = samples_per_period
    end

    # @deprecated Use {Astronoby::Sky::Target#greatest_elongations} instead
    # @param start_time [Time, Astronoby::Instant] start time
    # @param end_time [Time, Astronoby::Instant] end time
    # @return [Array<Astronoby::GreatestElongation>] greatest elongations in
    #   the range
    def greatest_elongation_events_between(start_time, end_time)
      Deprecation.warn(self.class, :greatest_elongation_events_between) do
        [
          "Astronoby::GreatestElongationCalculator" \
            "#greatest_elongation_events_between",
          "sky.#{@body.sky_name}.greatest_elongations"
        ]
      end
      start_jd = Instant.from(start_time).tt
      end_jd = Instant.from(end_time).tt

      finder
        .extrema_by_rate(
          start_jd,
          end_jd,
          type: :maximum,
          rate_at: method(:rate_at)
        )
        .map { |maximum| build_event(maximum) }
    end

    private

    def finder
      @finder ||= ExtremumFinder.new(
        value_at: ->(jd) { planet_at(jd).elongation },
        period: synodic_period,
        samples_per_period: @samples_per_period
      )
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
      Sky::Snapshot
        .new(ephem: @ephem, instant: Instant.from_terrestrial_time(jd))
        .body(@body)
    end

    def synodic_period
      @synodic_period ||=
        1.0 / ((1.0 / @body::ORBITAL_PERIOD) - (1.0 / Earth::ORBITAL_PERIOD)).abs
    end
  end
end
