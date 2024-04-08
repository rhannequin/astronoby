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
    end

    # @return [Array<Time, Time, Time>, nil] Rising, transit, and setting times
    def times
      return nil if h0.nil?

      delta_m_rising = (local_horizontal_altitude_rising - shift).degrees./(
        360 * declination_rising.cos * @observer.latitude.cos * local_hour_angle_rising.sin
      )
      delta_m_transit = - local_hour_angle_transit.degrees / 360
      delta_m_setting = (local_horizontal_altitude_setting - shift).degrees./(
        360 * declination_setting.cos * @observer.latitude.cos * local_hour_angle_setting.sin
      )

      corrected_rising =
        rationalize_decimal_hours(24 * (initial_rising + delta_m_rising))
      corrected_transit =
        rationalize_decimal_hours(24 * (initial_transit + delta_m_transit))
      corrected_setting =
        rationalize_decimal_hours(24 * (initial_setting + delta_m_setting))

      [
        Util::Time.decimal_hour_to_time(@date, corrected_rising),
        Util::Time.decimal_hour_to_time(@date, corrected_transit),
        Util::Time.decimal_hour_to_time(@date, corrected_setting)
      ]
    end

    # @return [Array<Astronoby::Angle, Astronoby::Angle>] Rising, and setting
    #   times
    def azimuths
      [
        local_horizontal_azimuth_rising,
        local_horizontal_azimuth_setting
      ]
    end

    # @return [Astronoby::Angle] Altitude at transit
    def altitude_at_transit
      local_horizontal_altitude_transit
    end

    private

    def observer_longitude
      # Longitude must be treated positively westwards from the meridian of
      # Greenwich, and negatively to the east
      @observer_longitude ||= -@observer.longitude
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
      @apparent_gst_at_midnight ||= Angle.from_hours(
        GreenwichSiderealTime.from_utc(
          Time.utc(@date.year, @date.month, @date.day)
        ).time
      )
    end

    def initial_transit
      @initial_transit ||= rationalize_decimal_time(
        (
          @coordinates_of_the_day.right_ascension.degrees +
            observer_longitude.degrees -
            apparent_gst_at_midnight.degrees
        ) / 360.0
      )
    end

    def initial_rising
      @initial_rising ||=
        rationalize_decimal_time(initial_transit - h0.degrees / 360)
    end

    def initial_setting
      @initial_setting ||=
        rationalize_decimal_time(initial_transit + h0.degrees / 360)
    end

    def gst_rising
      @gst_rising ||= Angle.from_degrees(
        apparent_gst_at_midnight.degrees +
          EARTH_SIDEREAL_ROTATION_RATE * initial_rising
      )
    end

    def gst_transit
      @gst_transit ||= Angle.from_degrees(
        apparent_gst_at_midnight.degrees +
          EARTH_SIDEREAL_ROTATION_RATE * initial_transit
      )
    end

    def gst_setting
      @gst_setting ||= Angle.from_degrees(
        apparent_gst_at_midnight.degrees +
          EARTH_SIDEREAL_ROTATION_RATE * initial_setting
      )
    end

    def leap_day_portion
      @leap_day_portion ||= begin
        leap_seconds = Util::Time.leap_seconds_for(@date)
        leap_seconds / SECONDS_IN_A_DAY
      end
    end

    def local_hour_angle_rising
      @local_hour_angle_rising ||=
        gst_rising - observer_longitude - right_ascension_rising
    end

    def local_hour_angle_transit
      @local_hour_angle_transit ||=
        gst_transit - observer_longitude - right_ascension_transit
    end

    def local_hour_angle_setting
      @local_hour_angle_setting ||=
        gst_setting - observer_longitude - right_ascension_setting
    end

    def local_horizontal_altitude_rising
      @local_horizontal_altitude_rising ||= Angle.asin(
        @observer.latitude.sin * declination_rising.sin +
          @observer.latitude.cos * declination_rising.cos * local_hour_angle_rising.cos
      )
    end

    def local_horizontal_azimuth_rising
      shift = -@standard_altitude
      term1 = declination_rising.sin + shift.sin * @observer.latitude.cos
      term2 = shift.cos * @observer.latitude.cos
      angle = term1 / term2
      Angle.acos(angle)
    end

    def local_horizontal_altitude_transit
      @local_horizontal_altitude_transit ||= Angle.asin(
        @observer.latitude.sin * declination_transit.sin +
          @observer.latitude.cos * declination_transit.cos * local_hour_angle_transit.cos
      )
    end

    def local_horizontal_altitude_setting
      @local_horizontal_altitude_setting ||= Angle.asin(
        @observer.latitude.sin * declination_setting.sin +
          @observer.latitude.cos * declination_setting.cos * local_hour_angle_setting.cos
      )
    end

    def local_horizontal_azimuth_setting
      shift = -@standard_altitude
      term1 = declination_setting.sin + shift.sin * @observer.latitude.cos
      term2 = shift.cos * @observer.latitude.cos
      angle = term1 / term2
      Angle.from_degrees(360 - Angle.acos(angle).degrees)
    end

    def rationalize_decimal_time(decimal_time)
      decimal_time += 1 if decimal_time.negative?
      decimal_time -= 1 if decimal_time > 1
      decimal_time
    end

    def rationalize_decimal_hours(decimal_hours)
      decimal_hours += 24 if decimal_hours.negative?
      decimal_hours -= 24 if decimal_hours > 24
      decimal_hours
    end

    def right_ascension_rising
      Angle.from_degrees(
        Util::Maths.interpolate(
          [
            @coordinates_of_the_previous_day.right_ascension.degrees,
            @coordinates_of_the_day.right_ascension.degrees,
            @coordinates_of_the_next_day.right_ascension.degrees
          ],
          initial_rising + leap_day_portion
        )
      )
    end

    def right_ascension_transit
      Angle.from_degrees(
        Util::Maths.interpolate(
          [
            @coordinates_of_the_previous_day.right_ascension.degrees,
            @coordinates_of_the_day.right_ascension.degrees,
            @coordinates_of_the_next_day.right_ascension.degrees
          ],
          initial_transit + leap_day_portion
        )
      )
    end

    def right_ascension_setting
      Angle.from_degrees(
        Util::Maths.interpolate(
          [
            @coordinates_of_the_previous_day.right_ascension.degrees,
            @coordinates_of_the_day.right_ascension.degrees,
            @coordinates_of_the_next_day.right_ascension.degrees
          ],
          initial_setting + leap_day_portion
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
          initial_rising + leap_day_portion
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
          initial_transit + leap_day_portion
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
          initial_setting + leap_day_portion
        )
      )
    end

    def shift
      @standard_altitude - @additional_altitude
    end
  end
end
