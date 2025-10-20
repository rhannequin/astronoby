# frozen_string_literal: true

RSpec.describe Astronoby::LocalSiderealTime do
  describe "::from_gst" do
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 14 - Local sidereal time (LST)
    it "computes the local mean sidereal time for 2024-03-14" do
      date = Date.new(2024, 3, 14)
      gst = Astronoby::GreenwichSiderealTime.new(
        date: date,
        time: 4 + 40 / 60.0 + 5.23 / 3600.0,
        type: :mean
      )
      longitude = Astronoby::Angle.from_degrees(-64)

      lst = described_class.from_gst(gst: gst, longitude: longitude)

      minute = (lst.time - lst.time.to_i) * 60
      second = (minute - minute.to_i) * 60
      expect(lst.time.to_i).to eq(0)
      expect(minute.to_i).to eq(24)
      expect(second.ceil(4)).to eq(5.2301)
      expect(lst.type).to eq(:mean)
      expect(lst).to be_mean
      expect(lst).not_to be_apparent
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "computes the local mean sidereal time for 1991-03-14" do
      date = Date.new(1991, 3, 14)
      gst = Astronoby::GreenwichSiderealTime.new(
        date: date,
        time: 2 + 3 / 60.0 + 41 / 3600.0,
        type: :mean
      )
      longitude = Astronoby::Angle.from_degrees(-40)

      lst = described_class.from_gst(gst: gst, longitude: longitude)

      minute = (lst.time - lst.time.to_i) * 60
      second = (minute - minute.to_i) * 60
      expect(lst.time.to_i).to eq(23)
      expect(minute.to_i).to eq(23)
      expect(second.round).to eq(41)
      expect(lst.type).to eq(:mean)
    end

    it "computes the local apparent sidereal time" do
      date = Date.new(2024, 3, 14)
      gast = Astronoby::GreenwichSiderealTime.new(
        date: date,
        time: 4 + 40 / 60.0 + 5.23 / 3600.0,
        type: :apparent
      )
      longitude = Astronoby::Angle.from_degrees(-64)

      last = described_class.from_gst(gst: gast, longitude: longitude)

      expect(last.type).to eq(:apparent)
      expect(last).to be_apparent
      expect(last).not_to be_mean
    end
  end

  describe "::from_utc" do
    it "creates local mean sidereal time from UTC" do
      utc = Time.utc(2024, 3, 14, 12, 0, 0)
      longitude = Astronoby::Angle.from_degrees(-64)

      lmst = described_class.from_utc(utc, longitude: longitude, type: :mean)

      expect(lmst.type).to eq(:mean)
      expect(lmst).to be_mean
      expect(lmst.longitude).to eq(longitude)
    end

    it "creates local apparent sidereal time from UTC" do
      utc = Time.utc(2024, 3, 14, 12, 0, 0)
      longitude = Astronoby::Angle.from_degrees(-64)

      last = described_class.from_utc(
        utc,
        longitude: longitude,
        type: :apparent
      )

      expect(last.type).to eq(:apparent)
      expect(last).to be_apparent
      expect(last.longitude).to eq(longitude)
    end
  end

  describe "#to_gst" do
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 15 - Converting LST to GST
    it "returns the Greenwich mean sidereal time for 2024-03-14" do
      longitude = Astronoby::Angle.from_degrees(-64)
      date = Date.new(2024, 3, 14)
      time = 24 / 60.0 + 5.23 / 3600.0
      lst = described_class.new(
        date: date,
        time: time,
        longitude: longitude,
        type: :mean
      )

      gst = lst.to_gst

      minute = (gst.time - gst.time.to_i) * 60
      second = (minute - minute.to_i) * 60
      expect(gst.time.to_i).to eq(4)
      expect(minute.to_i).to eq(40)
      expect(second.ceil(4)).to eq(5.2301)
      expect(gst.type).to eq(:mean)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the Greenwich mean sidereal time for 2014-12-13" do
      longitude = Astronoby::Angle.from_degrees(-77)
      date = Date.new(2014, 12, 13)
      time = 1 + 18 / 60.0 + 34 / 3600.0
      lst = described_class.new(
        date: date,
        time: time,
        longitude: longitude,
        type: :mean
      )

      gst = lst.to_gst

      minute = (gst.time - gst.time.to_i) * 60
      second = (minute - minute.to_i) * 60
      expect(gst.time.to_i).to eq(6)
      expect(minute.to_i).to eq(26)
      expect(second.round).to eq(34)
      expect(gst.type).to eq(:mean)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the Greenwich mean sidereal time for 2000-07-05" do
      longitude = Astronoby::Angle.from_degrees(60)
      date = Date.new(2000, 7, 5)
      time = 5 + 54 / 60.0 + 20 / 3600.0
      lst = described_class.new(
        date: date,
        time: time,
        longitude: longitude,
        type: :mean
      )

      gst = lst.to_gst

      minute = (gst.time - gst.time.to_i) * 60
      second = (minute - minute.to_i) * 60
      expect(gst.time.to_i).to eq(1)
      expect(minute.to_i).to eq(54)
      expect(second.round).to eq(20)
      expect(gst.type).to eq(:mean)
    end

    it "returns the Greenwich apparent sidereal time" do
      longitude = Astronoby::Angle.from_degrees(-64)
      date = Date.new(2024, 3, 14)
      time = 24 / 60.0 + 5.23 / 3600.0
      last = described_class.new(
        date: date,
        time: time,
        longitude: longitude,
        type: :apparent
      )

      gast = last.to_gst

      expect(gast.type).to eq(:apparent)
    end
  end
end
