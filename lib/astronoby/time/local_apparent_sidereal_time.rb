# frozen_string_literal: true

module Astronoby
  # Local Apparent Sidereal Time (LAST). Derived from GAST by adding the
  # observer's longitude.
  class LocalApparentSiderealTime < LocalSiderealTime
    # Creates LAST from a Greenwich Apparent Sidereal Time and longitude.
    #
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 14 - Local sidereal time (LST)
    #
    # @param gst [Astronoby::GreenwichApparentSiderealTime] GAST
    # @param longitude [Astronoby::Angle] the observer's longitude
    # @return [Astronoby::LocalApparentSiderealTime]
    # @raise [ArgumentError] if gst is not apparent sidereal time
    def self.from_gst(gst:, longitude:)
      unless gst.apparent?
        raise ArgumentError, "GST must be apparent sidereal time"
      end

      date = gst.date
      time = normalize_time(gst.time + longitude.hours)

      new(date: date, time: time, longitude: longitude)
    end

    # Creates LAST from UTC and longitude.
    #
    # @param utc [Time] the UTC time
    # @param longitude [Astronoby::Angle] the observer's longitude
    # @return [Astronoby::LocalApparentSiderealTime]
    def self.from_utc(utc, longitude:)
      gast = GreenwichApparentSiderealTime.from_utc(utc)
      from_gst(gst: gast, longitude: longitude)
    end

    # @param date [Date] the calendar date
    # @param time [Numeric] LAST in hours
    # @param longitude [Astronoby::Angle] the observer's longitude
    def initialize(date:, time:, longitude:)
      super(date: date, time: time, longitude: longitude, type: APPARENT)
    end

    # Converts to Greenwich Apparent Sidereal Time.
    #
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 15 - Converting LST to GST
    #
    # @return [Astronoby::GreenwichApparentSiderealTime]
    def to_gst
      date = @date
      time = normalize_time(@time - @longitude.hours)

      GreenwichApparentSiderealTime.new(date: date, time: time)
    end
  end
end
