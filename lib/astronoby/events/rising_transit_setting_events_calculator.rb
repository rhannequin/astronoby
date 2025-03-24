# frozen_string_literal: true

module Astronoby
  class RisingTransitSettingEventsCalculator
    class RisingTransitSettingEvents
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
    end

    # Encapsulates a time series of sky positions for a celestial body
    class PositionSeries
      attr_reader :times, :positions

      def initialize(times, positions)
        @times = times
        @positions = positions
        freeze
      end

      # Iterates through each time and position pair
      def each_pair
        @times.zip(@positions).each do |time, position|
          yield time, position
        end
      end

      # Iterates through consecutive pairs of time and position
      def each_consecutive_pair
        (0...@times.length - 1).each do |i|
          yield @times[i], @positions[i], @times[i + 1], @positions[i + 1]
        end
      end

      # Access data by index
      def [](index)
        {time: @times[index], position: @positions[index]}
      end

      # Returns altitudes in the series
      def altitudes
        @positions.map { |p| p[:altitude] }
      end

      # Returns hour angles in the series
      def hour_angles
        @positions.map { |p| p[:hour_angle] }
      end

      def size
        @times.length
      end
    end

    # Handles horizon calculations for different celestial bodies
    class HorizonCalculator
      STANDARD_REFRACTION_ANGLE = Angle.from_dms(0, -34, 0)
      SUN_REFRACTION_ANGLE = Angle.from_dms(0, -50, 0)

      def initialize(target_body)
        @target_body = target_body
      end

      # @param distance [Distance] Distance to the celestial body
      # @return [Float] Horizon angle in radians
      def calculate(distance)
        case @target_body.name
        when "Astronoby::Sun"
          SUN_REFRACTION_ANGLE.radians
        when "Astronoby::Moon"
          STANDARD_REFRACTION_ANGLE.radians -
            Moon::EQUATORIAL_RADIUS.m / distance.m
        else
          STANDARD_REFRACTION_ANGLE.radians
        end
      end
    end

    # Handles position calculations
    class PositionCalculator
      # @param observer [Astronoby::Observer] The observer's location
      # @param target_body [Astronoby::SolarSystemBody] Celestial body
      # @param ephem [Ephem::SPK] The ephemeris data source
      def initialize(observer:, target_body:, ephem:)
        @observer = observer
        @target_body = target_body
        @ephem = ephem
        @horizon_calculator = HorizonCalculator.new(target_body)
      end

      # Calculate position data at a specific time
      # @param time [Time] The time to calculate for
      # @return [Hash] Sky position data
      def calculate(time)
        instant = Instant.from_time(time)

        @target_body.new(instant: instant, ephem: @ephem).tap do |body|
          topocentric = body.observed_by(@observer)
          horizontal = topocentric.horizontal
          equatorial = topocentric.equatorial
          distance = topocentric.distance
          altitude = horizontal.altitude.radians
          azimuth = horizontal.azimuth.radians
          horizon = @horizon_calculator.calculate(distance)

          return {
            time: time,
            altitude: altitude,
            azimuth: azimuth,
            hour_angle: equatorial.compute_hour_angle(
              time: time,
              longitude: @observer.longitude
            ).radians,
            horizon: horizon,
            above_horizon: altitude > horizon
          }
        end
      rescue => e
        raise CalculationError, "Failed to calculate sky position: #{e.message}"
      end

      # Calculate azimuth at a specific time
      # @param time [Time] The time to calculate for
      # @return [Astronoby::Angle] Azimuth angle
      def calculate_azimuth(time)
        instant = Instant.from_time(time)
        body = @target_body.new(instant: instant, ephem: @ephem)
        body.observed_by(@observer).horizontal.azimuth
      end

      # Calculate altitude at a specific time
      # @param time [Time] The time to calculate for
      # @return [Astronoby::Angle] Altitude angle
      def calculate_altitude(time)
        instant = Instant.from_time(time)
        body = @target_body.new(instant: instant, ephem: @ephem)
        body.observed_by(@observer).horizontal.altitude
      end
    end

    # Handles the search for transit times (meridian crossing or maximum
    # altitude)
    class TransitFinder
      TRANSIT_REFINEMENT_WINDOW = 300  # seconds
      BINARY_SEARCH_ITERATIONS = 8

      # @param position_calculator [PositionCalculator] Calculator for positions
      # @param observer [Astronoby::Observer] The observer's location
      def initialize(position_calculator:, observer:)
        @position_calculator = position_calculator
        @observer = observer
      end

      # Find the transit time using multiple methods
      # @param position_series [PositionSeries] Time series of sky positions
      # @return [Time, nil] Transit time or nil if not found
      def find_transit_time(position_series)
        # Try meridian crossing first
        transit_candidate = find_meridian_crossings(position_series)

        # Fall back to altitude maxima if needed
        transit_candidate || find_altitude_maxima(position_series)
      end

      private

      # Find times when the body crosses the meridian (hour angle = 0)
      # @param position_series [PositionSeries] Time series of sky positions
      # @return [Time, nil] Candidate transit time
      def find_meridian_crossings(position_series)
        position_series.each_consecutive_pair do |time1, data1, time2, data2|
          # Extract and normalize hour angles to [-π, π]
          hour_angle1 = normalize_hour_angle(data1[:hour_angle])
          hour_angle2 = normalize_hour_angle(data2[:hour_angle])

          # Check if it crosses zero (sign change) without wrapping around the
          # full circle
          unless hour_angle1 * hour_angle2 <= 0 &&
              (hour_angle1 - hour_angle2).abs < Math::PI
            next
          end

          # Interpolate to find approximate crossing
          fraction = hour_angle1.abs / (hour_angle1.abs + hour_angle2.abs)
          approx_time = time1 + fraction * (time2 - time1)

          # Refine with binary search
          return refine_transit_time(
            approx_time - TRANSIT_REFINEMENT_WINDOW,
            approx_time + TRANSIT_REFINEMENT_WINDOW
          )
        end

        nil
      end

      # Find times of maximum altitude (potential transits)
      # @param position_series [PositionSeries] Time series of sky positions
      # @return [Time, nil] Candidate transit time based on altitude maxima
      def find_altitude_maxima(position_series)
        # Extract altitudes
        altitudes = position_series.altitudes

        # Look for local maxima
        (1...altitudes.length - 1).each do |i|
          unless altitudes[i] > altitudes[i - 1] &&
              altitudes[i] > altitudes[i + 1]
            next
          end

          # Local maximum found, refine it with quadratic interpolation
          return Util::Maths.quadratic_maximum(
            position_series.times[i - 1],
            position_series.times[i],
            position_series.times[i + 1],
            altitudes[i - 1],
            altitudes[i],
            altitudes[i + 1]
          )
        end

        nil
      end

      # Binary search to find exact transit (hour angle = 0)
      # @param t_min [Time] Lower bound time
      # @param t_max [Time] Upper bound time
      # @return [Time] Precise transit time
      def refine_transit_time(t_min, t_max)
        BINARY_SEARCH_ITERATIONS.times do
          t_mid = Time.at((t_min.to_f + t_max.to_f) / 2)
          hour_angle = @position_calculator.calculate(t_mid)[:hour_angle]
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
        data_min = @position_calculator.calculate(t_min)
        data_max = @position_calculator.calculate(t_max)

        hour_angle_min = normalize_hour_angle(data_min[:hour_angle])
        hour_angle_max = normalize_hour_angle(data_max[:hour_angle])

        # Linear interpolation for zero crossing
        fraction = hour_angle_min.abs / (
          hour_angle_min.abs + hour_angle_max.abs
        )
        Time.at(t_min.to_f + fraction * (t_max.to_f - t_min.to_f))
      end

      private

      def normalize_hour_angle(hour_angle)
        ((hour_angle + Math::PI) % Constants::RADIANS_PER_CIRCLE) - Math::PI
      end
    end

    # Handles the search for horizon crossings (rising and setting)
    class HorizonCrossingFinder
      EVENT_DIRECTION_CHECK_OFFSET = 60  # seconds
      BINARY_SEARCH_ITERATIONS = 8

      # @param position_calculator [PositionCalculator] Calculator for sky
      #   positions
      def initialize(position_calculator:)
        @position_calculator = position_calculator
      end

      # Find horizon crossings (rising or setting)
      # @param position_series [PositionSeries] Time series of sky positions
      # @param event_type [Symbol] :rising or :setting
      # @return [Time, nil] Event time
      def find_crossing(position_series, event_type)
        position_series.each_consecutive_pair do |time1, data1, time2, data2|
          first_above = data1[:altitude] > data1[:horizon]
          next_above = data2[:altitude] > data2[:horizon]

          # Check for the correct crossing pattern
          if !((event_type == :rising && !first_above && next_above) ||
            (event_type == :setting && first_above && !next_above))
            next
          end

          crossing_time = binary_search_crossing(
            time1,
            time2,
            event_type
          )

          if confirm_event_direction?(crossing_time, event_type)
            return crossing_time
          end
        end

        nil
      end

      private

      # Binary search to find horizon crossing with high precision
      # @param t_min [Time] Lower bound time
      # @param t_max [Time] Upper bound time
      # @param event_type [Symbol] :rising or :setting
      # @return [Time] Precise crossing time
      def binary_search_crossing(t_min, t_max, event_type)
        # Use iterative binary search for precision
        BINARY_SEARCH_ITERATIONS.times do
          t_mid = Time.at((t_min.to_f + t_max.to_f) / 2.0)
          position = @position_calculator.calculate(t_mid)

          below_horizon = position[:altitude] < position[:horizon]
          if below_horizon == (event_type == :rising)
            t_min = t_mid
          else
            t_max = t_mid
          end
        end

        # Final interpolation
        interpolate_crossing(t_min, t_max)
      end

      # Interpolate crossing time between two close times
      # @param t_min [Time] Time before crossing
      # @param t_max [Time] Time after crossing
      # @return [Time] Interpolated crossing time
      def interpolate_crossing(t_min, t_max)
        pos_min = @position_calculator.calculate(t_min)
        pos_max = @position_calculator.calculate(t_max)

        # Calculate altitude relative to horizon
        relative_min = pos_min[:altitude] - pos_min[:horizon]
        relative_max = pos_max[:altitude] - pos_max[:horizon]

        # Linear interpolation to find exact crossing
        t_cross = Util::Maths.linear_interpolate(
          t_min.to_f, t_max.to_f,
          relative_min, relative_max
        )

        Time.at(t_cross)
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
        altitude_before = @position_calculator
          .calculate_altitude(t_before)
          .radians
        altitude_after = @position_calculator
          .calculate_altitude(t_after)
          .radians

        # Calculate altitude rate (positive = rising, negative = setting)
        term1 = altitude_after - altitude_before
        term2 = 2 * EVENT_DIRECTION_CHECK_OFFSET
        altitude_rate = term1 / term2

        (event_type == :rising) ? altitude_rate > 0 : altitude_rate < 0
      end
    end

    SAMPLE_COUNT = 10

    # @param observer [Astronoby::Observer] The observer's location
    # @param target_body [Astronoby::SolarSystemBody] Celestial body class
    # @param ephem [Ephem::SPK] The ephemeris data source
    def initialize(observer:, target_body:, ephem:)
      @observer = observer
      @target_body = target_body

      @position_calculator = PositionCalculator.new(
        observer: observer,
        target_body: target_body,
        ephem: ephem
      )

      @transit_finder = TransitFinder.new(
        position_calculator: @position_calculator,
        observer: observer
      )

      @horizon_finder = HorizonCrossingFinder.new(
        position_calculator: @position_calculator
      )
    end

    # Calculate all events (rising, transit, setting) for a given date
    # @param date [Date] The date to calculate events for
    # @return [RisingTransitSettingEvents] Object containing all calculated
    #   events
    def calculate_events(date)
      @date = date
      @time_range = compute_time_range(date)

      sample_times = generate_sample_times
      sample_data = collect_sample_data(sample_times)

      # Create a sky position series instead of passing arrays separately
      position_series = PositionSeries.new(sample_times, sample_data)

      events = RisingTransitSettingEvents.new
      populate_event_times(events, position_series)
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
      time_span = end_time - start_time

      SAMPLE_COUNT.times.map do |i|
        fraction = i.to_f / (SAMPLE_COUNT - 1)
        start_time + fraction * time_span
      end
    end

    # Collects sky position data for each sample time
    # @param sample_times [Array<Time>] The times to collect data for
    # @return [Array<Hash>] Position data for each time
    def collect_sample_data(sample_times)
      sample_times.map { |time| @position_calculator.calculate(time) }
    end

    # Populates the rising, transit, and setting times
    # @param events [RisingTransitSettingEvents] The events object to populate
    # @param position_series [PositionSeries] Time series of sky positions
    def populate_event_times(events, position_series)
      events.rising_time = @horizon_finder.find_crossing(
        position_series, :rising
      )&.round

      events.transit_time = @transit_finder.find_transit_time(
        position_series
      )&.round

      events.setting_time = @horizon_finder.find_crossing(
        position_series, :setting
      )&.round
    end

    # Calculates additional data points (azimuths and altitudes) for found event
    # times
    # @param events [RisingTransitSettingEvents] The events object to populate
    def calculate_additional_data(events)
      if events.rising_time
        events.rising_azimuth =
          @position_calculator.calculate_azimuth(events.rising_time)
      end

      if events.transit_time
        events.transit_altitude =
          @position_calculator.calculate_altitude(events.transit_time)
      end

      if events.setting_time
        events.setting_azimuth =
          @position_calculator.calculate_azimuth(events.setting_time)
      end
    end
  end
end
