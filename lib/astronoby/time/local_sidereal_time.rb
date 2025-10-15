# frozen_string_literal: true

module Astronoby
  class LocalSiderealTime < SiderealTime
    attr_reader :longitude

    def self.from_gst(gst:, longitude:)
      case gst.type
      when MEAN
        LocalMeanSiderealTime.from_gst(gst: gst, longitude: longitude)
      when APPARENT
        LocalApparentSiderealTime.from_gst(gst: gst, longitude: longitude)
      end
    end

    def self.from_utc(utc, longitude:, type: MEAN)
      validate_type!(type)
      case type
      when MEAN
        LocalMeanSiderealTime.from_utc(utc, longitude: longitude)
      when APPARENT
        LocalApparentSiderealTime.from_utc(utc, longitude: longitude)
      end
    end

    def initialize(date:, time:, longitude:, type: MEAN)
      super(date: date, time: time, type: type)
      @longitude = longitude
    end

    def to_gst
      case @type
      when MEAN
        lst = LocalMeanSiderealTime.new(
          date: @date,
          time: @time,
          longitude: @longitude
        )
        lst.to_gst
      when APPARENT
        last = LocalApparentSiderealTime.new(
          date: @date,
          time: @time,
          longitude: @longitude
        )
        last.to_gst
      end
    end
  end
end
