# frozen_string_literal: true

RSpec.describe Astronoby::Epoch do
  describe "::from_time" do
    # Source: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
    it "returns the Julian day number associated with the time" do
      time = Time.utc(1582, 10, 15, 0, 0, 0)

      expect(described_class.from_time(time)).to eq(2299160.5)
    end

    # Source: https://github.com/observerly/polaris
    it "returns the Julian day number associated with the time" do
      time = Time.utc(2021, 5, 14, 0, 0, 0)

      expect(described_class.from_time(time)).to eq(2459348.5)
    end
  end
end
