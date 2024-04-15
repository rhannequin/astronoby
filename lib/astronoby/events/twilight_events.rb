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
            compute(period_of_the_day, twilight)
          end
        end
      end

      private

      # Source:
      #  Title: Practical Astronomy with your Calculator or Spreadsheet
      #  Authors: Peter Duffett-Smith and Jonathan Zwart
      #  Edition: Cambridge University Press
      #  Chapter: 50 - Twilight
      def compute(period_of_the_day, twilight)
        period_time = if period_of_the_day == MORNING
          observation_events.rising_time
        else
          observation_events.setting_time
        end

        hour_angle_at_period = equatorial_coordinates_at_midday
          .compute_hour_angle(time: period_time, longitude: @observer.longitude)

        zenith_angle = TWILIGHT_ANGLES[twilight]

        term1 = zenith_angle.cos -
          @observer.latitude.sin *
            @equatorial_coordinates_at_midday.declination.sin
        term2 = @observer.latitude.cos *
          equatorial_coordinates_at_midday.declination.cos
        hour_angle_ratio_at_twilight = term1 / term2

        unless hour_angle_ratio_at_twilight.between?(-1, 1)
          return instance_variable_set(
            :"@#{period_of_the_day}_#{twilight}_twilight_time",
            nil
          )
        end

        hour_angle_at_twilight = Angle.acos(hour_angle_ratio_at_twilight)
        time_sign = -1

        if period_of_the_day == MORNING
          hour_angle_at_twilight =
            Angle.from_degrees(360 - hour_angle_at_twilight.degrees)
          time_sign = 1
        end

        twilight_in_hours =
          time_sign * (hour_angle_at_twilight - hour_angle_at_period).hours *
          GreenwichSiderealTime::SIDEREAL_MINUTE_IN_UT_MINUTE
        twilight_in_seconds = time_sign * twilight_in_hours * 3600

        instance_variable_set(
          :"@#{period_of_the_day}_#{twilight}_twilight_time",
          (period_time + twilight_in_seconds).round
        )
      end

      def observation_events
        @observation_events ||= @sun.observation_events(observer: @observer)
      end

      def midday
        utc_from_epoch = Epoch.to_utc(@sun.epoch)
        Time.utc(
          utc_from_epoch.year,
          utc_from_epoch.month,
          utc_from_epoch.day,
          12
        )
      end

      def equatorial_coordinates_at_midday
        @equatorial_coordinates_at_midday ||=
          @sun.apparent_ecliptic_coordinates
            .to_apparent_equatorial(epoch: Epoch.from_time(midday))
      end
    end
  end
end
