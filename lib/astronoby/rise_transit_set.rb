# frozen_string_literal: true

module Astronoby
  class RiseTransitSet
    STANDARD_ALTITUDE = Angle.from_dms(0, -34, 0)
    RISING_SETTING_HOUR_ANGLE_RATIO_RANGE = (-1..1)
    SECONDS_IN_A_DAY = 86_400
    EARTH_SIDEREAL_ROTATION_RATE = 360.98564736629

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
    # @param standard_altitude [Astronoby::Angle] Standard altitude adjustment
    # @return [Array<Time, Time, Time>] Rising, transit, and setting times
    def compute(
      observer:,
      date:,
      coordinates_of_the_previous_day:,
      coordinates_of_the_day:,
      coordinates_of_the_next_day:,
      standard_altitude: STANDARD_ALTITUDE
    )
      # Longitude must be treated positively westwards from the meridian of
      # Greenwich, and negatively to the east
      observer_longitude = Angle.from_degrees(-1 * observer.longitude.degrees)

      term1 = standard_altitude.sin -
        observer.latitude.sin * coordinates_of_the_day.declination.sin
      term2 = observer.latitude.cos * coordinates_of_the_day.declination.cos
      ratio = term1 / term2
      return nil unless RISING_SETTING_HOUR_ANGLE_RATIO_RANGE.cover?(ratio)

      h0 = Angle.acos(ratio)

      apparent_gst_at_midnight = Angle.from_hours(
        GreenwichSiderealTime.from_utc(
          Time.utc(date.year, date.month, date.day)
        ).time
      )

      initial_transit = rationalize_decimal_time(
        (
          coordinates_of_the_day.right_ascension.degrees +
            observer_longitude.degrees -
            apparent_gst_at_midnight.degrees
        ) / 360.0
      )
      initial_rising = rationalize_decimal_time(
        initial_transit - h0.degrees / 360
      )
      initial_setting = rationalize_decimal_time(
        initial_transit + h0.degrees / 360
      )

      gst_rising = Angle.from_degrees(
        apparent_gst_at_midnight.degrees +
          EARTH_SIDEREAL_ROTATION_RATE * initial_rising
      )
      gst_transit = Angle.from_degrees(
        apparent_gst_at_midnight.degrees +
          EARTH_SIDEREAL_ROTATION_RATE * initial_transit
      )
      gst_setting = Angle.from_degrees(
        apparent_gst_at_midnight.degrees +
          EARTH_SIDEREAL_ROTATION_RATE * initial_setting
      )

      leap_seconds = Util::Time.leap_seconds_for(date)
      leap_day_portion = leap_seconds / SECONDS_IN_A_DAY

      right_ascension_rising,
         right_ascension_transit,
         right_ascension_setting,
         declination_rising,
         declination_setting = computed_coordinates(
           coordinates_of_the_previous_day,
           coordinates_of_the_day,
           coordinates_of_the_next_day,
           initial_rising + leap_day_portion,
           initial_transit + leap_day_portion,
           initial_setting + leap_day_portion
         )

      local_hour_angle_rising =
        gst_rising - observer_longitude - right_ascension_rising

      local_hour_angle_transit =
        gst_transit - observer_longitude - right_ascension_transit

      local_hour_angle_setting =
        gst_setting - observer_longitude - right_ascension_setting

      local_horizontal_altitude_rising = Angle.asin(
        observer.latitude.sin * declination_rising.sin +
          observer.latitude.cos * declination_rising.cos * local_hour_angle_rising.cos
      )
      local_horizontal_altitude_setting = Angle.asin(
        observer.latitude.sin * declination_setting.sin +
          observer.latitude.cos * declination_setting.cos * local_hour_angle_setting.cos
      )

      delta_m_rising = (local_horizontal_altitude_rising - standard_altitude).degrees./(
        360 * declination_rising.cos * observer.latitude.cos * local_hour_angle_rising.sin
      )
      delta_m_transit = - local_hour_angle_transit.degrees / 360
      delta_m_setting = (local_horizontal_altitude_setting - standard_altitude).degrees./(
        360 * declination_setting.cos * observer.latitude.cos * local_hour_angle_setting.sin
      )

      corrected_rising = initial_rising + delta_m_rising
      corrected_transit = initial_transit + delta_m_transit
      corrected_setting = initial_setting + delta_m_setting

      [
        Util::Time.decimal_hour_to_time(date, 24 * corrected_rising),
        Util::Time.decimal_hour_to_time(date, 24 * corrected_transit),
        Util::Time.decimal_hour_to_time(date, 24 * corrected_setting)
      ]
    end

    private

    def rationalize_decimal_time(decimal_time)
      decimal_time += 1 if decimal_time.negative?
      decimal_time -= 1 if decimal_time > 1
      decimal_time
    end

    def computed_coordinates(
      coordinates_of_the_previous_day,
      coordinates_of_the_day,
      coordinates_of_the_next_day,
      interpolation_factor_rising,
      interpolation_factor_transit,
      interpolation_factor_setting
    )
      right_ascension_rising = Angle.from_degrees(
        Util::Maths.interpolate(
          [
            coordinates_of_the_previous_day.right_ascension.degrees,
            coordinates_of_the_day.right_ascension.degrees,
            coordinates_of_the_next_day.right_ascension.degrees
          ],
          interpolation_factor_rising
        )
      )

      right_ascension_transit = Angle.from_degrees(
        Util::Maths.interpolate(
          [
            coordinates_of_the_previous_day.right_ascension.degrees,
            coordinates_of_the_day.right_ascension.degrees,
            coordinates_of_the_next_day.right_ascension.degrees
          ],
          interpolation_factor_transit
        )
      )

      right_ascension_setting = Angle.from_degrees(
        Util::Maths.interpolate(
          [
            coordinates_of_the_previous_day.right_ascension.degrees,
            coordinates_of_the_day.right_ascension.degrees,
            coordinates_of_the_next_day.right_ascension.degrees
          ],
          interpolation_factor_setting
        )
      )

      declination_rising = Angle.from_degrees(
        Util::Maths.interpolate(
          [
            coordinates_of_the_previous_day.declination.degrees,
            coordinates_of_the_day.declination.degrees,
            coordinates_of_the_next_day.declination.degrees
          ],
          interpolation_factor_rising
        )
      )

      declination_setting = Angle.from_degrees(
        Util::Maths.interpolate(
          [
            coordinates_of_the_previous_day.declination.degrees,
            coordinates_of_the_day.declination.degrees,
            coordinates_of_the_next_day.declination.degrees
          ],
          interpolation_factor_setting
        )
      )

      [
        right_ascension_rising,
        right_ascension_transit,
        right_ascension_setting,
        declination_rising,
        declination_setting
      ]
    end
  end
end
