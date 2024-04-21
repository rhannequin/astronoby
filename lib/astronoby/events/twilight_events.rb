# frozen_string_literal: true

module Astronoby
  module Events
    class TwilightEvents
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

      attr_reader :morning_civil_twilight_time,
        :evening_civil_twilight_time,
        :morning_nautical_twilight_time,
        :evening_nautical_twilight_time,
        :morning_astronomical_twilight_time,
        :evening_astronomical_twilight_time

      def initialize(observer:, sun:)
        @observer = observer
        @sun = sun
        PERIODS_OF_THE_DAY.each do |period_of_the_day|
          TWILIGHT_ANGLES.each do |twilight, _|
            zenith_angle = TWILIGHT_ANGLES[twilight]
            instance_variable_set(
              :"@#{period_of_the_day}_#{twilight}_twilight_time",
              compute(period_of_the_day, zenith_angle)
            )
          end
        end
      end

      private

      # Source:
      #  Title: Practical Astronomy with your Calculator or Spreadsheet
      #  Authors: Peter Duffett-Smith and Jonathan Zwart
      #  Edition: Cambridge University Press
      #  Chapter: 50 - Twilight
      def compute(period_of_the_day, zenith_angle)
        period_time = if period_of_the_day == MORNING
          observation_events.rising_time
        else
          observation_events.setting_time
        end

        hour_angle_at_period = equatorial_coordinates_at_midday
          .compute_hour_angle(time: period_time, longitude: @observer.longitude)

        term1 = zenith_angle.cos -
          @observer.latitude.sin *
            @equatorial_coordinates_at_midday.declination.sin
        term2 = @observer.latitude.cos *
          equatorial_coordinates_at_midday.declination.cos
        hour_angle_ratio_at_twilight = term1 / term2

        return unless hour_angle_ratio_at_twilight.between?(-1, 1)

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

      def observation_events
        @observation_events ||= @sun.observation_events(observer: @observer)
      end

      def midday
        date = @sun.time.to_date
        Time.utc(date.year, date.month, date.day, 12)
      end

      def sun_at_midday
        Sun.new(time: midday)
      end

      def equatorial_coordinates_at_midday
        @equatorial_coordinates_at_midday ||= sun_at_midday
          .apparent_ecliptic_coordinates
          .to_apparent_equatorial(epoch: Epoch.from_time(midday))
      end
    end
  end
end
