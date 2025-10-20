# frozen_string_literal: true

RSpec.describe Astronoby::GreenwichSiderealTime do
  describe "::from_utc" do
    context "when type is :mean (default)" do
      # Source:
      #  Title: Practical Astronomy with your Calculator or Spreadsheet
      #  Authors: Peter Duffett-Smith and Jonathan Zwart
      #  Edition: Cambridge University Press
      #  Chapter: 12 - Conversion of UT to Greenwich sidereal time (GST)
      it "computes the GMST for 1980-04-22" do
        utc = Time.utc(1980, 4, 22, 14, 36, 51.67)

        gmst = described_class.from_utc(utc)
        minute = (gmst.time - gmst.time.to_i) * 60
        second = (minute - minute.to_i) * 60

        expect(gmst.time.to_i).to eq(4)
        expect(minute.to_i).to eq(40)
        expect(second.ceil(4)).to eq(5.2296)
        expect(gmst.type).to eq(:mean)
        expect(gmst).to be_mean
        expect(gmst).not_to be_apparent
        # Skyfield: 4h 40m 5.5947s
      end

      # Source:
      #  Title: Astronomical Algorithms
      #  Author: Jean Meeus
      #  Edition: 2nd edition
      #  Chapter: 12 - Sidereal Time at Greenwich
      it "computes the GMST for 1987-04-10" do
        utc = Time.utc(1987, 4, 10, 0, 0, 0)

        gmst = described_class.from_utc(utc)
        minute = (gmst.time - gmst.time.to_i) * 60
        second = (minute - minute.to_i) * 60

        expect(gmst.time.to_i).to eq(13)
        expect(minute.to_i).to eq(10)
        expect(second.ceil(4)).to eq(46.3673)
        expect(gmst.type).to eq(:mean)
        # Skyfield: 13h 10m 46.0782s
      end

      # Source:
      #  Title: Calculs astronomiques à l'usage des amateurs
      #  Author: Jean Meeus
      #  Edition: Société Astronomique de France
      #  Chapter: 7 - Temps Sidéral à Greenwich
      it "computes the GMST for 2014-04-10" do
        utc = Time.utc(2014, 4, 10, 19, 21, 0)

        gmst = described_class.from_utc(utc)
        minute = (gmst.time - gmst.time.to_i) * 60
        second = (minute - minute.to_i) * 60

        expect(gmst.time.to_i).to eq(8)
        expect(minute.to_i).to eq(36)
        expect(second.ceil(4)).to eq(46.1279)
        expect(gmst.type).to eq(:mean)
        # Skyfield: 8h 36m 45.9086s
      end
    end

    context "when type is :apparent" do
      it "computes the GAST for 1987-04-10" do
        utc = Time.utc(1987, 4, 10, 0, 0, 0)

        gast = described_class.from_utc(utc, type: :apparent)
        minute = (gast.time - gast.time.to_i) * 60
        second = (minute - minute.to_i) * 60

        expect(gast.time.to_i).to eq(13)
        expect(minute.to_i).to eq(10)
        expect(second.ceil(4)).to eq(46.136)
        expect(gast.type).to eq(:apparent)
        # Skyfield: 13h 10m 45.8470s
      end

      it "computes the GAST for 2014-04-10" do
        utc = Time.utc(2014, 4, 10, 19, 21, 0)

        gast = described_class.from_utc(utc, type: :apparent)
        minute = (gast.time - gast.time.to_i) * 60
        second = (minute - minute.to_i) * 60

        expect(gast.time.to_i).to eq(8)
        expect(minute.to_i).to eq(36)
        expect(second.ceil(4)).to eq(46.6127)
        expect(gast.type).to eq(:apparent)
        # Skyfield: 8h 36m 46.3933s
      end
    end

    context "with invalid type" do
      it "raises an error" do
        utc = Time.utc(2014, 4, 10, 19, 21, 0)

        expect { described_class.from_utc(utc, type: :invalid) }
          .to raise_error(
            ArgumentError,
            "Invalid type: invalid. Must be one of [:mean, :apparent]"
          )
      end
    end
  end

  describe "#to_utc" do
    context "for mean sidereal time" do
      # Source:
      #  Title: Practical Astronomy with your Calculator or Spreadsheet
      #  Authors: Peter Duffett-Smith and Jonathan Zwart
      #  Edition: Cambridge University Press
      #  Chapter: 13 - Conversion of GST to UT
      it "returns the universal coordinates time for 1980-04-22" do
        date = Date.new(1980, 4, 22)
        time = 4 + 40 / 60.0 + 5.23 / 3600.0
        gst = described_class.new(date: date, time: time, type: :mean)

        utc = gst.to_utc

        expect(utc).to eq Time.utc(1980, 4, 22, 14, 36, 52)
      end
    end

    context "for apparent sidereal time" do
      it "raises an error" do
        date = Date.new(1980, 4, 22)
        time = 4

        gast = described_class.new(date: date, time: time, type: :apparent)

        expect { gast.to_utc }
          .to raise_error(
            NotImplementedError,
            "UTC conversion only supported for mean sidereal time"
          )
      end
    end
  end
end
