# frozen_string_literal: true

RSpec.describe Astronoby::LocalSiderealTime do
  describe "::from_gst" do
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 14 - Local sidereal time (LST)
    it "computes the local sidereal time for 2024-03-14" do
      date = Date.new(2024, 3, 14)
      gst = Astronoby::GreenwichSiderealTime.new(
        date: date,
        time: 4 + 40 / 60.0 + 5.23 / 3600.0
      )
      longitude = Astronoby::Angle.as_degrees(-64)

      lst = described_class.from_gst(gst: gst, longitude: longitude)

      minute = (lst.time - lst.time.to_i) * 60
      second = (minute - minute.to_i) * 60
      expect(lst.time.to_i).to eq(0)
      expect(minute.to_i).to eq(24)
      expect(second.ceil(4)).to eq(5.2301)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "computes the local sidereal time for 1991-03-14" do
      date = Date.new(1991, 3, 14)
      gst = Astronoby::GreenwichSiderealTime.new(
        date: date,
        time: 2 + 3 / 60.0 + 41 / 3600.0
      )
      longitude = Astronoby::Angle.as_degrees(-40)

      lst = described_class.from_gst(gst: gst, longitude: longitude)

      minute = (lst.time - lst.time.to_i) * 60
      second = (minute - minute.to_i) * 60
      expect(lst.time.to_i).to eq(23)
      expect(minute.to_i).to eq(23)
      expect(second.round).to eq(41)
    end
  end

  describe "#to_gst" do
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 15 - Converting LST to GST
    it "returns the Greenwich sidereal time for 2024-03-14" do
      longitude = Astronoby::Angle.as_degrees(-64)
      date = Date.new(2024, 3, 14)
      time = 24 / 60.0 + 5.23 / 3600.0
      lst = described_class.new(date: date, time: time, longitude: longitude)

      gst = lst.to_gst

      minute = (gst.time - gst.time.to_i) * 60
      second = (minute - minute.to_i) * 60
      expect(gst.time.to_i).to eq(4)
      expect(minute.to_i).to eq(40)
      expect(second.ceil(4)).to eq(5.2301)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the Greenwich sidereal time for 2014-12-13" do
      longitude = Astronoby::Angle.as_degrees(-77)
      date = Date.new(2014, 12, 13)
      time = 1 + 18 / 60.0 + 34 / 3600.0
      lst = described_class.new(date: date, time: time, longitude: longitude)

      gst = lst.to_gst

      minute = (gst.time - gst.time.to_i) * 60
      second = (minute - minute.to_i) * 60
      expect(gst.time.to_i).to eq(6)
      expect(minute.to_i).to eq(26)
      expect(second.round).to eq(34)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the Greenwich sidereal time for 200-07-05" do
      longitude = Astronoby::Angle.as_degrees(60)
      date = Date.new(2000, 7, 5)
      time = 5 + 54 / 60.0 + 20 / 3600.0
      lst = described_class.new(date: date, time: time, longitude: longitude)

      gst = lst.to_gst

      minute = (gst.time - gst.time.to_i) * 60
      second = (minute - minute.to_i) * 60
      expect(gst.time.to_i).to eq(1)
      expect(minute.to_i).to eq(54)
      expect(second.round).to eq(20)
    end
  end
end
