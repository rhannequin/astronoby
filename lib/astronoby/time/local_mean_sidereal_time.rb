# frozen_string_literal: true

module Astronoby
  class LocalMeanSiderealTime < LocalSiderealTime
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 14 - Local sidereal time (LST)
    def self.from_gst(gst:, longitude:)
      unless gst.mean?
        raise ArgumentError, "GST must be mean sidereal time"
      end

      date = gst.date
      time = normalize_time(gst.time + longitude.hours)

      new(date: date, time: time, longitude: longitude)
    end

    def self.from_utc(utc, longitude:)
      gmst = GreenwichMeanSiderealTime.from_utc(utc)
      from_gst(gst: gmst, longitude: longitude)
    end

    def initialize(date:, time:, longitude:)
      super(date: date, time: time, longitude: longitude, type: MEAN)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 15 - Converting LST to GST
    def to_gst
      date = @date
      time = normalize_time(@time - @longitude.hours)

      GreenwichMeanSiderealTime.new(date: date, time: time)
    end
  end
end
