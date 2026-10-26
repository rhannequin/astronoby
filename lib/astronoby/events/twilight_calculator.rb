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
      @crossing_calculator = AltitudeCrossingCalculator.new(
        body: Sun,
        observer: observer,
        ephem: ephem
      )
    end

    def event_on(date, utc_offset: 0)
      start_time = Time
        .new(date.year, date.month, date.day, 0, 0, 0, utc_offset)
      following = date.next_day
      end_time = Time.new(
        following.year, following.month, following.day,
        0, 0, 0,
        utc_offset
      ) - 1e-6
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
      crossings = @crossing_calculator.multiple_crossings_between(
        start_time,
        end_time,
        altitudes: TWILIGHT_ANGLES.values.map { |angle| altitude_for(angle) }
      )
      times = TWILIGHT_ANGLES.keys.zip(crossings).to_h do |twilight, found|
        [twilight, [:rising, :setting].map do |direction|
          found
            .select { |crossing| crossing.direction == direction }
            .map { |crossing| crossing.instant.to_time.round }
        end]
      end

      TwilightEvents.new(
        times[CIVIL][0],
        times[CIVIL][1],
        times[NAUTICAL][0],
        times[NAUTICAL][1],
        times[ASTRONOMICAL][0],
        times[ASTRONOMICAL][1]
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
          "Only #{PERIODS_OF_THE_DAY.join(" or ")} are allowed as " \
          "period_of_the_day, got #{period_of_the_day}"
      end

      crossing = @crossing_calculator.crossing_on(
        date,
        altitude: altitude_for(zenith_angle),
        direction: (period_of_the_day == MORNING) ? :rising : :setting,
        utc_offset: utc_offset
      )

      crossing&.instant&.to_time&.round
    end

    private

    def altitude_for(zenith_angle)
      Angle.from_degrees(90) - zenith_angle
    end
  end
end
