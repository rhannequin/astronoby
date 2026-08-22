# frozen_string_literal: true

RSpec.describe Astronoby::DeltaT do
  describe "::at" do
    it "returns the number of seconds between TT and UT for a given Julian Day" do
      epoch = 2437665.5

      delta = described_class.at(epoch).round(2)

      expect(delta).to eq 33.99
      # USNO historic_deltat.data: 33.992
    end

    it "returns the number of seconds between TT and UT for a given Time object" do
      time = Time.utc(1977, 1, 1)

      delta = described_class.at(time).round(2)

      expect(delta).to eq 47.52
      # USNO deltat.data: 47.5214
    end

    it "returns the number of seconds between TT and UT for a given Date object" do
      date = Date.new(1980, 1, 1)

      delta = described_class.at(date).round(2)

      expect(delta).to eq 50.54
      # USNO deltat.data: 50.5387
    end

    context "when the instant is not a supported type" do
      it "raises an error" do
        expect { described_class.at("2024-03-14") }
          .to raise_error(
            Astronoby::IncompatibleArgumentsError,
            "Expected a Numeric, Time, Date or DateTime object, got String"
          )
      end
    end

    context "when the date is before the available range" do
      it "returns 0" do
        date = Date.new(1700, 1, 1)

        delta = described_class.at(date)

        expect(delta).to eq 0
      end
    end

    context "when the date is after the available range" do
      it "returns the last known value" do
        date = Date.new(2200, 1, 1)

        delta = described_class.at(date)

        expect(delta).to eq described_class.at(Date.new(2100, 1, 1))
      end
    end
  end
end
