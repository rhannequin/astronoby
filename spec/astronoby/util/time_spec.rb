# frozen_string_literal: true

RSpec.describe Astronoby::Util::Time do
  describe "::decimal_hour_to_time" do
    it "returns a Time object" do
      date = Date.new
      decimal = 0

      expect(described_class.decimal_hour_to_time(date, 0, decimal)).to be_a Time
    end

    it "converts a decimal time to a Time format" do
      date = Date.new(2024, 3, 14)
      decimal = 12.34

      time = described_class.decimal_hour_to_time(date, 0, decimal)

      expect(time).to eq Time.utc(2024, 3, 14, 12, 20, 24)
    end

    context "when the decimal time is out of range" do
      it "raises an error" do
        expect { described_class.decimal_hour_to_time(Date.new, 0, 25) }
          .to raise_error(
            Astronoby::IncompatibleArgumentsError,
            "Hour must be between 0 and 24, got 25"
          )
      end
    end

    context "when the offset is large enough to change the date" do
      context "when the offset is positive" do
        it "updates the date" do
          date = Date.new(2024, 3, 14)
          offset = "+12:00"
          decimal = 22

          time = described_class.decimal_hour_to_time(date, offset, decimal)

          expect(time.to_date).to eq Date.new(2024, 3, 13)
        end
      end

      context "when the offset is negative" do
        it "updates the date" do
          date = Date.new(2024, 3, 14)
          offset = "-12:00"
          decimal = 2

          time = described_class.decimal_hour_to_time(date, offset, decimal)

          expect(time.to_date).to eq Date.new(2024, 3, 15)
        end
      end
    end
  end

  describe "::terrestrial_universal_time_delta" do
    it "returns the number of seconds between TT and UT for a given Julian Day" do
      epoch = 2437665.5 # 1962-01-01T00:00:00

      delta = described_class.terrestrial_universal_time_delta(epoch).round(2)

      expect(delta).to eq 33.99
      # USNO historic_deltat.data: 33.992
    end

    it "returns the number of seconds between TT and UT for a given Time object" do
      time = Time.utc(1977, 1, 1) # 2443144.5

      delta = described_class.terrestrial_universal_time_delta(time).round(2)

      expect(delta).to eq 47.52
      # USNO deltat.data: 47.5214
    end

    it "returns the number of seconds between TT and UT for a given Date object" do
      date = Date.new(1980, 1, 1) # 2444239.5

      delta = described_class.terrestrial_universal_time_delta(date).round(2)

      expect(delta).to eq 50.54
      # USNO deltat.data: 50.5387
    end

    context "when the date is before 1800" do
      it "returns 0" do
        date = Date.new(1700, 1, 1)

        delta = described_class.terrestrial_universal_time_delta(date)

        expect(delta).to eq 0
      end
    end
  end
end
