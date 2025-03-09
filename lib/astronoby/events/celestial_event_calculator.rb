# frozen_string_literal: true

module Astronoby
  class CelestialEvents
    attr_accessor :rising_time,
      :rising_azimuth,
      :transit_time,
      :transit_altitude,
      :setting_time,
      :setting_azimuth

    def initialize(
      rising_time: nil,
      rising_azimuth: nil,
      transit_time: nil,
      transit_altitude: nil,
      setting_time: nil,
      setting_azimuth: nil
    )
      @rising_time = rising_time
      @rising_azimuth = rising_azimuth
      @transit_time = transit_time
      @transit_altitude = transit_altitude
      @setting_time = setting_time
      @setting_azimuth = setting_azimuth
    end

    def to_h
      {
        rising_time: @rising_time,
        rising_azimuth: @rising_azimuth,
        transit_time: @transit_time,
        transit_altitude: @transit_altitude,
        setting_time: @setting_time,
        setting_azimuth: @setting_azimuth
      }
    end
  end

  class CelestialEventCalculator
    STANDARD_REFRACTION_ANGLE = Angle.from_dms(0, -34, 0)
    SUN_REFRACTION_ANGLE = Angle.from_dms(0, -50, 0)
    MOON_RADIUS = Distance.from_meters(1.7374e6)
    SAMPLE_COUNT = 10

    # Search parameters
    BINARY_SEARCH_ITERATIONS = 8
    EVENT_DIRECTION_CHECK_OFFSET = 60  # seconds
    TRANSIT_REFINEMENT_WINDOW = 300    # seconds

    class CalculationError < StandardError; end

    # @param observer [Object] The observer's location
    # @param target_body [Class] Celestial body class to calculate events for
    # @param ephem [Object] The ephemeris data source
    def initialize(observer:, target_body:, ephem:)
      @observer = observer
      @target_body = target_body
      @ephem = ephem
    end

    # Calculate all events (rising, transit, setting) for a given date
    # @param date [Date] The date to calculate events for
    # @return [CelestialEvents] Object containing all calculated events
    def calculate_events(date)
      @date = date
      @time_range = compute_time_range(date)
      @horizon_function = build_horizon_function

      sample_times = generate_sample_times

      sample_data = collect_sample_data(sample_times)

      events = CelestialEvents.new
      populate_event_times(events, sample_times, sample_data)
      calculate_additional_data(events)

      events
    end

    private

    # Computes the time range for the given date in the observer's timezone
    # @param date [Date] The date to compute time range for
    # @return [Array<Time>] Start and end times for the date
    def compute_time_range(date)
      start_time = Time.new(
        date.year, date.month, date.day, 0, 0, 0, @observer.utc_offset
      )
      end_time = Time.new(
        date.year, date.month, date.day, 23, 59, 59, @observer.utc_offset
      )

      [start_time, end_time]
    end

    # Generates evenly spaced sample times throughout the day
    # @return [Array<Time>] Sample times
    def generate_sample_times
      start_time, end_time = @time_range

      SAMPLE_COUNT.times.map do |i|
        fraction = i.to_f / (SAMPLE_COUNT - 1)
        start_time + fraction * (end_time - start_time)
      end
    end

    # Collects sky position data for each sample time
    # @param sample_times [Array<Time>] The times to collect data for
    # @return [Array<Hash>] Position data for each time
    def collect_sample_data(sample_times)
      sample_times.map do |time|
        calculate_sky_position(time, @horizon_function)
      end
    end

    # Populates the rising, transit, and setting times
    # @param events [CelestialEvents] The events object to populate
    # @param sample_times [Array<Time>] Sample times
    # @param sample_data [Array<Hash>] Position data for sample times
    def populate_event_times(events, sample_times, sample_data)
      events.rising_time = find_rising_time(sample_times, sample_data)&.round
      events.transit_time = find_transit_time(sample_times, sample_data)&.round
      events.setting_time = find_setting_time(sample_times, sample_data)&.round
    end

    # Calculates additional data points (azimuths and altitudes) for found event
    # times
    # @param events [CelestialEvents] The events object to populate
    def calculate_additional_data(events)
      if events.rising_time
        events.rising_azimuth = calculate_azimuth(events.rising_time)
      end

      if events.transit_time
        events.transit_altitude = calculate_altitude(events.transit_time)
      end

      if events.setting_time
        events.setting_azimuth = calculate_azimuth(events.setting_time)
      end
    end

    # Calculate position data at a specific time
    # @param time [Time] The time to calculate for
    # @param horizon_function [Proc] Function to calculate horizon for given
    #   distance
    # @return [Hash] Sky position data
    def calculate_sky_position(time, horizon_function)
      instant = Instant.from_time(time)

      @target_body.new(instant: instant, ephem: @ephem).tap do |body|
        topocentric = body.observed_by(@observer)
        horizontal = topocentric.horizontal
        equatorial = topocentric.equatorial
        distance = topocentric.distance
        altitude = horizontal.altitude.radians
        azimuth = horizontal.azimuth.radians

        return {
          time: time,
          altitude: altitude,
          azimuth: azimuth,
          hour_angle: equatorial.compute_hour_angle(
            time: time,
            longitude: @observer.longitude
          ).radians,
          horizon: horizon_function.call(distance),
          above_horizon: altitude > horizon_function.call(distance)
        }
      end
    rescue => e
      raise CalculationError, "Failed to calculate sky position: #{e.message}"
    end

    # Find the rising time using binary search and interpolation
    # @param sample_times [Array<Time>] Array of sample times
    # @param sample_data [Array<Hash>] Position data for each sample time
    # @return [Time, nil] The rising time or nil if not found
    def find_rising_time(sample_times, sample_data)
      find_horizon_crossings(sample_times, sample_data, :rising)
    end

    # Find the transit time (meridian crossing or maximum altitude)
    # @param sample_times [Array<Time>] Array of sample times
    # @param sample_data [Array<Hash>] Position data for each sample time
    # @return [Time, nil] The transit time or nil if not found
    def find_transit_time(sample_times, sample_data)
      # Method 1: Find meridian crossings (hour angle = 0)
      transit_candidate = find_meridian_crossings(sample_times, sample_data)

      # Method 2: Find altitude maxima if needed
      if transit_candidate.nil?
        transit_candidate = find_altitude_maxima(sample_times, sample_data)
      end

      transit_candidate
    end

    # Find the setting time using binary search and interpolation
    # @param sample_times [Array<Time>] Array of sample times
    # @param sample_data [Array<Hash>] Position data for each sample time
    # @return [Time, nil] The setting time or nil if not found
    def find_setting_time(sample_times, sample_data)
      find_horizon_crossings(sample_times, sample_data, :setting)
    end

    # Find horizon crossings (rising or setting)
    # @param sample_times [Array<Time>] Sample times
    # @param sample_data [Array<Hash>] Position data
    # @param event_type [Symbol] :rising or :setting
    # @return [Time, nil] Candidate event time
    def find_horizon_crossings(sample_times, sample_data, event_type)
      candidate = nil

      # Determine the conditions based on event type
      (0...sample_times.length - 1).each do |i|
        first_above = sample_data[i][:altitude] > sample_data[i][:horizon]
        next_above = sample_data[i + 1][:altitude] > sample_data[i + 1][:horizon]

        # Check for the correct crossing pattern
        if (event_type == :rising && !first_above && next_above) ||
            (event_type == :setting && first_above && !next_above)

          crossing_time = binary_search_crossing(
            sample_times[i],
            sample_times[i + 1],
            event_type
          )

          if confirm_event_direction?(crossing_time, event_type)
            candidate = crossing_time
            break  # Use the first valid crossing
          end
        end
      end

      candidate
    end

    # Find times when the body crosses the meridian (hour angle = 0)
    # @param sample_times [Array<Time>] Sample times
    # @param sample_data [Array<Hash>] Position data
    # @return [Time, nil] Candidate transit time
    def find_meridian_crossings(sample_times, sample_data)
      candidate = nil

      (0...sample_times.length - 1).each do |i|
        # Extract and normalize hour angles to [-π, π]
        ha1 = normalize_hour_angle(sample_data[i][:hour_angle])
        ha2 = normalize_hour_angle(sample_data[i + 1][:hour_angle])

        # Check if it crosses zero (sign change) without wrapping around the
        # full circle
        if ha1 * ha2 <= 0 && (ha1 - ha2).abs < Math::PI
          # Interpolate to find approximate crossing
          fraction = ha1.abs / (ha1.abs + ha2.abs)
          approx_time = sample_times[i] +
            fraction * (sample_times[i + 1] -
              sample_times[i])

          # Refine with binary search
          refined_time = binary_search_transit(
            approx_time - TRANSIT_REFINEMENT_WINDOW,
            approx_time + TRANSIT_REFINEMENT_WINDOW
          )

          candidate = refined_time
        end
      end

      candidate
    end

    # Find times of maximum altitude (potential transits)
    # @param sample_times [Array<Time>] Sample times
    # @param sample_data [Array<Hash>] Position data
    # @return [Time, nil] Candidate transit time based on altitude maxima
    def find_altitude_maxima(sample_times, sample_data)
      candidate = nil

      # Extract altitudes
      altitudes = sample_data.map { |d| d[:altitude] }

      # Look for local maxima
      (1...altitudes.length - 1).each do |i|
        if altitudes[i] > altitudes[i - 1] && altitudes[i] > altitudes[i + 1]
          # Local maximum found, refine it with quadratic interpolation
          max_time = quadratic_maximum(
            sample_times[i - 1], sample_times[i], sample_times[i + 1],
            altitudes[i - 1], altitudes[i], altitudes[i + 1]
          )
          candidate = max_time
        end
      end

      candidate
    end

    # Normalize hour angle to the range [-π, π]
    # @param hour_angle [Float] The hour angle in radians
    # @return [Float] Normalized hour angle
    def normalize_hour_angle(hour_angle)
      ((hour_angle + Math::PI) % (2 * Math::PI)) - Math::PI
    end

    # Binary search to find horizon crossing with high precision
    # @param t_min [Time] Lower bound time
    # @param t_max [Time] Upper bound time
    # @param event_type [Symbol] :rising or :setting
    # @return [Time] Precise crossing time
    def binary_search_crossing(t_min, t_max, event_type)
      # Use iterative binary search for precision
      BINARY_SEARCH_ITERATIONS.times do
        t_mid = Time.at((t_min.to_f + t_max.to_f) / 2)

        instant = Instant.from_time(t_mid)
        body = @target_body.new(instant: instant, ephem: @ephem)
        horizontal = body.observed_by(@observer).horizontal
        altitude = horizontal.altitude.radians

        distance = body.apparent.distance
        horizon = @horizon_function.call(distance)

        if event_type == :rising
          (altitude < horizon) ? t_min = t_mid : t_max = t_mid
        else # :setting
          (altitude > horizon) ? t_min = t_mid : t_max = t_mid
        end
      end

      # Final linear interpolation for precision
      interpolate_crossing(t_min, t_max)
    end

    # Interpolate crossing time between two close times
    # @param t_min [Time] Time before crossing
    # @param t_max [Time] Time after crossing
    # @return [Time] Interpolated crossing time
    def interpolate_crossing(t_min, t_max)
      # Get altitude and horizon at t_min
      instant_min = Instant.from_time(t_min)
      body_min = @target_body.new(instant: instant_min, ephem: @ephem)
      altitude_min = body_min.observed_by(@observer).horizontal.altitude.radians
      distance_min = body_min.apparent.distance
      horizon_min = @horizon_function.call(distance_min)

      # Get altitude and horizon at t_max
      instant_max = Instant.from_time(t_max)
      body_max = @target_body.new(instant: instant_max, ephem: @ephem)
      altitude_max = body_max.observed_by(@observer).horizontal.altitude.radians
      distance_max = body_max.apparent.distance
      horizon_max = @horizon_function.call(distance_max)

      # Calculate altitude relative to horizon
      relative_min = altitude_min - horizon_min
      relative_max = altitude_max - horizon_max

      # Linear interpolation to find exact crossing
      fraction = relative_min.abs / (relative_min.abs + relative_max.abs)
      Time.at(t_min.to_f + fraction * (t_max.to_f - t_min.to_f))
    end

    # Binary search to find exact transit (hour angle = 0)
    # @param t_min [Time] Lower bound time
    # @param t_max [Time] Upper bound time
    # @return [Time] Precise transit time
    def binary_search_transit(t_min, t_max)
      BINARY_SEARCH_ITERATIONS.times do
        t_mid = Time.at((t_min.to_f + t_max.to_f) / 2)

        instant = Instant.from_time(t_mid)
        body = @target_body.new(instant: instant, ephem: @ephem)
        equatorial = body.apparent.equatorial
        hour_angle = equatorial.compute_hour_angle(
          time: t_mid,
          longitude: @observer.longitude
        ).radians

        # Normalize to [-π, π]
        hour_angle = normalize_hour_angle(hour_angle)

        if hour_angle < 0
          # Hour angle negative, object hasn't reached meridian yet
          t_min = t_mid
        else
          # Hour angle positive, object already passed meridian
          t_max = t_mid
        end
      end

      # Final interpolation
      instant_min = Instant.from_time(t_min)
      body_min = @target_body.new(instant: instant_min, ephem: @ephem)
      ha_min = normalize_hour_angle(
        body_min.apparent.equatorial.compute_hour_angle(
          time: t_min,
          longitude: @observer.longitude
        ).radians
      )

      instant_max = Instant.from_time(t_max)
      body_max = @target_body.new(instant: instant_max, ephem: @ephem)
      ha_max = normalize_hour_angle(
        body_max.apparent.equatorial.compute_hour_angle(
          time: t_max,
          longitude: @observer.longitude
        ).radians
      )

      # Linear interpolation for zero crossing
      fraction = ha_min.abs / (ha_min.abs + ha_max.abs)
      Time.at(t_min.to_f + fraction * (t_max.to_f - t_min.to_f))
    end

    # Find maximum altitude using quadratic interpolation
    # @param t1, t2, t3 [Time] Three consecutive times
    # @param alt1, alt2, alt3 [Float] Corresponding altitudes
    # @return [Time] Time of maximum altitude
    def quadratic_maximum(t1, t2, t3, alt1, alt2, alt3)
      # Convert to float seconds for arithmetic
      x1, x2, x3 = t1.to_f, t2.to_f, t3.to_f
      y1, y2, y3 = alt1, alt2, alt3

      # Quadratic interpolation formula
      denom = (x1 - x2) * (x1 - x3) * (x2 - x3)
      a = (x3 * (y2 - y1) +
        x2 * (y1 - y3) +
        x1 * (y3 - y2)) / denom
      b = (x3 * x3 * (y1 - y2) +
        x2 * x2 * (y3 - y1) +
        x1 * x1 * (y2 - y3)) / denom

      # Maximum is at -b/2a
      max_t = -b / (2 * a)

      # Return as Time object
      Time.at(max_t)
    end

    # Calculate azimuth at a specific time
    # @param time [Time] The time to calculate for
    # @return [Object] Azimuth angle
    def calculate_azimuth(time)
      instant = Instant.from_time(time)
      body = @target_body.new(instant: instant, ephem: @ephem)
      horizontal = body.observed_by(@observer).horizontal
      horizontal.azimuth
    end

    # Calculate altitude at a specific time
    # @param time [Time] The time to calculate for
    # @return [Object] Altitude angle
    def calculate_altitude(time)
      instant = Instant.from_time(time)
      body = @target_body.new(instant: instant, ephem: @ephem)
      horizontal = body.observed_by(@observer).horizontal
      horizontal.altitude
    end

    # Verify that the event direction is correct (rising vs setting)
    # @param time [Time] The event time to verify
    # @param event_type [Symbol] :rising or :setting
    # @return [Boolean] True if direction is correct
    def confirm_event_direction?(time, event_type)
      # Check altitude rate of change
      t_before = Time.at(time.to_f - EVENT_DIRECTION_CHECK_OFFSET)
      t_after = Time.at(time.to_f + EVENT_DIRECTION_CHECK_OFFSET)

      # Calculate altitudes at before and after times
      altitude_before = calculate_altitude(t_before).radians
      altitude_after = calculate_altitude(t_after).radians

      # Calculate altitude rate (positive = rising, negative = setting)
      term1 = altitude_after - altitude_before
      term2 = 2 * EVENT_DIRECTION_CHECK_OFFSET
      altitude_rate = term1 / term2

      if event_type == :rising
        altitude_rate > 0  # Must be positive for rising
      else
        altitude_rate < 0  # Must be negative for setting
      end
    end

    # Build the appropriate horizon function based on the target body
    # @return [Proc] Function to calculate horizon for a given distance
    def build_horizon_function
      @build_horizon_function ||= case @target_body.name
      when "Astronoby::Sun"
        ->(_distance) { SUN_REFRACTION_ANGLE.radians }
      when "Astronoby::Moon"
        ->(distance) {
          STANDARD_REFRACTION_ANGLE.radians - MOON_RADIUS.m / distance.m
        }
      else
        ->(_distance) { STANDARD_REFRACTION_ANGLE.radians }
      end
    end
  end
end
