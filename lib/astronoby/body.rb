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
      ar = Math.sin(@equatorial_coordinates.declination.to_radians.value)./(
        Math.cos(latitude.to_radians.value)
      )
      return nil if ar >= 1

      r = Astronoby::Angle.as_radians(Math.acos(ar))
      s = Astronoby::Angle.as_degrees(360 - r.to_degrees.value)
      h1 = Math.tan(latitude.to_radians.value) *
        Math.tan(@equatorial_coordinates.declination.to_radians.value)
      return nil if h1 > 1

      h2 = Astronoby::Angle.as_radians(Math.acos(-h1) / 15.0)

      rising_lst = 24 + @equatorial_coordinates.right_ascension.to_hours.value - h2.to_degrees.value
      rising_lst -= 24 if rising_lst > 24

      Astronoby::Util::Time.lst_to_ut(
        date: date,
        longitude: longitude,
        lst: rising_lst
      )
    end
  end
end
