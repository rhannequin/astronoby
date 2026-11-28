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
    SEED_MARGIN_IN_DAYS = 0.1
    FALLBACK_HALF_WIDTH_IN_DAYS = 0.5

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
        next unless covered?(seed_tt)

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

      seed = tt
      MAX_ITERATIONS.times do
        residual = wrap(longitude_difference_at(tt) - target)
        if previous && tt != previous[:tt]
          rate = (residual - previous[:residual]) / (tt - previous[:tt])
        end
        step = residual / rate
        break unless step.abs <= FALLBACK_HALF_WIDTH_IN_DAYS

        previous = {tt: tt, residual: residual}
        tt -= step
        return tt if step.abs < TOLERANCE_IN_DAYS
      end

      bisect_near(seed) { |jd| wrap(longitude_difference_at(jd) - target) }
    end

    def bisect_near(seed, &residual)
      RootFinder
        .new(value_at: residual, period: 2 * FALLBACK_HALF_WIDTH_IN_DAYS)
        .roots(seed - FALLBACK_HALF_WIDTH_IN_DAYS, seed + FALLBACK_HALF_WIDTH_IN_DAYS)
        .min_by { |jd| (jd - seed).abs } || seed
    end

    def covered?(tt)
      first, last = @ephem.coverage
      tt.between?(first, last)
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
