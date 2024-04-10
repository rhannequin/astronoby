# frozen_string_literal: true

RSpec.describe Astronoby::Util::Time do
  describe "::decimal_hour_to_time" do
    it "returns a Time object" do
      date = Date.new
      decimal = 0

      expect(described_class.decimal_hour_to_time(date, decimal)).to be_a Time
    end

    it "converts a decimal time to a Time format" do
      date = Date.new(2024, 3, 14)
      decimal = 12.34

      time = described_class.decimal_hour_to_time(date, decimal)

      expect(time).to eq Time.utc(2024, 3, 14, 12, 20, 24)
    end

    context "when the decimal time is out of range" do
      it "raises an error" do
        expect { described_class.decimal_hour_to_time(Date.new, 25) }
          .to raise_error(
            Astronoby::IncompatibleArgumentsError,
            "Hour must be between 0 and 24, got 25"
          )
      end
    end
  end
end
