# frozen_string_literal: true

module Astronoby
  class RiseTransitSetCalculator
    class PotentialEvent
      attr_reader :hour_angle, :can_occur

      def initialize(hour_angle, can_occur)
        @hour_angle = hour_angle
        @can_occur = can_occur
      end

      def negated
        self.class.new(-@hour_angle, @can_occur)
      end
    end

    TAU = Math::PI * 2
    SAMPLE_THRESHOLD = 0.8
    REFINEMENT_ITERATIONS = 3
    MIN_TIME_ADJUSTMENT = Constants::MICROSECOND_IN_DAYS
    STANDARD_REFRACTION_ANGLE = -Angle.from_dms(0, 34, 0)
    SUN_REFRACTION_ANGLE = -Angle.from_dms(0, 50, 0)
    EVENT_TYPES = [:rising, :transit, :setting].freeze

    # @param body [Astronoby::SolarSystemBody, Astronoby::DeepSkyObject]
    #   Celestial body for which to calculate events
    # @param observer [Astronoby::Observer] Observer location
    # @param ephem [::Ephem::SPK, nil] Ephemeris data source
    def initialize(body:, observer:, ephem: nil)
      @body = body
      @observer = observer
      @ephem = ephem
    end

    def event_on(date, utc_offset: 0)
      events = events_on(date, utc_offset: utc_offset)
      RiseTransitSetEvent.new(
        events.rising_times.first,
        events.transit_times.first,
        events.setting_times.first
      )
    end

    def events_on(date, utc_offset: 0)
      start_time = Time.new(
        date.year,
        date.month,
        date.day,
        0, 0, 0, utc_offset
      )
      end_time = Time.new(
        date.year,
        date.month,
        date.day,
        23, 59, 59, utc_offset
      )
      events_between(start_time, end_time)
    end

    def events_between(start_time, end_time)
      reset_state
      @start_instant = Instant.from_time(start_time)
      @end_instant = Instant.from_time(end_time)
      events
    end

    private

    def events
      rising_events = calculate_initial_positions.map do |position|
        calculate_rising_event(position)
      end
      setting_events = rising_events.map(&:negated)
      transit_event = PotentialEvent.new(Angle.zero, true)

      event_data = {
        rising: rising_events,
        transit: [transit_event],
        setting: setting_events
      }

      results = EVENT_TYPES.each_with_object({}) do |event_type, results|
        results[event_type] = calculate_event_times(
          event_type,
          event_data[event_type]
        )
      end

      RiseTransitSetEvents.new(
        results[:rising],
        results[:transit],
        results[:setting]
      )
    end

    def calculate_rising_event(position)
      declination = position.equatorial.declination
      latitude = @observer.latitude
      altitude = horizon_angle(position.distance)

      # Calculate the unmodified ratio to check if the body rises/sets
      numerator = altitude.sin - latitude.sin * declination.sin
      denominator = latitude.cos * declination.cos
      ratio = numerator / denominator

      # Determine if the body can rise/set and calculate the hour angle
      can_rise_set = ratio.abs <= 1.0
      angle = can_rise_set ? -Angle.acos(ratio.clamp(-1.0, 1.0)) : Angle.zero

      PotentialEvent.new(angle, can_rise_set)
    end

    def calculate_event_times(event_type, events)
      desired_hour_angles = events.map(&:hour_angle)

      # Calculate differences between current and desired hour angles
      angle_differences = calculate_angle_differences(
        calculate_initial_hour_angles,
        desired_hour_angles
      )

      # Find intervals where the body crosses the desired hour angle
      crossing_indexes = find_crossing_intervals(angle_differences)

      # Skip if no relevant crossing points found
      return [] if crossing_indexes.empty?

      valid_crossings = if events.size == 1
        # For transit (single event), all crossings are valid
        crossing_indexes.map { true }
      else
        # For rise/set, check if each crossing corresponds to a valid event
        crossing_indexes.map { |i| events[i].can_occur }
      end

      old_hour_angles = calculate_initial_hour_angles
        .values_at(*crossing_indexes)
      old_instants = sample_instants.values_at(*crossing_indexes)

      # Initial estimate of event times using linear interpolation
      new_instants = interpolate_initial_times(
        crossing_indexes,
        angle_differences
      )

      # Refine the estimates through iteration
      refined_times = refine_time_estimates(
        event_type,
        new_instants,
        old_hour_angles,
        old_instants
      )

      # Filter out times for bodies that never rise/set
      refined_times
        .zip(valid_crossings)
        .filter_map { |time, valid| time if valid }
    end

    def sample_count
      @sample_count ||=
        ((@end_instant.tt - @start_instant.tt) / SAMPLE_THRESHOLD).ceil + 1
    end

    def sample_instants
      @sample_instants ||= Util::Maths.linspace(
        @start_instant.tt,
        @end_instant.tt,
        sample_count
      ).map { |tt| Instant.from_terrestrial_time(tt) }
    end

    def calculate_initial_positions
      @initial_positions ||= calculate_positions_at_instants(sample_instants)
    end

    def calculate_initial_hour_angles
      @initial_hour_angles ||=
        calculate_hour_angles(calculate_initial_positions)
    end

    def calculate_angle_differences(hour_angles, angles)
      hour_angles.each_with_index.map do |hour_angle, i|
        angle = (angles.size == 1) ? angles[0] : angles[i]
        Angle.from_radians((angle - hour_angle).radians % TAU)
      end
    end

    def find_crossing_intervals(differences)
      differences
        .each_cons(2)
        .map { |a, b| b - a }
        .each_with_index
        .filter_map { |diff, i| i if diff.radians > 0.0 }
    end

    def interpolate_initial_times(crossing_indexes, angle_differences)
      crossing_indexes.map do |index|
        a = angle_differences[index].radians
        b = TAU - angle_differences[index + 1].radians
        c = sample_instants[index].tt
        d = sample_instants[index + 1].tt

        # Linear interpolation formula
        tt = (b * c + a * d) / (a + b)
        Instant.from_terrestrial_time(tt)
      end
    end

    def refine_time_estimates(
      event_type,
      new_instants,
      old_hour_angles,
      old_instants
    )
      REFINEMENT_ITERATIONS.times do |iteration|
        # Calculate positions at current estimates
        apparent_positions = calculate_positions_at_instants(new_instants)

        # Calculate current hour angles
        current_hour_angles = calculate_hour_angles(apparent_positions)

        # Calculate desired hour angles based on current positions
        desired_hour_angles = calculate_desired_hour_angles(
          event_type,
          apparent_positions
        )

        # Calculate hour angle adjustments
        hour_angle_adjustments = calculate_hour_angle_adjustments(
          current_hour_angles,
          desired_hour_angles
        )

        # Calculate hour angle changes for rate determination
        hour_angle_changes = calculate_hour_angle_changes(
          current_hour_angles,
          old_hour_angles,
          iteration
        )

        # Calculate time differences
        time_differences_in_days = new_instants.each_with_index.map do |instant, i|
          instant.tt - old_instants[i].tt
        end

        # Calculate hour angle rate (radians per day)
        hour_angle_rates = hour_angle_changes.each_with_index.map do |angle, i|
          denominator = time_differences_in_days[i]
          angle.radians / denominator
        end

        # Store current values for next iteration
        old_hour_angles = current_hour_angles
        old_instants = new_instants

        # Calculate time adjustments
        time_adjustments = hour_angle_adjustments
          .each_with_index
          .map do |angle, i|
            ratio = angle.radians / hour_angle_rates[i]
            time_adjustment = (ratio.nan? || ratio.infinite?) ? 0 : ratio
            [time_adjustment, MIN_TIME_ADJUSTMENT].max
          end

        # Apply time adjustments
        new_instants = new_instants.each_with_index.map do |instant, i|
          Instant.from_terrestrial_time(instant.tt + time_adjustments[i])
        end
      end

      new_instants.map { _1.to_time.round }
    end

    def calculate_positions_at_instants(instants)
      if Astronoby.configuration.cache_enabled?
        instants.map do |instant|
          cache_key = CacheKey.generate(
            :observed_by,
            instant,
            @body.to_s,
            @observer.hash
          )
          Astronoby.cache.fetch(cache_key) do
            @body
              .at(instant, ephem: @ephem)
              .observed_by(@observer)
          end
        end
      else
        @positions_cache ||= {}
        precision = Astronoby.configuration.cache_precision(:observed_by)
        instants.map do |instant|
          rounded_instant = Instant.from_terrestrial_time(
            instant.tt.round(precision)
          )
          @positions_cache[rounded_instant] ||= @body
            .at(rounded_instant, ephem: @ephem)
            .observed_by(@observer)
        end
      end
    end

    def calculate_hour_angles(positions)
      positions.map do |position|
        position.equatorial.compute_hour_angle(
          time: position.instant.to_time,
          longitude: @observer.longitude
        )
      end
    end

    def calculate_desired_hour_angles(event_type, positions)
      positions.map do |position|
        if event_type == :transit
          Angle.zero
        else
          declination = position.equatorial.declination
          ha = rising_hour_angle(
            @observer.latitude,
            declination,
            horizon_angle(position.distance)
          )
          (event_type == :rising) ? ha : -ha
        end
      end
    end

    def calculate_hour_angle_adjustments(current_angles, angles)
      current_angles.each_with_index.map do |angle, i|
        radians = ((angles[i] - angle).radians + Math::PI) % TAU - Math::PI
        Angle.from_radians(radians)
      end
    end

    def calculate_hour_angle_changes(current_angles, old_angles, iteration)
      current_angles.each_with_index.map do |angle, i|
        radians = angle.radians - old_angles[i].radians

        if iteration == 0
          radians %= TAU
        else
          radians = (radians + Math::PI) % TAU - Math::PI
        end

        Angle.from_radians(radians)
      end
    end

    def rising_hour_angle(latitude, declination, altitude)
      numerator = altitude.sin - latitude.sin * declination.sin
      denominator = latitude.cos * declination.cos
      ratio = (numerator / denominator).clamp(-1.0, 1.0)
      -Angle.acos(ratio)
    end

    def horizon_angle(distance)
      if @body == Astronoby::Sun
        SUN_REFRACTION_ANGLE
      elsif @body == Astronoby::Moon
        STANDARD_REFRACTION_ANGLE -
          Angle.from_radians(Moon::EQUATORIAL_RADIUS.m / distance.m)
      else
        STANDARD_REFRACTION_ANGLE
      end
    end

    def reset_state
      @initial_hour_angles = nil
      @initial_positions = nil
      @sample_count = nil
      @sample_instants = nil
      @start_instant = nil
      @end_instant = nil
      @positions_cache = nil
    end
  end
end
