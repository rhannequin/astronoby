# frozen_string_literal: true

module Astronoby
  class LocalSiderealTime
    attr_reader :date, :time, :longitude

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 14 - Local sidereal time (LST)
    def self.from_gst(gst:, longitude:)
      date = gst.date
      time = gst.time + longitude.hours
      time += Constants::HOURS_PER_DAY if time.negative?
      time -= Constants::HOURS_PER_DAY if time > Constants::HOURS_PER_DAY

      new(date: date, time: time, longitude: longitude)
    end

    def initialize(date:, time:, longitude:)
      @date = date
      @time = time
      @longitude = longitude
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 15 - Converting LST to GST
    def to_gst
      date = @date
      time = @time - @longitude.hours
      time += Constants::HOURS_PER_DAY if time.negative?
      time -= Constants::HOURS_PER_DAY if time > Constants::HOURS_PER_DAY

      GreenwichSiderealTime.new(date: date, time: time)
    end
  end
end
