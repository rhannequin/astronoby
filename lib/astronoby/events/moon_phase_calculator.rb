# frozen_string_literal: true

module Astronoby
  # @api private
  class MoonPhaseCalculator
    TARGETS = {
      MoonPhase::NEW_MOON => 0.0,
      MoonPhase::FIRST_QUARTER => 90.0,
      MoonPhase::FULL_MOON => 180.0,
      MoonPhase::LAST_QUARTER => 270.0
    }.freeze
    MEAN_RATE_IN_DEGREES_PER_DAY = 12.190749
    TOLERANCE_IN_DAYS = 1e-8
    MAX_ITERATIONS = 10
    SEED_MARGIN_IN_DAYS = 1

    def initialize(ephem:)
      @ephem = ephem
    end

    def phases_between(start_instant, end_instant)
      seeds(start_instant, end_instant).filter_map do |seed|
        seed_tt = seed.instant.tt
        next unless seed_tt.between?(
          start_instant.tt - SEED_MARGIN_IN_DAYS,
          end_instant.tt + SEED_MARGIN_IN_DAYS
        )

        tt = refine(seed_tt, TARGETS.fetch(seed.phase))
        next unless tt.between?(start_instant.tt, end_instant.tt)

        MoonPhase.new(
          instant: Instant.from_terrestrial_time(tt),
          phase: seed.phase
        )
      end
    end

    private

    def seeds(start_instant, end_instant)
      first = (start_instant.to_time - Constants::SECONDS_PER_DAY).to_date
      last = (end_instant.to_time + Constants::SECONDS_PER_DAY).to_date
      months(first, last).flat_map do |date|
        Events::MoonPhases.phases_for(year: date.year, month: date.month)
      end
    end

    def months(first, last)
      cursor = Date.new(first.year, first.month, 1)
      found = []
      while cursor <= last
        found << cursor
        cursor = cursor.next_month
      end
      found
    end

    def refine(tt, target)
      rate = MEAN_RATE_IN_DEGREES_PER_DAY
      previous = nil

      MAX_ITERATIONS.times do
        residual = wrap(longitude_difference_at(tt) - target)
        if previous && tt != previous[:tt]
          rate = (residual - previous[:residual]) / (tt - previous[:tt])
        end
        step = residual / rate
        previous = {tt: tt, residual: residual}
        tt -= step
        break if step.abs < TOLERANCE_IN_DAYS
      end

      tt
    end

    def wrap(degrees)
      (degrees + 180) % 360 - 180
    end

    def longitude_difference_at(tt)
      snapshot = Sky::Snapshot.new(
        ephem: @ephem,
        instant: Instant.from_terrestrial_time(tt)
      )
      snapshot.body(Moon).apparent.ecliptic.longitude.degrees -
        snapshot.body(Sun).apparent.ecliptic.longitude.degrees
    end
  end
end
