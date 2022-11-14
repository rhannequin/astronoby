# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Equatorial
      def initialize(
        right_ascension_hour:,
        right_ascension_minute:,
        right_ascension_second:,
        declination_degree:,
        declination_minute:,
        declination_second:
      )
        @right_ascension_hour = right_ascension_hour
        @right_ascension_minute = right_ascension_minute
        @right_ascension_second = right_ascension_second
        @declination_degree = declination_degree
        @declination_minute = declination_minute
        @declination_second = declination_second
      end

      def to_horizontal(time:, latitude:, longitude:)
        universal_time = time.utc
        jd = universal_time.to_date.ajd.to_f
        jd0 = Time.utc(universal_time.year, 1, 1, 0, 0, 0).to_date.ajd - 1
        days = jd - jd0
        t = (jd0 - BigDecimal("2415020")) / BigDecimal("36525")
        r = BigDecimal("6.6460656") +
          BigDecimal("2400.051262") * t + BigDecimal("0.00002581") * t * t
        b = 24 - r + 24 * (universal_time.year - 1900)
        t0 = BigDecimal("0.0657098") * days - b
        ut = universal_time.hour +
          universal_time.min / BigDecimal("60") +
          universal_time.sec / BigDecimal("3600")
        gst = t0 + BigDecimal("1.002738") * ut

        # If gst negative, add 24 hours to the date
        # If gst is greater than 24, subtract 24 hours from the date

        gst += 24 if gst.negative?
        gst -= 24 if gst > 24

        adjustment = longitude / BigDecimal("15")
        lst = (gst + adjustment)

        hour_angle = lst - (
          @right_ascension_hour +
          @right_ascension_minute / 60r +
          @right_ascension_second / 3600r
        )

        hour_angle += 24 if hour_angle.negative?
        hour_angle -= 24 if hour_angle > 24
        hour_angle_degree = hour_angle * BigDecimal("15")
        hour_angle_radians = Astronoby::Util::Trigonometry.to_radians(hour_angle_degree)

        declination_sign = @declination_degree.negative? ? -1 : 1
        declination_decimal = (
          @declination_degree.abs +
          @declination_minute / BigDecimal("60") +
          @declination_second / BigDecimal("3600")
        ) * declination_sign
        declination_radians = Astronoby::Util::Trigonometry.to_radians(declination_decimal)

        latitude_radians = Astronoby::Util::Trigonometry.to_radians(latitude)
        t0 = Math.sin(declination_radians) * Math.sin(latitude_radians) +
          Math.cos(declination_radians) * Math.cos(latitude_radians) * Math.cos(hour_angle_radians)
        h = Astronoby::Util::Trigonometry.to_degrees(Math.asin(t0))
        h_radians = Astronoby::Util::Trigonometry.to_radians(h)
        t1 = Math.sin(declination_radians) -
          Math.sin(latitude_radians) * Math.sin(h_radians)
        t2 = t1 / (Math.cos(latitude_radians) * Math.cos(h_radians))

        sin_hour_angle = Math.sin(hour_angle_radians)
        a = Astronoby::Util::Trigonometry.to_degrees(Math.acos(t2))
        a = 360 - a if sin_hour_angle.positive?

        azimuth_sign = a.negative? ? -1 : 1
        azimuth_absolute = a.abs
        azimuth_degree = azimuth_absolute.floor
        azimuth_decimal_minute = 60 * (azimuth_absolute - azimuth_degree)
        azimuth_minute = azimuth_decimal_minute.floor
        azimuth_second = 60 * (azimuth_decimal_minute - azimuth_decimal_minute.floor)

        altitude_sign = h.negative? ? -1 : 1
        altitude_absolute = h.abs
        altitude_degree = altitude_absolute.floor
        altitude_decimal_minute = 60 * (altitude_absolute - altitude_degree)
        altitude_minute = altitude_decimal_minute.floor
        altitude_second = 60 * (altitude_decimal_minute - altitude_decimal_minute.floor)

        Horizontal.new(
          azimuth_degree: azimuth_degree * azimuth_sign,
          azimuth_minute: azimuth_minute,
          azimuth_second: azimuth_second,
          altitude_degree: altitude_degree * altitude_sign,
          altitude_minute: altitude_minute,
          altitude_second: altitude_second,
          latitude: latitude,
          longitude: longitude
        )
      end
    end
  end
end
