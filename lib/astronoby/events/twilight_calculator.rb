# frozen_string_literal: true

module Astronoby
  class TwilightCalculator
    TWILIGHTS = [
      CIVIL = :civil,
      NAUTICAL = :nautical,
      ASTRONOMICAL = :astronomical
    ].freeze

    TWILIGHT_ANGLES = {
      CIVIL => Angle.from_degrees(96),
      NAUTICAL => Angle.from_degrees(102),
      ASTRONOMICAL => Angle.from_degrees(108)
    }.freeze

    PERIODS_OF_THE_DAY = [
      MORNING = :morning,
      EVENING = :evening
    ].freeze

    def initialize(observer:, ephem:)
      @observer = observer
      @ephem = ephem
    end

    def event_on(date, utc_offset: 0)
      start_time = Time
        .new(date.year, date.month, date.day, 0, 0, 0, utc_offset)
      end_time = Time
        .new(date.year, date.month, date.day, 23, 59, 59, utc_offset)
      events = events_between(start_time, end_time)

      TwilightEvent.new(
        morning_civil_twilight_time:
          events.morning_civil_twilight_times.first,
        evening_civil_twilight_time:
          events.evening_civil_twilight_times.first,
        morning_nautical_twilight_time:
          events.morning_nautical_twilight_times.first,
        evening_nautical_twilight_time:
          events.evening_nautical_twilight_times.first,
        morning_astronomical_twilight_time:
          events.morning_astronomical_twilight_times.first,
        evening_astronomical_twilight_time:
          events.evening_astronomical_twilight_times.first
      )
    end

    def events_between(start_time, end_time)
      rts_events = Astronoby::RiseTransitSetCalculator.new(
        body: Sun,
        observer: @observer,
        ephem: @ephem
      ).events_between(start_time, end_time)

      equatorial_by_time = {}

      (rts_events.rising_times + rts_events.setting_times)
        .compact
        .each do |t|
        .each do |event_time|
          rounded_time = event_time.round
          next if equatorial_by_time.key?(rounded_time)

          instant = Instant.from_time(rounded_time)
          sun_at_time = Sun.new(instant: instant, ephem: @ephem)
          equatorial_by_time[rounded_time] = sun_at_time.apparent.equatorial
        end

      morning_civil = []
      evening_civil = []
      morning_nautical = []
      evening_nautical = []
      morning_astronomical = []
      evening_astronomical = []

      rts_events.rising_times.each do |rise_time|
        next unless rise_time
        eq = equatorial_by_time[rise_time.round]
        morning_civil << compute_twilight_time_from(
          MORNING,
          TWILIGHT_ANGLES[CIVIL],
          rise_time,
          eq
        )
        morning_nautical << compute_twilight_time_from(
          MORNING,
          TWILIGHT_ANGLES[NAUTICAL],
          rise_time,
          eq
        )
        morning_astronomical << compute_twilight_time_from(
          MORNING,
          TWILIGHT_ANGLES[ASTRONOMICAL],
          rise_time,
          eq
        )
      end

      rts_events.setting_times.each do |set_time|
        next unless set_time
        eq = equatorial_by_time[set_time.round]
        evening_civil << compute_twilight_time_from(
          EVENING,
          TWILIGHT_ANGLES[CIVIL],
          set_time,
          eq
        )
        evening_nautical << compute_twilight_time_from(
          EVENING,
          TWILIGHT_ANGLES[NAUTICAL],
          set_time,
          eq
        )
        evening_astronomical << compute_twilight_time_from(
          EVENING,
          TWILIGHT_ANGLES[ASTRONOMICAL],
          set_time,
          eq
        )
      end

      within_range = ->(time) { time && time >= start_time && time <= end_time }

      TwilightEvents.new(
        morning_civil.select(&within_range),
        evening_civil.select(&within_range),
        morning_nautical.select(&within_range),
        evening_nautical.select(&within_range),
        morning_astronomical.select(&within_range),
        evening_astronomical.select(&within_range)
      )
    end

    def time_for_zenith_angle(
      date:,
      period_of_the_day:,
      zenith_angle:,
      utc_offset: 0
    )
      unless PERIODS_OF_THE_DAY.include?(period_of_the_day)
        raise IncompatibleArgumentsError,
          "Only #{PERIODS_OF_THE_DAY.join(" or ")} are allowed as period_of_the_day, got #{period_of_the_day}"
      end

      observation_events = get_observation_events(date, utc_offset: utc_offset)
      midday_instant = create_midday_instant(date, utc_offset: utc_offset)
      sun_at_midday = Sun.new(instant: midday_instant, ephem: @ephem)
      equatorial_coordinates = sun_at_midday.apparent.equatorial

      compute_twilight_time(
        period_of_the_day,
        zenith_angle,
        observation_events,
        equatorial_coordinates
      )
    end

    private

    def create_midday_instant(date, utc_offset: 0)
      time = Time.new(date.year, date.month, date.day, 12, 0, 0, utc_offset)
      Instant.from_time(time)
    end

    def get_observation_events(date, utc_offset: 0)
      Astronoby::RiseTransitSetCalculator.new(
        body: Sun,
        observer: @observer,
        ephem: @ephem
      ).event_on(date, utc_offset: utc_offset)
    end

    def compute_twilight_time(
      period_of_the_day,
      zenith_angle,
      observation_events,
      equatorial_coordinates
    )
      period_time = if period_of_the_day == MORNING
        observation_events.rising_time
      else
        observation_events.setting_time
      end

      compute_twilight_time_from(
        period_of_the_day,
        zenith_angle,
        period_time,
        equatorial_coordinates
      )
    end

    def compute_twilight_time_from(
      period_of_the_day,
      zenith_angle,
      period_time,
      equatorial_coordinates
    )
      # If the sun doesn't rise or set on this day, we can't calculate twilight
      return nil unless period_time

      hour_angle_at_period = equatorial_coordinates
        .compute_hour_angle(time: period_time, longitude: @observer.longitude)

      term1 = zenith_angle.cos -
        @observer.latitude.sin * equatorial_coordinates.declination.sin
      term2 = @observer.latitude.cos * equatorial_coordinates.declination.cos
      hour_angle_ratio_at_twilight = term1 / term2

      # Check if twilight occurs at this location and date
      return nil unless hour_angle_ratio_at_twilight.between?(-1, 1)

      hour_angle_at_twilight = Angle.acos(hour_angle_ratio_at_twilight)
      time_sign = -1

      if period_of_the_day == MORNING
        hour_angle_at_twilight = Angle.from_degrees(
          Constants::DEGREES_PER_CIRCLE - hour_angle_at_twilight.degrees
        )
        time_sign = 1
      end

      twilight_in_hours =
        time_sign * (hour_angle_at_twilight - hour_angle_at_period).hours *
        GreenwichSiderealTime::SIDEREAL_MINUTE_IN_UT_MINUTE
      twilight_in_seconds = time_sign *
        twilight_in_hours *
        Constants::SECONDS_PER_HOUR

      (period_time + twilight_in_seconds).round
    end
  end
end
