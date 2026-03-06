# frozen_string_literal: true

module Astronoby
  # Local Mean Sidereal Time (LMST). Derived from GMST by adding the
  # observer's longitude.
  class LocalMeanSiderealTime < LocalSiderealTime
    # Creates LMST from a Greenwich Mean Sidereal Time and longitude.
    #
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 14 - Local sidereal time (LST)
    #
    # @param gst [Astronoby::GreenwichMeanSiderealTime] GMST
    # @param longitude [Astronoby::Angle] the observer's longitude
    # @return [Astronoby::LocalMeanSiderealTime]
    # @raise [ArgumentError] if gst is not mean sidereal time
    def self.from_gst(gst:, longitude:)
      unless gst.mean?
        raise ArgumentError, "GST must be mean sidereal time"
      end

      date = gst.date
      time = normalize_time(gst.time + longitude.hours)

      new(date: date, time: time, longitude: longitude)
    end

    # Creates LMST from UTC and longitude.
    #
    # @param utc [Time] the UTC time
    # @param longitude [Astronoby::Angle] the observer's longitude
    # @return [Astronoby::LocalMeanSiderealTime]
    def self.from_utc(utc, longitude:)
      gmst = GreenwichMeanSiderealTime.from_utc(utc)
      from_gst(gst: gmst, longitude: longitude)
    end

    # @param date [Date] the calendar date
    # @param time [Numeric] LMST in hours
    # @param longitude [Astronoby::Angle] the observer's longitude
    def initialize(date:, time:, longitude:)
      super(date: date, time: time, longitude: longitude, type: MEAN)
    end

    # Converts to Greenwich Mean Sidereal Time.
    #
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 15 - Converting LST to GST
    #
    # @return [Astronoby::GreenwichMeanSiderealTime]
    def to_gst
      date = @date
      time = normalize_time(@time - @longitude.hours)

      GreenwichMeanSiderealTime.new(date: date, time: time)
    end
  end
end
