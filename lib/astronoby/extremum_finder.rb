# frozen_string_literal: true

module Astronoby
  class ExtremumFinder
    PHI = (1 + Math.sqrt(5)) / 2
    INVPHI = 1 / PHI
    GOLDEN_SECTION_TOLERANCE = 1e-5

    MIN_SAMPLES_PER_PERIOD = 20
    DUPLICATE_THRESHOLD_DAYS = 0.5
    BOUNDARY_BUFFER_DAYS = 0.01

    # @param value_at [#call] callable mapping a Julian Date (Terrestrial Time)
    #   to a comparable value
    # @param period [Float] the characteristic period of the quantity in days,
    #   used to scale the sampling density
    # @param samples_per_period [Integer] number of samples per period
    def initialize(value_at:, period:, samples_per_period: 60)
      @value_at = value_at
      @period = period
      @samples_per_period = samples_per_period
    end

    # @param start_jd [Float] start time in Julian Date (Terrestrial Time)
    # @param end_jd [Float] end time in Julian Date (Terrestrial Time)
    # @param type [Symbol] +:maximum+ or +:minimum+
    # @return [Array<Hash>] extrema as +{jd: Float, value: Comparable}+, sorted
    #   by time
    def extrema(start_jd, end_jd, type: :maximum)
      candidates = find_candidates(start_jd, end_jd, type)
      refined = candidates.map { |candidate| refine(candidate, type) }.compact
      refined = remove_duplicates(refined)
      filter_boundary_artifacts(refined, start_jd, end_jd)
    end

    private

    def find_candidates(start_jd, end_jd, type)
      samples = collect_samples(start_jd, end_jd)
      find_local_extrema(samples, type)
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

    def find_local_extrema(samples, type)
      candidates = []

      (1...samples.length - 1).each do |i|
        next unless local_extremum?(samples, i, type)

        candidates << {
          start_jd: samples[i - 1][:jd],
          end_jd: samples[i + 1][:jd]
        }
      end

      candidates
    end

    def local_extremum?(samples, index, type)
      current = samples[index][:value]
      previous = samples[index - 1][:value]
      following = samples[index + 1][:value]

      if type == :maximum
        current > previous && current > following
      else
        current < previous && current < following
      end
    end

    def refine(candidate, type)
      golden_section_search(candidate[:start_jd], candidate[:end_jd], type)
    end

    def golden_section_search(a, b, type)
      return nil if b <= a

      tol = GOLDEN_SECTION_TOLERANCE * (b - a).abs

      x1 = a + (1 - INVPHI) * (b - a)
      x2 = a + INVPHI * (b - a)
      f1 = @value_at.call(x1)
      f2 = @value_at.call(x2)

      while (b - a).abs > tol
        keep_left = (type == :maximum) ? (f1 > f2) : (f1 < f2)

        if keep_left
          b = x2
          x2 = x1
          f2 = f1
          x1 = a + (1 - INVPHI) * (b - a)
          f1 = @value_at.call(x1)
        else
          a = x1
          x1 = x2
          f1 = f2
          x2 = a + INVPHI * (b - a)
          f2 = @value_at.call(x2)
        end
      end

      mid = (a + b) / 2
      {jd: mid, value: @value_at.call(mid)}
    end

    def remove_duplicates(extrema)
      return extrema if extrema.length <= 1

      cleaned = [extrema.first]

      extrema.each_with_index do |current, i|
        next if i == 0

        is_duplicate = cleaned.any? do |existing|
          (current[:jd] - existing[:jd]).abs < DUPLICATE_THRESHOLD_DAYS
        end

        cleaned << current unless is_duplicate
      end

      cleaned
    end

    def filter_boundary_artifacts(extrema, start_jd, end_jd)
      extrema.reject do |extreme|
        (extreme[:jd] - start_jd).abs < BOUNDARY_BUFFER_DAYS ||
          (extreme[:jd] - end_jd).abs < BOUNDARY_BUFFER_DAYS
      end
    end
  end
end
