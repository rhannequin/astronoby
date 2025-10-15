# frozen_string_literal: true

module Astronoby
  class GreenwichSiderealTime < SiderealTime
    def self.from_utc(utc, type: MEAN)
      validate_type!(type)
      case type
      when MEAN
        GreenwichMeanSiderealTime.from_utc(utc)
      when APPARENT
        GreenwichApparentSiderealTime.from_utc(utc)
      end
    end

    def self.mean_from_utc(utc)
      GreenwichMeanSiderealTime.from_utc(utc)
    end

    def self.apparent_from_utc(utc)
      GreenwichApparentSiderealTime.from_utc(utc)
    end

    def to_utc
      unless mean?
        raise NotImplementedError,
          "UTC conversion only supported for mean sidereal time"
      end

      gmst = GreenwichMeanSiderealTime.new(date: @date, time: @time)
      gmst.to_utc
    end

    def to_lst(longitude:)
      LocalSiderealTime.from_gst(gst: self, longitude: longitude)
    end
  end
end
