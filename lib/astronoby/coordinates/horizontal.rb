# frozen_string_literal: true

module Astronoby
  module Coordinates
    class Horizontal
      def initialize(
        azimuth_degree:,
        azimuth_minute:,
        azimuth_second:,
        altitude_degree:,
        altitude_minute:,
        altitude_second:,
        latitude:,
        longitude:
      )
        @azimuth_degree = azimuth_degree
        @azimuth_minute = azimuth_minute
        @azimuth_second = azimuth_second
        @altitude_degree = altitude_degree
        @altitude_minute = altitude_minute
        @altitude_second = altitude_second
        @latitude = latitude
        @longitude = longitude
      end

      def to_equatorial(time:)
        universal_time = time.utc
        jd = universal_time.to_date.ajd.to_f
        jd0 = Time.utc(universal_time.year, 1, 1, 0, 0, 0).to_date.ajd - 1
        days = jd - jd0
        t = (jd0 - BigDecimal("2415020")) / BigDecimal("36525")
        r = BigDecimal("6.6460656") +
          BigDecimal("2400.051262") * t +
          BigDecimal("0.00002581") * t * t
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

        adjustment = @longitude / 15
        lst = (gst + adjustment)

        altitude_sign = @altitude_degree.negative? ? -1 : 1
        altitude_decimal_degrees = (
          @altitude_degree.abs +
            @altitude_minute / 60r +
            @altitude_second / 3600r
        ) * altitude_sign
        azimuth_decimal_degrees = @azimuth_degree +
          @azimuth_minute / 60r +
          @azimuth_second / 3600r

        altitude_radians = Astronoby::Util::Trigonometry
          .to_radians(altitude_decimal_degrees)
        latitude_radians = Astronoby::Util::Trigonometry
          .to_radians(@latitude)
        azimuth_radians = Astronoby::Util::Trigonometry
          .to_radians(azimuth_decimal_degrees)

        t0 = Math.sin(altitude_radians) * Math.sin(latitude_radians) +
          Math.cos(altitude_radians) * Math.cos(latitude_radians) * Math.cos(azimuth_radians)

        declination_radians = Math.asin(t0)
        declination_decimal_degrees = Astronoby::Util::Trigonometry
          .to_degrees(declination_radians)

        t1 = Math.sin(altitude_radians) -
          Math.sin(latitude_radians) * Math.sin(declination_radians)

        hour_angle_degrees = Astronoby::Util::Trigonometry.to_degrees(
          Math.acos(
            t1 / (Math.cos(latitude_radians) * Math.cos(declination_radians))
          )
        )

        if Math.sin(azimuth_radians).positive?
          hour_angle_degrees = BigDecimal("360") - hour_angle_degrees
        end

        hour_angle_hours = hour_angle_degrees / 15r
        right_ascension_decimal = lst - hour_angle_hours
        right_ascension_decimal += 24 if right_ascension_decimal.negative?

        right_ascension_absolute = right_ascension_decimal.abs
        right_ascension_hour = right_ascension_absolute.floor
        right_ascension_decimal_minute = 60 * (right_ascension_absolute - right_ascension_hour)
        right_ascension_minute = right_ascension_decimal_minute.floor
        right_ascension_second = 60 * (right_ascension_decimal_minute - right_ascension_decimal_minute.floor)

        declination_sign = declination_decimal_degrees.negative? ? -1 : 1
        declination_absolute = declination_decimal_degrees.abs
        declination_degree = declination_absolute.floor
        declination_decimal_minute = 60 * (declination_absolute - declination_degree)
        declination_minute = declination_decimal_minute.floor
        declination_second = 60 * (declination_decimal_minute - declination_decimal_minute.floor)

        Equatorial.new(
          right_ascension_hour: right_ascension_hour,
          right_ascension_minute: right_ascension_minute,
          right_ascension_second: right_ascension_second,
          declination_degree: declination_sign * declination_degree,
          declination_minute: declination_minute,
          declination_second: declination_second
        )
      end
    end
  end
end
