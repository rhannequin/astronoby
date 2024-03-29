# frozen_string_literal: true

module Astronoby
  class Body
    DEFAULT_REFRACTION_VERTICAL_SHIFT = Angle.from_dms(0, 34, 0)
    RISING_SETTING_HOUR_ANGLE_RATIO_RANGE = (-1..1)

    def initialize(equatorial_coordinates)
      @equatorial_coordinates = equatorial_coordinates
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 33 - Rising and setting

    # @param latitude [Astronoby::Angle] Latitude of the observer
    # @param longitude [Astronoby::Angle] Longitude of the observer
    # @param date [Date] Date of the event
    # @param apparent [Boolean] Compute apparent or true data
    # @param vertical_shift [Astronoby::Angle] Vertical shift correction angle
    # @return [Time, nil] Sunrise time
    def rising_time(
      latitude:,
      longitude:,
      date:,
      apparent: true,
      vertical_shift: nil
    )
      time_ratio = time_ratio(latitude, apparent, vertical_shift)
      return nil unless RISING_SETTING_HOUR_ANGLE_RATIO_RANGE.cover?(time_ratio)

      hour_angle = Angle.acos(time_ratio)
      local_sidereal_time = LocalSiderealTime.new(
        date: date,
        time: right_ascension.hours - hour_angle.hours,
        longitude: longitude
      )

      local_sidereal_time.to_gst.to_utc
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 33 - Rising and setting

    # @param latitude [Astronoby::Angle] Latitude of the observer
    # @param apparent [Boolean] Compute apparent or true data
    # @param vertical_shift [Astronoby::Angle] Vertical shift correction angle
    # @return [Astronoby::Angle, nil] Sunrise azimuth
    def rising_azimuth(latitude:, apparent: true, vertical_shift: nil)
      time_ratio = time_ratio(latitude, apparent, vertical_shift)
      return nil unless RISING_SETTING_HOUR_ANGLE_RATIO_RANGE.cover?(time_ratio)

      azimuth_ratio = azimuth_ratio(latitude, apparent, vertical_shift)

      Angle.acos(azimuth_ratio)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 33 - Rising and setting

    # @param latitude [Astronoby::Angle] Latitude of the observer
    # @param longitude [Astronoby::Angle] Longitude of the observer
    # @param date [Date] Date of the event
    # @param apparent [Boolean] Compute apparent or true data
    # @param vertical_shift [Astronoby::Angle] Vertical shift correction angle
    # @return [Time, nil] Sunset time
    def setting_time(
      latitude:,
      longitude:,
      date:,
      apparent: true,
      vertical_shift: nil
    )
      time_ratio = time_ratio(latitude, apparent, vertical_shift)
      return unless RISING_SETTING_HOUR_ANGLE_RATIO_RANGE.cover?(time_ratio)

      hour_angle = Angle.acos(time_ratio)
      local_sidereal_time = LocalSiderealTime.new(
        date: date,
        time: right_ascension.hours + hour_angle.hours,
        longitude: longitude
      )

      local_sidereal_time.to_gst.to_utc
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 33 - Rising and setting

    # @param latitude [Astronoby::Angle] Latitude of the observer
    # @param apparent [Boolean] Compute apparent or true data
    # @param vertical_shift [Astronoby::Angle] Vertical shift correction angle
    # @return [Astronoby::Angle, nil] Sunset azimuth
    def setting_azimuth(latitude:, apparent: true, vertical_shift: nil)
      time_ratio = time_ratio(latitude, apparent, vertical_shift)
      return nil unless RISING_SETTING_HOUR_ANGLE_RATIO_RANGE.cover?(time_ratio)

      azimuth_ratio = azimuth_ratio(latitude, apparent, vertical_shift)

      Angle.from_degrees(360 - Angle.acos(azimuth_ratio).degrees)
    end

    private

    def time_ratio(latitude, apparent, vertical_shift)
      shift = if vertical_shift
        vertical_shift
      elsif apparent
        DEFAULT_REFRACTION_VERTICAL_SHIFT
      else
        Angle.zero
      end

      term1 = shift.sin + latitude.sin * declination.sin
      term2 = latitude.cos * declination.cos

      -term1 / term2
    end

    def azimuth_ratio(latitude, apparent, vertical_shift)
      shift = if vertical_shift
        vertical_shift
      elsif apparent
        DEFAULT_REFRACTION_VERTICAL_SHIFT
      else
        Angle.zero
      end

      (declination.sin + shift.sin * latitude.cos) / (shift.cos * latitude.cos)
    end

    def azimuth_component(latitude)
      declination.sin / latitude.cos
    end

    def right_ascension
      @equatorial_coordinates.right_ascension
    end

    def declination
      @equatorial_coordinates.declination
    end
  end
end
