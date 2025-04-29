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

    def event_on(date)
      observation_events = get_observation_events(date)
      midday_instant = create_midday_instant(date)
      sun_at_midday = Sun.new(instant: midday_instant, ephem: @ephem)
      equatorial_coordinates = sun_at_midday.apparent.equatorial

      morning_civil = compute_twilight_time(
        MORNING,
        TWILIGHT_ANGLES[CIVIL],
        observation_events,
        equatorial_coordinates
      )

      evening_civil = compute_twilight_time(
        EVENING,
        TWILIGHT_ANGLES[CIVIL],
        observation_events,
        equatorial_coordinates
      )

      morning_nautical = compute_twilight_time(
        MORNING,
        TWILIGHT_ANGLES[NAUTICAL],
        observation_events,
        equatorial_coordinates
      )

      evening_nautical = compute_twilight_time(
        EVENING,
        TWILIGHT_ANGLES[NAUTICAL],
        observation_events,
        equatorial_coordinates
      )

      morning_astronomical = compute_twilight_time(
        MORNING,
        TWILIGHT_ANGLES[ASTRONOMICAL],
        observation_events,
        equatorial_coordinates
      )

      evening_astronomical = compute_twilight_time(
        EVENING,
        TWILIGHT_ANGLES[ASTRONOMICAL],
        observation_events,
        equatorial_coordinates
      )

      TwilightEvent.new(
        morning_civil_twilight_time: morning_civil,
        evening_civil_twilight_time: evening_civil,
        morning_nautical_twilight_time: morning_nautical,
        evening_nautical_twilight_time: evening_nautical,
        morning_astronomical_twilight_time: morning_astronomical,
        evening_astronomical_twilight_time: evening_astronomical
      )
    end

    def time_for_zenith_angle(date:, period_of_the_day:, zenith_angle:)
      unless PERIODS_OF_THE_DAY.include?(period_of_the_day)
        raise IncompatibleArgumentsError,
          "Only #{PERIODS_OF_THE_DAY.join(" or ")} are allowed as period_of_the_day, got #{period_of_the_day}"
      end

      observation_events = get_observation_events(date)
      midday_instant = create_midday_instant(date)
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

    def create_midday_instant(date)
      time = Time.utc(date.year, date.month, date.day, 12)
      Instant.from_time(time)
    end

    def get_observation_events(date)
      Astronoby::RiseTransitSetCalculator.new(
        body: Sun,
        observer: @observer,
        ephem: @ephem
      ).event_on(date)
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

      # If the sun doesn't rise or set on this day, we can't calculate
      # twilight
      return nil unless period_time

      # Calculate the hour angle at rise/set
      hour_angle_at_period = equatorial_coordinates
        .compute_hour_angle(time: period_time, longitude: @observer.longitude)

      # Calculate the hour angle at the desired zenith angle
      term1 = zenith_angle.cos -
        @observer.latitude.sin *
          equatorial_coordinates.declination.sin
      term2 = @observer.latitude.cos *
        equatorial_coordinates.declination.cos
      hour_angle_ratio_at_twilight = term1 / term2

      # Check if twilight occurs at this location and date
      return nil unless hour_angle_ratio_at_twilight.between?(-1, 1)

      # Calculate the hour angle difference
      hour_angle_at_twilight = Angle.acos(hour_angle_ratio_at_twilight)
      time_sign = -1

      if period_of_the_day == MORNING
        hour_angle_at_twilight = Angle.from_degrees(
          Constants::DEGREES_PER_CIRCLE - hour_angle_at_twilight.degrees
        )
        time_sign = 1
      end

      # Convert the angle difference to time
      twilight_in_hours =
        time_sign * (hour_angle_at_twilight - hour_angle_at_period).hours *
        GreenwichSiderealTime::SIDEREAL_MINUTE_IN_UT_MINUTE
      twilight_in_seconds = time_sign *
        twilight_in_hours *
        Constants::SECONDS_PER_HOUR

      # Calculate the final time
      (period_time + twilight_in_seconds).round
    end
  end
end
