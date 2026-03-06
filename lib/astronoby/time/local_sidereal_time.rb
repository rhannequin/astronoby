# frozen_string_literal: true

module Astronoby
  # Local Sidereal Time base class. Dispatches to mean or apparent subclasses
  # based on the type of the source GST.
  class LocalSiderealTime < SiderealTime
    # @return [Astronoby::Angle] the observer's longitude
    attr_reader :longitude

    # Creates an LST from a Greenwich Sidereal Time and longitude.
    #
    # @param gst [Astronoby::GreenwichSiderealTime] Greenwich Sidereal Time
    # @param longitude [Astronoby::Angle] the observer's longitude
    # @return [Astronoby::LocalMeanSiderealTime,
    #   Astronoby::LocalApparentSiderealTime]
    def self.from_gst(gst:, longitude:)
      case gst.type
      when MEAN
        LocalMeanSiderealTime.from_gst(gst: gst, longitude: longitude)
      when APPARENT
        LocalApparentSiderealTime.from_gst(gst: gst, longitude: longitude)
      end
    end

    # Creates an LST from UTC and longitude.
    #
    # @param utc [Time] the UTC time
    # @param longitude [Astronoby::Angle] the observer's longitude
    # @param type [Symbol] :mean or :apparent
    # @return [Astronoby::LocalMeanSiderealTime,
    #   Astronoby::LocalApparentSiderealTime]
    def self.from_utc(utc, longitude:, type: MEAN)
      validate_type!(type)
      case type
      when MEAN
        LocalMeanSiderealTime.from_utc(utc, longitude: longitude)
      when APPARENT
        LocalApparentSiderealTime.from_utc(utc, longitude: longitude)
      end
    end

    # @param date [Date] the calendar date
    # @param time [Numeric] the sidereal time in hours
    # @param longitude [Astronoby::Angle] the observer's longitude
    # @param type [Symbol] :mean or :apparent
    def initialize(date:, time:, longitude:, type: MEAN)
      super(date: date, time: time, type: type)
      @longitude = longitude
    end

    # Converts to Greenwich Sidereal Time.
    #
    # @return [Astronoby::GreenwichMeanSiderealTime,
    #   Astronoby::GreenwichApparentSiderealTime]
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
