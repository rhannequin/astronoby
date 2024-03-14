# frozen_string_literal: true

RSpec.describe Astronoby::GreenwichSiderealTime do
  describe "::from_utc" do
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 12 - Conversion of UT to Greenwich sidereal time (GST)
    it "computes the GST for 1980-04-22" do
      utc = Time.utc(1980, 4, 22, 14, 36, 51.67)

      gst = described_class.from_utc(utc)
      minute = (gst.time - gst.time.to_i) * 60
      second = (minute - minute.to_i) * 60

      expect(gst.time.to_i).to eq(4)
      expect(minute.to_i).to eq(40)
      expect(second.ceil(4)).to eq(5.2296)
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 12 - Sidereal Time at Greenwich
    it "computes the GST for 1987-04-10" do
      utc = Time.utc(1987, 4, 10, 0, 0, 0)

      gst = described_class.from_utc(utc)
      minute = (gst.time - gst.time.to_i) * 60
      second = (minute - minute.to_i) * 60

      expect(gst.time.to_i).to eq(13)
      expect(minute.to_i).to eq(10)
      expect(second.ceil(4)).to eq(46.3673)
    end

    # Source:
    #  Title: Calculs astronomiques à l'usage des amateurs
    #  Author: Jean Meeus
    #  Edition: Société Astronomique de France
    #  Chapter: 7 - Temps Sidéral à Greenwich
    it "computes the GST for 2014-04-10" do
      utc = Time.utc(2014, 4, 10, 19, 21, 0)

      gst = described_class.from_utc(utc)
      minute = (gst.time - gst.time.to_i) * 60
      second = (minute - minute.to_i) * 60

      expect(gst.time.to_i).to eq(8)
      expect(minute.to_i).to eq(36)
      expect(second.ceil(4)).to eq(46.1279)
    end
  end

  describe "#to_utc" do
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 13 - Conversion of GST to UT
    it "returns the universal coordinates time for 1980-04-22" do
      date = Date.new(1980, 4, 22)
      time = 4 + 40 / 60.0 + 5.23 / 3600.0
      gst = described_class.new(date: date, time: time)

      utc = gst.to_utc

      expect(utc).to eq Time.utc(1980, 4, 22, 14, 36, 52)
    end
  end
end
