# frozen_string_literal: true

module Astronoby
  class Body
    DEFAULT_REFRACTION_VERTICAL_SHIFT = Angle.as_dms(0, 34, 0)
    RISING_SETTING_HOUR_ANGLE_RATIO_RANGE = (-1..1)

    def initialize(equatorial_coordinates)
      @equatorial_coordinates = equatorial_coordinates
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 33 - Rising and setting
    def rising_time(latitude:, longitude:, date:, apparent: true)
      ratio = ratio(latitude, apparent)
      return nil unless RISING_SETTING_HOUR_ANGLE_RATIO_RANGE.cover?(ratio)

      hour_angle = Angle.acos(ratio)
      local_sidereal_time = LocalSiderealTime.new(
        date: date,
        time: @equatorial_coordinates.right_ascension.hours - hour_angle.hours,
        longitude: longitude
      )

      local_sidereal_time.to_gst.to_utc
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    def rising_azimuth(latitude:)
      ar = azimuth_component(latitude)
      return nil if ar >= 1

      Angle.acos(ar)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 33 - Rising and setting
    def setting_time(latitude:, longitude:, date:, apparent: true)
      ratio = ratio(latitude, apparent)
      return nil unless RISING_SETTING_HOUR_ANGLE_RATIO_RANGE.cover?(ratio)

      hour_angle = Angle.acos(ratio)
      local_sidereal_time = LocalSiderealTime.new(
        date: date,
        time: @equatorial_coordinates.right_ascension.hours + hour_angle.hours,
        longitude: longitude
      )

      local_sidereal_time.to_gst.to_utc
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    def setting_azimuth(latitude:)
      rising_az = rising_azimuth(latitude: latitude)
      return nil if rising_az.nil?

      Angle.as_degrees(360 - rising_az.degrees)
    end

    private

    def ratio(latitude, apparent)
      shift = apparent ? DEFAULT_REFRACTION_VERTICAL_SHIFT : Angle.zero

      -(shift.sin + latitude.sin * @equatorial_coordinates.declination.sin)./(
        latitude.cos * @equatorial_coordinates.declination.cos
      )
    end

    def azimuth_component(latitude)
      @equatorial_coordinates.declination.sin / latitude.cos
    end
  end
end
