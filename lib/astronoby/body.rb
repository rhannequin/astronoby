# frozen_string_literal: true

module Astronoby
  class Body
    def initialize(equatorial_coordinates)
      @equatorial_coordinates = equatorial_coordinates
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    def rising_time(latitude:, longitude:, date:)
      h2_component = h2(latitude: latitude)
      return nil if h2_component.nil?

      rising_lst = 24 +
        @equatorial_coordinates.right_ascension.hours - h2_component.degrees
      rising_lst -= 24 if rising_lst > 24

      Astronoby::Util::Time.lst_to_ut(
        date: date,
        longitude: longitude,
        lst: rising_lst
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    def rising_azimuth(latitude:)
      ar = azimuth_component(latitude: latitude)
      return nil if ar >= 1

      Astronoby::Angle.as_radians(Math.acos(ar))
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    def setting_time(latitude:, longitude:, date:)
      h2_component = h2(latitude: latitude)
      return nil if h2_component.nil?

      setting_lst = @equatorial_coordinates.right_ascension.hours + h2_component.degrees
      setting_lst -= 24 if setting_lst > 24

      Astronoby::Util::Time.lst_to_ut(
        date: date,
        longitude: longitude,
        lst: setting_lst
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    def setting_azimuth(latitude:)
      rising_az = rising_azimuth(latitude: latitude)
      return nil if rising_az.nil?

      Astronoby::Angle.as_degrees(360 - rising_az.degrees)
    end

    private

    def azimuth_component(latitude:)
      Math.sin(@equatorial_coordinates.declination.radians)./(
        Math.cos(latitude.radians)
      )
    end

    def h2(latitude:)
      ar = azimuth_component(latitude: latitude)
      return nil if ar >= 1

      h1 = Math.tan(latitude.radians) *
        Math.tan(@equatorial_coordinates.declination.radians)
      return nil if h1.abs > 1

      Astronoby::Angle.as_radians(Math.acos(-h1) / 15.0)
    end
  end
end
