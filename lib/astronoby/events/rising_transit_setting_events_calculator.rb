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

    SAMPLE_COUNT = 10
    TRANSIT_REFINEMENT_WINDOW_SECONDS = 300
    BINARY_SEARCH_ITERATIONS = 8
    EVENT_DIRECTION_CHECK_OFFSET_SECONDS = 60
    STANDARD_REFRACTION_ANGLE = -Angle.from_dms(0, 34, 0)
    SUN_REFRACTION_ANGLE = -Angle.from_dms(0, 50, 0)
    NORMALIZATION_EPSILON = 1e-10

    def initialize(observer:, target_body:, ephem:)
      @observer = observer
      @target_body = target_body
      @ephem = ephem
    end

    def events_on(date)
      time_range = day_time_range(date)
      sample_times = generate_sample_times(time_range)
      sample_data = sample_times.map { |time| calculate_position(time) }

      events = RisingTransitSettingEvents.new
      find_rising_setting(events, sample_times, sample_data)
      find_transit(events, sample_times, sample_data)
      calculate_event_details(events)

      events
    end

    private

    def day_time_range(date)
      start_time = Time
        .new(date.year, date.month, date.day, 0, 0, 0, @observer.utc_offset)
      end_time = Time
        .new(date.year, date.month, date.day, 23, 59, 59, @observer.utc_offset)
      [start_time, end_time]
    end

    def generate_sample_times(time_range)
      start_time, end_time = time_range
      time_span = end_time - start_time

      SAMPLE_COUNT.times.map do |i|
        fraction = i.to_f / (SAMPLE_COUNT - 1)
        start_time + fraction * time_span
      end
    end

    def calculate_position(time)
      instant = Instant.from_time(time)
      body = @target_body.new(instant: instant, ephem: @ephem)
      topocentric = body.observed_by(@observer)
      horizontal = topocentric.horizontal
      equatorial = topocentric.equatorial
      distance = topocentric.distance
      altitude = horizontal.altitude
      azimuth = horizontal.azimuth

      horizon = calculate_horizon(distance)

      {
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

    def calculate_horizon(distance)
      case @target_body.name
      when "Astronoby::Sun"
        SUN_REFRACTION_ANGLE
      when "Astronoby::Moon"
        Angle.from_radians(
          STANDARD_REFRACTION_ANGLE.radians -
            Moon::EQUATORIAL_RADIUS.m / distance.m
        )
      else
        STANDARD_REFRACTION_ANGLE
      end
    end

    def calculate_azimuth(time)
      instant = Instant.from_time(time)
      body = @target_body.new(instant: instant, ephem: @ephem)
      body.observed_by(@observer).horizontal.azimuth
    end

    def calculate_altitude(time)
      instant = Instant.from_time(time)
      body = @target_body.new(instant: instant, ephem: @ephem)
      body.observed_by(@observer).horizontal.altitude
    end

    def find_rising_setting(events, sample_times, sample_data)
      (0...sample_times.length - 1).each do |i|
        time1, time2 = sample_times[i], sample_times[i + 1]
        data1, data2 = sample_data[i], sample_data[i + 1]

        first_above = data1[:altitude] > data1[:horizon]
        next_above = data2[:altitude] > data2[:horizon]

        if !first_above && next_above && events.rising_time.nil?
          events.rising_time =
            find_precise_crossing(time1, time2, :rising)
        end

        if first_above && !next_above && events.setting_time.nil?
          events.setting_time =
            find_precise_crossing(time1, time2, :setting)
        end
      end
    end

    def find_precise_crossing(t_min, t_max, event_type)
      BINARY_SEARCH_ITERATIONS.times do
        t_mid = Time.at((t_min.to_f + t_max.to_f) / 2.0)
        position = calculate_position(t_mid)

        below_horizon = position[:altitude] < position[:horizon]
        if below_horizon == (event_type == :rising)
          t_min = t_mid
        else
          t_max = t_mid
        end
      end

      crossing_time = interpolate_crossing(t_min, t_max)

      crossing_time.round if confirm_event_direction(crossing_time, event_type)
    end

    def interpolate_crossing(t_min, t_max)
      pos_min = calculate_position(t_min)
      pos_max = calculate_position(t_max)

      relative_min = pos_min[:altitude] - pos_min[:horizon]
      relative_max = pos_max[:altitude] - pos_max[:horizon]

      t_cross = Util::Maths.linear_interpolate(
        t_min.to_f,
        t_max.to_f,
        relative_min.radians,
        relative_max.radians,
        0
      )

      Time.at(t_cross)
    end

    def confirm_event_direction(time, event_type)
      t_before = Time.at(time.to_f - EVENT_DIRECTION_CHECK_OFFSET_SECONDS)
      t_after = Time.at(time.to_f + EVENT_DIRECTION_CHECK_OFFSET_SECONDS)

      altitude_before = calculate_altitude(t_before)
      altitude_after = calculate_altitude(t_after)

      altitude_rate = (altitude_after - altitude_before).radians./(
        2 * EVENT_DIRECTION_CHECK_OFFSET_SECONDS
      )

      (event_type == :rising) ? altitude_rate > 0 : altitude_rate < 0
    end

    def find_transit(events, sample_times, sample_data)
      events.transit_time = find_meridian_crossing(sample_times, sample_data)
      events.transit_time ||= find_altitude_maximum(sample_times, sample_data)
      events.transit_time = events.transit_time.round if events.transit_time
    end

    def find_meridian_crossing(sample_times, sample_data)
      (0...sample_times.length - 1).each do |i|
        time1, time2 = sample_times[i], sample_times[i + 1]
        hour_angle1 = normalize_hour_angle(sample_data[i][:hour_angle])
        hour_angle2 = normalize_hour_angle(sample_data[i + 1][:hour_angle])

        unless hour_angle1 * hour_angle2 <= 0 &&
            (hour_angle1 - hour_angle2).abs < Math::PI
          next
        end

        fraction = hour_angle1.abs / (hour_angle1.abs + hour_angle2.abs)
        approx_time = time1 + fraction * (time2 - time1)

        return refine_transit_time(
          approx_time - TRANSIT_REFINEMENT_WINDOW_SECONDS,
          approx_time + TRANSIT_REFINEMENT_WINDOW_SECONDS
        )
      end

      nil
    end

    # Normalize hour angle to range [-π, π]
    def normalize_hour_angle(hour_angle)
      normalized = hour_angle % (2 * Math::PI)

      if normalized > Math::PI
        normalized -= 2 * Math::PI
      elsif normalized < -Math::PI
        normalized += 2 * Math::PI
      end

      # Handle boundary case with epsilon
      if (normalized.abs - Math::PI).abs < NORMALIZATION_EPSILON
        normalized = if normalized > 0
          Math::PI - NORMALIZATION_EPSILON
        else
          -Math::PI + NORMALIZATION_EPSILON
        end
      end

      normalized
    end

    def refine_transit_time(t_min, t_max)
      BINARY_SEARCH_ITERATIONS.times do
        t_mid = Time.at((t_min.to_f + t_max.to_f) / 2)
        hour_angle = calculate_position(t_mid)[:hour_angle]
        hour_angle = normalize_hour_angle(hour_angle)

        if hour_angle < 0
          # Object hasn't reached meridian yet
          t_min = t_mid
        else
          # Object already passed meridian
          t_max = t_mid
        end
      end

      data_min = calculate_position(t_min)
      data_max = calculate_position(t_max)

      hour_angle_min = normalize_hour_angle(data_min[:hour_angle])
      hour_angle_max = normalize_hour_angle(data_max[:hour_angle])

      fraction = hour_angle_min.abs / (hour_angle_min.abs + hour_angle_max.abs)
      Time.at(t_min.to_f + fraction * (t_max.to_f - t_min.to_f))
    end

    def find_altitude_maximum(sample_times, sample_data)
      altitudes = sample_data.map { |p| p[:altitude] }

      (1...altitudes.length - 1).each do |i|
        unless altitudes[i] > altitudes[i - 1] &&
            altitudes[i] > altitudes[i + 1]
          next
        end

        return Util::Maths.quadratic_maximum(
          sample_times[i - 1],
          sample_times[i],
          sample_times[i + 1],
          altitudes[i - 1],
          altitudes[i],
          altitudes[i + 1]
        )
      end

      nil
    end

    def calculate_event_details(events)
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
  end
end
