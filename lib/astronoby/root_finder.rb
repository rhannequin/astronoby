# frozen_string_literal: true

module Astronoby
  class RootFinder
    MIN_SAMPLES_PER_PERIOD = 20
    BISECTION_TOLERANCE_DAYS = 1e-5

    # @param value_at [#call] callable mapping a Julian Date (Terrestrial Time)
    #   to a Float
    # @param period [Float] the characteristic period of the quantity in days
    # @param samples_per_period [Integer] number of samples per period
    def initialize(value_at:, period:, samples_per_period: 60)
      @value_at = value_at
      @period = period
      @samples_per_period = samples_per_period
    end

    # @param start_jd [Float] start time in Julian Date (Terrestrial Time)
    # @param end_jd [Float] end time in Julian Date (Terrestrial Time)
    # @param accept [#call, nil] optional predicate on a located root (a Julian
    #   Date)
    # @return [Array<Float>] root times in Julian Date (Terrestrial Time),
    #   sorted by time
    def roots(start_jd, end_jd, accept: nil)
      brackets = find_brackets(start_jd, end_jd)
      located = brackets.map { |a, b| bisect(a, b) }
      located.select { |jd| accept.nil? || accept.call(jd) }
    end

    private

    def find_brackets(start_jd, end_jd)
      samples = collect_samples(start_jd, end_jd)

      (0...samples.length - 1).filter_map do |i|
        current = samples[i]
        following = samples[i + 1]

        [current[:jd], following[:jd]] if sign_change?(current, following)
      end
    end

    def sign_change?(current, following)
      current[:value] * following[:value] < 0
    end

    def collect_samples(start_jd, end_jd)
      duration = end_jd - start_jd
      sample_count = sample_count_for(duration)
      step = duration / sample_count

      (0..sample_count).map do |i|
        jd = start_jd + (i * step)
        {jd: jd, value: @value_at.call(jd)}
      end
    end

    def sample_count_for(duration)
      periods_in_range = duration / @period
      base_samples = (periods_in_range * @samples_per_period).to_i
      [base_samples, MIN_SAMPLES_PER_PERIOD].max
    end

    def bisect(a, b)
      f_a = @value_at.call(a)

      while (b - a).abs > BISECTION_TOLERANCE_DAYS
        midpoint = (a + b) / 2
        f_midpoint = @value_at.call(midpoint)
        return midpoint if f_midpoint.zero?

        if f_a.negative? == f_midpoint.negative?
          a = midpoint
          f_a = f_midpoint
        else
          b = midpoint
        end
      end

      (a + b) / 2
    end
  end
end
