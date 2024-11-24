# frozen_string_literal: true

module Astronoby
  class RiseTransitSetIteration
    EARTH_SIDEREAL_ROTATION_RATE = 360.98564736629

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 15 - Rising, Transit, and Setting

    # @param observer [Astronoby::Observer] Observer
    # @param date [Date] Date of the event
    # @param coordinates_of_the_previous_day [Astronoby::Coordinates::Equatorial]
    #  Coordinates of the body of the previous day
    # @param coordinates_of_the_day [Astronoby::Coordinates::Equatorial]
    #   Coordinates of the body of the day
    # @param coordinates_of_the_next_day [Astronoby::Coordinates::Equatorial]
    #   Coordinates of the body of the next day
    # @param shift [Astronoby::Angle] Altitude shift
    # @param initial_rising [Float] Initial rising
    # @param initial_transit [Float] Initial transit
    # @param initial_setting [Float] Initial setting
    def initialize(
      observer:,
      date:,
      coordinates_of_the_previous_day:,
      coordinates_of_the_day:,
      coordinates_of_the_next_day:,
      shift:,
      initial_rising:,
      initial_transit:,
      initial_setting:
    )
      @observer = observer
      @date = date
      @coordinates_of_the_previous_day = coordinates_of_the_previous_day
      @coordinates_of_the_day = coordinates_of_the_day
      @coordinates_of_the_next_day = coordinates_of_the_next_day
      @shift = shift
      @initial_rising = initial_rising
      @initial_transit = initial_transit
      @initial_setting = initial_setting
    end

    # @return [Array<Float>] Iteration results
    def iterate
      [
        delta_m_rising,
        delta_m_transit,
        delta_m_setting
      ]
    end

    private

    def delta_m_rising
      (local_horizontal_altitude_rising - @shift).degrees./(
        Constants::DEGREES_PER_CIRCLE *
          declination_rising.cos *
          @observer.latitude.cos *
          local_hour_angle_rising.sin
      )
    end

    def delta_m_transit
      -local_hour_angle_transit.degrees / Constants::DEGREES_PER_CIRCLE
    end

    def delta_m_setting
      (local_horizontal_altitude_setting - @shift).degrees./(
        Constants::DEGREES_PER_CIRCLE *
          declination_setting.cos *
          @observer.latitude.cos *
          local_hour_angle_setting.sin
      )
    end

    def observer_longitude
      # Longitude must be treated positively westwards from the meridian of
      # Greenwich, and negatively to the east
      @observer_longitude ||= -@observer.longitude
    end

    def apparent_gst_at_midnight
      @apparent_gst_at_midnight ||= Angle.from_hours(
        GreenwichSiderealTime.from_utc(
          Time.utc(@date.year, @date.month, @date.day)
        ).time
      )
    end

    def gst_rising
      @gst_rising ||= Angle.from_degrees(
        apparent_gst_at_midnight.degrees +
          EARTH_SIDEREAL_ROTATION_RATE * @initial_rising
      )
    end

    def gst_transit
      @gst_transit ||= Angle.from_degrees(
        apparent_gst_at_midnight.degrees +
          EARTH_SIDEREAL_ROTATION_RATE * @initial_transit
      )
    end

    def gst_setting
      @gst_setting ||= Angle.from_degrees(
        apparent_gst_at_midnight.degrees +
          EARTH_SIDEREAL_ROTATION_RATE * @initial_setting
      )
    end

    def local_hour_angle_rising
      @local_hour_angle_rising ||=
        gst_rising - observer_longitude - right_ascension_rising
    end

    def local_hour_angle_transit
      gst_transit - observer_longitude - right_ascension_transit
    end

    def local_hour_angle_setting
      @local_hour_angle_setting ||=
        gst_setting - observer_longitude - right_ascension_setting
    end

    def local_horizontal_altitude_rising
      Angle.asin(
        @observer.latitude.sin * declination_rising.sin +
          @observer.latitude.cos * declination_rising.cos * local_hour_angle_rising.cos
      )
    end

    def local_horizontal_altitude_setting
      Angle.asin(
        @observer.latitude.sin * declination_setting.sin +
          @observer.latitude.cos * declination_setting.cos * local_hour_angle_setting.cos
      )
    end

    def right_ascension_rising
      Angle.from_degrees(
        Util::Maths.interpolate(
          Util::Maths.normalize_angles_for_interpolation(
            [
              @coordinates_of_the_previous_day.right_ascension.degrees,
              @coordinates_of_the_day.right_ascension.degrees,
              @coordinates_of_the_next_day.right_ascension.degrees
            ]
          ),
          @initial_rising
        )
      )
    end

    def right_ascension_transit
      Angle.from_degrees(
        Util::Maths.interpolate(
          Util::Maths.normalize_angles_for_interpolation(
            [
              @coordinates_of_the_previous_day.right_ascension.degrees,
              @coordinates_of_the_day.right_ascension.degrees,
              @coordinates_of_the_next_day.right_ascension.degrees
            ]
          ),
          @initial_transit
        )
      )
    end

    def right_ascension_setting
      Angle.from_degrees(
        Util::Maths.interpolate(
          Util::Maths.normalize_angles_for_interpolation(
            [
              @coordinates_of_the_previous_day.right_ascension.degrees,
              @coordinates_of_the_day.right_ascension.degrees,
              @coordinates_of_the_next_day.right_ascension.degrees
            ]
          ),
          @initial_setting
        )
      )
    end

    def declination_rising
      Angle.from_degrees(
        Util::Maths.interpolate(
          Util::Maths.normalize_angles_for_interpolation(
            [
              @coordinates_of_the_previous_day.declination.degrees,
              @coordinates_of_the_day.declination.degrees,
              @coordinates_of_the_next_day.declination.degrees
            ]
          ),
          @initial_rising
        )
      )
    end

    def declination_setting
      Angle.from_degrees(
        Util::Maths.interpolate(
          Util::Maths.normalize_angles_for_interpolation(
            [
              @coordinates_of_the_previous_day.declination.degrees,
              @coordinates_of_the_day.declination.degrees,
              @coordinates_of_the_next_day.declination.degrees
            ]
          ),
          @initial_setting
        )
      )
    end
  end
end
