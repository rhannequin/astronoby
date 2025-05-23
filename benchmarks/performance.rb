require "benchmark"
require "etc"

class PerformanceBenchmark
  attr_reader :warmup_runs,
    :measure_runs,
    :iterations_per_run,
    :planets,
    :ephem

  BENCHMARK_METRICS = [
    :rts_event_on,
    :rts_events_between,
    :twilight_event_on,
    :moon_phases
  ]

  def initialize(warmup_runs: 2, measure_runs: 3, iterations_per_run: 10)
    @warmup_runs = warmup_runs
    @measure_runs = measure_runs
    @iterations_per_run = iterations_per_run
    @ephem = Astronoby::Ephem
      .load("spec/support/data/inpop19a_2000_2050_excerpt.bsp")
    @planets = [
      Astronoby::Mercury,
      Astronoby::Venus,
      Astronoby::Mars,
      Astronoby::Jupiter,
      Astronoby::Saturn,
      Astronoby::Uranus,
      Astronoby::Neptune
    ]
  end

  def run
    print_env_info
    warmup
    all_results = measure
    print_results(**all_results)
    nil
  end

  private

  def print_env_info
    puts "Astronoby Performance Benchmark"
    puts "  Ruby version : #{RUBY_VERSION}"
    puts "  Date         : #{Date.today}\n\n"
  end

  def warmup
    puts "Warming up (#{warmup_runs} run#{"s" if warmup_runs > 1}, not measured)..."
    warmup_runs.times do
      GC.start
      time_single_run
    end
    puts
  end

  def measure
    puts "Measuring (#{measure_runs} run#{"s" if measure_runs > 1}, each #{iterations_per_run} iterations)..."
    result_arrays = BENCHMARK_METRICS.map { |k| [k, []] }.to_h
    total_times = []

    measure_runs.times do |i|
      GC.start
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      single_run_results = time_single_run
      duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

      BENCHMARK_METRICS.each_with_index do |metric, idx|
        result_arrays[metric] << single_run_results[idx]
      end
      total_times << duration

      puts "  Run #{i + 1}/#{measure_runs} complete."
    end
    puts
    result_arrays.merge(total: total_times)
  end

  def time_single_run
    times = Hash.new(0)
    iterations_per_run.times do
      planets.each do |planet|
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(rand(-40..40)),
          longitude: Astronoby::Angle.from_degrees(rand(-40..40))
        )
        rts_calculator = Astronoby::RiseTransitSetCalculator.new(
          body: planet,
          observer: observer,
          ephem: ephem
        )
        twilight_calculator = Astronoby::TwilightCalculator.new(
          observer: observer,
          ephem: ephem
        )

        times[:rts_event_on] += time_block do
          (Date.new(2025, 5, 1)..Date.new(2025, 6, 1)).each do |date|
            rts_calculator.event_on(date)
          end
        end
        times[:rts_events_between] += time_block do
          rts_calculator.events_between(
            Time.utc(2025, 7, 1),
            Time.utc(2025, 8, 1)
          )
        end
        times[:twilight_event_on] += time_block do
          (Date.new(2025, 5, 1)..Date.new(2025, 6, 1)).each do |date|
            twilight_calculator.event_on(date)
          end
        end
        times[:moon_phases] += time_block do
          (2000..2050).each do |year|
            (1..12).each do |month|
              Astronoby::Events::MoonPhases.phases_for(year: year, month: month)
            end
          end
        end
      end
    end

    BENCHMARK_METRICS.map { |k| times[k] }
  end

  def time_block
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
  end

  def print_results(**results)
    puts "RESULTS (averaged over #{measure_runs} run#{"s" if measure_runs > 1}, each #{iterations_per_run} iterations):"
    max_label_length = results.keys.map { |label| label.to_s.length }.max
    results.each do |label, data|
      puts formatted_result(label, data, max_label_length)
    end
  end

  def formatted_result(label, data, label_width)
    if data.respond_to?(:sum)
      format(
        "  %-#{label_width}s  %8.2f  ± %5.2f sec",
        "#{label}:",
        mean(data),
        stddev(data)
      )
    else
      format("  %-#{label_width}s  %s", "#{label}:", data.inspect)
    end
  end

  def mean(array)
    array.sum(0.0) / array.size
  end

  def stddev(array)
    m = mean(array)
    Math.sqrt(array.sum { |x| (x - m)**2 } / array.size)
  end
end
