# frozen_string_literal: true

module Astronoby
  module Events
    class ObservationEvents
      STANDARD_ALTITUDE = Angle.from_dms(0, -34, 0)
      RISING_SETTING_HOUR_ANGLE_RATIO_RANGE = (-1..1)
      EARTH_SIDEREAL_ROTATION_RATE = 360.98564736629
      ITERATION_PRECISION = 0.0001
      ITERATION_LIMIT = 5

      attr_reader :rising_time,
        :rising_azimuth,
        :transit_time,
        :transit_altitude,
        :setting_time,
        :setting_azimuth

      # Source:
      #  Title: Astronomical Algorithms
      #  Author: Jean Meeus
      #  Edition: 2nd edition
      #  Chapter: 15 - Rising, Transit, and Setting

      # @param observer [Astronoby::Observer] Observer
      # @param date [Date] Date of the event
      # @param coordinates_of_the_previous_day [Astronoby::Coordinates::Equatorial]
      #   Coordinates of the body of the previous day
      # @param coordinates_of_the_day [Astronoby::Coordinates::Equatorial]
      #   Coordinates of the body of the day
      # @param coordinates_of_the_next_day [Astronoby::Coordinates::Equatorial]
      #   Coordinates of the body of the next day
      # @param additional_altitude [Astronoby::Angle] Additional altitude to the
      #   standard altitude adjustment
      def initialize(
        observer:,
        date:,
        coordinates_of_the_previous_day:,
        coordinates_of_the_day:,
        coordinates_of_the_next_day:,
        additional_altitude: Angle.zero
      )
        @observer = observer
        @date = date
        @coordinates_of_the_previous_day = coordinates_of_the_previous_day
        @coordinates_of_the_day = coordinates_of_the_day
        @coordinates_of_the_next_day = coordinates_of_the_next_day
        @standard_altitude = STANDARD_ALTITUDE
        @additional_altitude = additional_altitude
        compute
      end

      private

      def compute
        @initial_transit = initial_transit
        @transit_time = Util::Time.decimal_hour_to_time(@date, @initial_transit)
        @transit_altitude = local_horizontal_altitude_transit

        return if h0.nil?

        initial_rising = rationalize_decimal_time(
          @initial_transit - h0.degrees / Constants::DEGREES_PER_CIRCLE
        )

        initial_setting = rationalize_decimal_time(
          @initial_transit + h0.degrees / Constants::DEGREES_PER_CIRCLE
        )

        @final_rising, @final_transit, @final_setting =
          iterate(initial_rising, @initial_transit, initial_setting)

        rationalized_corrected_rising = rationalize_decimal_hours(
          Constants::HOURS_PER_DAY * @final_rising
        )
        rationalized_corrected_transit = rationalize_decimal_hours(
          Constants::HOURS_PER_DAY * @final_transit
        )
        rationalized_corrected_setting = rationalize_decimal_hours(
          Constants::HOURS_PER_DAY * @final_setting
        )

        @rising_time = Util::Time.decimal_hour_to_time(@date, rationalized_corrected_rising)
        @rising_azimuth = local_horizontal_azimuth_rising
        @transit_time = Util::Time.decimal_hour_to_time(@date, rationalized_corrected_transit)
        @transit_altitude = local_horizontal_altitude_transit
        @setting_time = Util::Time.decimal_hour_to_time(@date, rationalized_corrected_setting)
        @setting_azimuth = local_horizontal_azimuth_setting
      end

      def iterate(initial_rising, initial_transit, initial_setting)
        delta = 1
        iteration = 1
        corrected_rising = initial_rising
        corrected_transit = initial_transit
        corrected_setting = initial_setting
        until delta < ITERATION_PRECISION || iteration > ITERATION_LIMIT
          iterate = RiseTransitSetIteration.new(
            observer: @observer,
            date: @date,
            coordinates_of_the_next_day: @coordinates_of_the_next_day,
            coordinates_of_the_day: @coordinates_of_the_day,
            coordinates_of_the_previous_day: @coordinates_of_the_previous_day,
            shift: shift,
            initial_rising: corrected_rising,
            initial_transit: corrected_transit,
            initial_setting: corrected_setting
          ).iterate
          delta = iterate.sum
          corrected_rising = rationalize_decimal_time corrected_rising + iterate[0]
          corrected_transit = rationalize_decimal_time corrected_transit + iterate[1]
          corrected_setting = rationalize_decimal_time corrected_setting + iterate[2]
          iteration += 1
        end
        [corrected_rising, corrected_transit, corrected_setting]
      end

      def observer_longitude
        # Longitude must be treated positively westwards from the meridian of
        # Greenwich, and negatively to the east
        -@observer.longitude
      end

      def initial_transit
        rationalize_decimal_time(
          (
            @coordinates_of_the_day.right_ascension.degrees +
              observer_longitude.degrees -
              apparent_gst_at_midnight.degrees
          ) / Constants::DEGREES_PER_CIRCLE
        )
      end

      def h0
        @h0 ||= begin
          term1 = shift.sin -
            @observer.latitude.sin * @coordinates_of_the_day.declination.sin
          term2 = @observer.latitude.cos * @coordinates_of_the_day.declination.cos
          ratio = term1 / term2
          return nil unless RISING_SETTING_HOUR_ANGLE_RATIO_RANGE.cover?(ratio)

          Angle.acos(ratio)
        end
      end

      def apparent_gst_at_midnight
        Angle.from_hours(
          GreenwichSiderealTime.from_utc(
            Time.utc(@date.year, @date.month, @date.day)
          ).time
        )
      end

      def gst_transit
        Angle.from_degrees(
          apparent_gst_at_midnight.degrees +
            EARTH_SIDEREAL_ROTATION_RATE * (@final_transit || @initial_transit)
        )
      end

      def leap_day_portion
        leap_seconds = Util::Time.terrestrial_universal_time_delta(@date)
        leap_seconds / Constants::SECONDS_PER_DAY
      end

      def local_hour_angle_transit
        gst_transit - observer_longitude - right_ascension_transit
      end

      def local_horizontal_azimuth_rising
        term1 = declination_rising.sin + (-shift).sin * @observer.latitude.cos
        term2 = (-shift).cos * @observer.latitude.cos
        angle = term1 / term2
        Angle.acos(angle)
      end

      def local_horizontal_altitude_transit
        Angle.asin(
          @observer.latitude.sin * declination_transit.sin +
            @observer.latitude.cos * declination_transit.cos * local_hour_angle_transit.cos
        )
      end

      def local_horizontal_azimuth_setting
        term1 = declination_setting.sin + (-shift).sin * @observer.latitude.cos
        term2 = (-shift).cos * @observer.latitude.cos
        angle = term1 / term2
        Angle.from_degrees(
          Constants::DEGREES_PER_CIRCLE - Angle.acos(angle).degrees
        )
      end

      def rationalize_decimal_time(decimal_time)
        decimal_time += 1 if decimal_time.negative?
        decimal_time -= 1 if decimal_time > 1
        decimal_time
      end

      def rationalize_decimal_hours(decimal_hours)
        decimal_hours += Constants::HOURS_PER_DAY if decimal_hours.negative?
        decimal_hours -= Constants::HOURS_PER_DAY if decimal_hours > Constants::HOURS_PER_DAY
        decimal_hours
      end

      def right_ascension_transit
        Angle.from_degrees(
          Util::Maths.interpolate(
            [
              @coordinates_of_the_previous_day.right_ascension.degrees,
              @coordinates_of_the_day.right_ascension.degrees,
              @coordinates_of_the_next_day.right_ascension.degrees
            ],
            (@final_transit || @initial_transit) + leap_day_portion
          )
        )
      end

      def declination_rising
        Angle.from_degrees(
          Util::Maths.interpolate(
            [
              @coordinates_of_the_previous_day.declination.degrees,
              @coordinates_of_the_day.declination.degrees,
              @coordinates_of_the_next_day.declination.degrees
            ],
            @final_rising + leap_day_portion
          )
        )
      end

      def declination_transit
        Angle.from_degrees(
          Util::Maths.interpolate(
            [
              @coordinates_of_the_previous_day.declination.degrees,
              @coordinates_of_the_day.declination.degrees,
              @coordinates_of_the_next_day.declination.degrees
            ],
            (@final_transit || @initial_transit) + leap_day_portion
          )
        )
      end

      def declination_setting
        Angle.from_degrees(
          Util::Maths.interpolate(
            [
              @coordinates_of_the_previous_day.declination.degrees,
              @coordinates_of_the_day.declination.degrees,
              @coordinates_of_the_next_day.declination.degrees
            ],
            @final_setting + leap_day_portion
          )
        )
      end

      def shift
        @standard_altitude - @additional_altitude
      end
    end
  end
end
