# frozen_string_literal: true

module Astronoby
  # Calculates extrema (minima and maxima) in the distance between two
  # celestial bodies over a given time range using adaptive sampling and golden
  # section search refinement.
  class ExtremumCalculator
    # Mathematical constants
    PHI = (1 + Math.sqrt(5)) / 2
    INVPHI = 1 / PHI
    GOLDEN_SECTION_TOLERANCE = 1e-5

    # Algorithm parameters
    MIN_SAMPLES_PER_PERIOD = 20
    DUPLICATE_THRESHOLD_DAYS = 0.5
    BOUNDARY_BUFFER_DAYS = 0.01

    # Orbital periods
    ORBITAL_PERIODS = {
      "Astronoby::Moon" => 27.504339,
      "Astronoby::Mercury" => 87.969,
      "Astronoby::Venus" => 224.701,
      "Astronoby::Earth" => 365.256,
      "Astronoby::Mars" => 686.98,
      "Astronoby::Jupiter" => 4332.59,
      "Astronoby::Saturn" => 10759.22,
      "Astronoby::Uranus" => 30688.5,
      "Astronoby::Neptune" => 60182.0
    }.freeze

    # @param ephem [::Ephem::SPK] Ephemeris data source
    # @param body [Astronoby::SolarSystemBody] The celestial body to track
    # @param primary_body [Astronoby::SolarSystemBody] The reference body
    #   (e.g., Sun for planetary orbits)
    # @param samples_per_period [Integer] Number of samples to take per orbital
    #   period
    def initialize(
      body:,
      primary_body:,
      ephem:,
      samples_per_period: 60
    )
      @ephem = ephem
      @body = body
      @primary_body = primary_body
      @orbital_period = ORBITAL_PERIODS.fetch(body.name)
      @samples_per_period = samples_per_period
    end

    # Finds all apoapsis events between two times
    # @param start_time [Time] Start time
    # @param end_time [Time] End time
    # @return [Array<Astronoby::ExtremumEvent>] Array of apoapsis events
    def apoapsis_events_between(start_time, end_time)
      find_extrema(
        Astronoby::Instant.from_time(start_time).julian_date,
        Astronoby::Instant.from_time(end_time).julian_date,
        type: :maximum
      )
    end

    # Finds all periapsis events between two times
    # @param start_time [Time] Start time
    # @param end_time [Time] End time
    # @return [Array<Astronoby::ExtremumEvent>] Array of periapsis events
    def periapsis_events_between(start_time, end_time)
      find_extrema(
        Astronoby::Instant.from_time(start_time).julian_date,
        Astronoby::Instant.from_time(end_time).julian_date,
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
      # 1: Find extrema candidates through adaptive sampling
      candidates = find_extrema_candidates(start_jd, end_jd, type)

      # 2: Refine each candidate using golden section search
      refined_extrema = candidates
        .map { |candidate| refine_extremum(candidate, type) }
        .compact

      # 3: Remove duplicates and boundary artifacts
      refined_extrema = remove_duplicates(refined_extrema)
      filter_boundary_artifacts(refined_extrema, start_jd, end_jd)
    end

    private

    def distance_at(jd)
      instant = Instant.from_terrestrial_time(jd)
      body_geometric = @body.geometric(ephem: @ephem, instant: instant)
      primary_geometric = @primary_body
        .geometric(ephem: @ephem, instant: instant)

      distance_vector = body_geometric.position - primary_geometric.position
      distance_vector.magnitude
    end

    def find_extrema_candidates(start_jd, end_jd, type)
      samples = collect_samples(start_jd, end_jd)
      find_local_extrema_in_samples(samples, type)
    end

    def collect_samples(start_jd, end_jd)
      duration = end_jd - start_jd
      sample_count = calculate_sample_count(duration)
      step = duration / sample_count

      (0..sample_count).map do |i|
        jd = start_jd + (i * step)
        {jd: jd, value: distance_at(jd)}
      end
    end

    def calculate_sample_count(duration)
      # Adaptive sampling: scale with duration and orbital period
      periods_in_range = duration / @orbital_period
      base_samples = (periods_in_range * @samples_per_period).to_i

      # Ensure minimum sample density for short ranges
      [base_samples, MIN_SAMPLES_PER_PERIOD].max
    end

    def find_local_extrema_in_samples(samples, type)
      candidates = []

      # Check each interior point for local extrema
      (1...samples.length - 1).each do |i|
        if local_extremum?(samples, i, type)
          candidates << {
            start_jd: samples[i - 1][:jd],
            end_jd: samples[i + 1][:jd],
            center_jd: samples[i][:jd]
          }
        end
      end

      candidates
    end

    def local_extremum?(samples, index, type)
      current_val = samples[index][:value].m
      prev_val = samples[index - 1][:value].m
      next_val = samples[index + 1][:value].m

      if type == :maximum
        current_val > prev_val && current_val > next_val
      else
        current_val < prev_val && current_val < next_val
      end
    end

    def refine_extremum(candidate, type)
      golden_section_search(candidate[:start_jd], candidate[:end_jd], type)
    end

    def golden_section_search(a, b, type)
      return nil if b <= a

      tol = GOLDEN_SECTION_TOLERANCE * (b - a).abs

      # Initial points using golden ratio
      x1 = a + (1 - INVPHI) * (b - a)
      x2 = a + INVPHI * (b - a)

      f1 = distance_at(x1).m
      f2 = distance_at(x2).m

      while (b - a).abs > tol
        should_keep_left = (type == :maximum) ? (f1 > f2) : (f1 < f2)

        if should_keep_left
          b = x2
          x2 = x1
          f2 = f1
          x1 = a + (1 - INVPHI) * (b - a)
          f1 = distance_at(x1).m
        else
          a = x1
          x1 = x2
          f1 = f2
          x2 = a + INVPHI * (b - a)
          f2 = distance_at(x2).m
        end
      end

      mid = (a + b) / 2
      ExtremumEvent.new(
        Instant.from_terrestrial_time(mid),
        distance_at(mid)
      )
    end

    def remove_duplicates(extrema)
      return extrema if extrema.length <= 1

      cleaned = [extrema.first]

      extrema.each_with_index do |current, i|
        next if i == 0

        is_duplicate = cleaned.any? do |existing|
          time_diff = (
            current.instant.julian_date - existing.instant.julian_date
          ).abs
          time_diff < DUPLICATE_THRESHOLD_DAYS
        end

        cleaned << current unless is_duplicate
      end

      cleaned
    end

    def filter_boundary_artifacts(extrema, start_jd, end_jd)
      extrema.reject do |extreme|
        start_diff = (extreme.instant.julian_date - start_jd).abs
        end_diff = (extreme.instant.julian_date - end_jd).abs

        too_close_to_start = start_diff < BOUNDARY_BUFFER_DAYS
        too_close_to_end = end_diff < BOUNDARY_BUFFER_DAYS
        too_close_to_start || too_close_to_end
      end
    end
  end
end
