# frozen_string_literal: true

RSpec.describe Astronoby::Pressure do
  describe "object immutability" do
    it "is frozen" do
      expect(described_class.from_pascals(101_325)).to be_frozen
    end
  end

  describe "::from_pascals" do
    it "returns a Pressure in pascals" do
      pressure = described_class.from_pascals(101_325)

      expect(pressure.pascals).to eq 101_325
    end
  end

  describe "validation" do
    it "accepts a pressure of zero" do
      expect(described_class.from_pascals(0).pascals).to eq 0
    end

    it "raises an error for a negative pressure" do
      expect { described_class.from_pascals(-1) }.to raise_error(
        Astronoby::IncompatibleArgumentsError,
        "Expected a pressure of zero or more, got -1 Pa"
      )
    end
  end

  describe "::from_hectopascals" do
    it "converts hectopascals to pascals" do
      pressure = described_class.from_hectopascals(1013.25)

      expect(pressure.pascals).to eq 101_325
    end
  end

  describe "::from_millibars" do
    it "converts millibars to pascals" do
      pressure = described_class.from_millibars(1013.25)

      expect(pressure.pascals).to eq 101_325
    end
  end

  describe "::standard_atmosphere" do
    it "returns 1013.25 hPa" do
      expect(described_class.standard_atmosphere.hectopascals).to eq 1013.25
    end
  end

  describe "::at_elevation" do
    it "returns the standard atmosphere at sea level" do
      pressure = described_class.at_elevation(
        Astronoby::Distance.zero,
        temperature: Astronoby::Temperature.from_celsius(10)
      )

      expect(pressure).to eq described_class.standard_atmosphere
    end

    # Barometric formula for an isothermal atmosphere:
    # 1013.25 × exp(-9.80665 × 0.0289644 × 1000 / (8.31432 × 283.15)) = 898.08
    it "returns a lower pressure higher up" do
      pressure = described_class.at_elevation(
        Astronoby::Distance.from_meters(1000),
        temperature: Astronoby::Temperature.from_celsius(10)
      )

      expect(pressure.millibars.round(2)).to eq 898.08
    end
  end

  describe "#millibars" do
    it "returns the pressure in millibars" do
      pressure = described_class.from_pascals(101_325)

      expect(pressure.millibars).to eq 1013.25
    end
  end

  describe "equality" do
    it "is equal to the same pressure built from another unit" do
      expect(described_class.from_millibars(1013.25))
        .to eq described_class.from_pascals(101_325)
    end

    it "has the same hash as an equal pressure" do
      expect(described_class.from_millibars(1013.25).hash)
        .to eq described_class.from_pascals(101_325).hash
    end
  end
end
