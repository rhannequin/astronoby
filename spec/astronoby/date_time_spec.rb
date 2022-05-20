# frozen_string_literal: true

RSpec.describe Astronoby::DateTime do
  describe "::new" do
    context "when a full date is provided" do
      it "initializes properly" do
        expect { described_class.new(2000, 1, 1) }.not_to raise_error
      end
    end

    context "when a full date_time is provided" do
      it "initializes properly" do
        expect { described_class.new(2000, 1, 1, 12, 0, 0) }.not_to raise_error
      end
    end

    context "when a partial date is provided" do
      it "raises an ArgumentError" do
        expect { described_class.new(2000) }.to raise_error(ArgumentError)
      end
    end

    context "when an errored date is provided" do
      it "raises an ArgumentError" do
        expect { described_class.new(2000, nil, 1) }.to raise_error(ArgumentError)
      end
    end

    context "when a partial date time is provided" do
      it "raises an ArgumentError" do
        expect { described_class.new(2000, 1, 1, 12) }.to raise_error(ArgumentError)
      end
    end

    context "when an errored date is provided" do
      it "raises an ArgumentError" do
        expect { described_class.new(2000, 1, 1, 12, nil, 42) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#julian_day" do
    # Tests specified in Astronomical Algorithms by Jean Meeus
    # Chapter 7, page 62
    data = [
      {date_time: described_class.new(2000, 1, 1, 12, 0, 0), julian_day: 2451545.0},
      {date_time: described_class.new(1999, 1, 1, 0, 0, 0), julian_day: 2451179.5},
      {date_time: described_class.new(1987, 1, 27), julian_day: 2446822.5},
      {date_time: described_class.new(1987, 6, 19, 12, 0, 0), julian_day: 2446966.0},
      {date_time: described_class.new(1988, 1, 27), julian_day: 2447187.5},
      {date_time: described_class.new(1900, 1, 1), julian_day: 2415020.5},
      {date_time: described_class.new(1600, 1, 1), julian_day: 2305447.5},
      {date_time: described_class.new(1600, 12, 31), julian_day: 2305812.5},
      {date_time: described_class.new(837, 4, 10, 8, 0, 0), julian_day: 2026871.8},
      {date_time: described_class.new(-123, 12, 31), julian_day: 1676496.5},
      {date_time: described_class.new(-122, 1, 1), julian_day: 1676497.5},
      {date_time: described_class.new(-1000, 7, 12, 12, 0, 0), julian_day: 1356001.0},
      {date_time: described_class.new(-1000, 2, 29), julian_day: 1355866.5},
      {date_time: described_class.new(-1001, 8, 17, 21, 40, 0), julian_day: 1355671.4},
      {date_time: described_class.new(-4712, 1, 1, 12, 0, 0), julian_day: 0.0}
    ]

    data.each do |test|
      dt = test[:date_time]

      context "when date_time is #{dt.year}/#{dt.month}/#{dt.day} #{dt.hour}:#{dt.min}:#{dt.sec}" do
        it "returns the expected Julian day #{test[:julian_day]}" do
          expect(dt.julian_day.floor(1)).to eq(test[:julian_day])
        end
      end
    end
  end
end
