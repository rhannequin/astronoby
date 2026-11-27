# frozen_string_literal: true

module Astronoby
  # @api private
  class SeasonCalculator
    KINDS = SeasonStart::KINDS
    MEAN_RATE_IN_DEGREES_PER_DAY = 0.98564736
    TOLERANCE_IN_DAYS = 1e-8
    MAX_ITERATIONS = 10
    SEED_MARGIN_IN_DAYS = 1

    def initialize(ephem:)
      @ephem = ephem
    end

    def season_starts_between(start_instant, end_instant)
      years = (start_instant.to_time.year - 1)..(end_instant.to_time.year + 1)
      years.flat_map do |year|
        KINDS.each_with_index.filter_map do |kind, index|
          seed_tt = EquinoxSolstice.new(year, index, @ephem).estimate.tt
          next unless seed_tt.between?(
            start_instant.tt - SEED_MARGIN_IN_DAYS,
            end_instant.tt + SEED_MARGIN_IN_DAYS
          )

          tt = refine(seed_tt, index * 90.0)
          next unless tt.between?(start_instant.tt, end_instant.tt)

          SeasonStart.new(instant: Instant.from_terrestrial_time(tt), kind: kind)
        end
      end
    end

    private

    def refine(tt, target)
      rate = MEAN_RATE_IN_DEGREES_PER_DAY
      previous = nil

      MAX_ITERATIONS.times do
        residual = wrap(sun_longitude_at(tt) - target)
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

    def sun_longitude_at(tt)
      Sun
        .new(ephem: @ephem, instant: Instant.from_terrestrial_time(tt))
        .apparent
        .ecliptic
        .longitude
        .degrees
    end
  end
end
