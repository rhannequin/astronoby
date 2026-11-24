# frozen_string_literal: true

RSpec.describe Astronoby::Temperature do
  describe "object immutability" do
    it "is frozen" do
      expect(described_class.from_kelvins(283.15)).to be_frozen
    end
  end

  describe "::from_kelvins" do
    it "returns a Temperature in kelvins" do
      temperature = described_class.from_kelvins(283.15)

      expect(temperature.kelvins).to eq 283.15
    end
  end

  describe "validation" do
    it "raises an error at absolute zero" do
      expect { described_class.from_kelvins(0) }.to raise_error(
        Astronoby::IncompatibleArgumentsError,
        "Expected a temperature above absolute zero, got 0 K"
      )
    end

    it "raises an error below absolute zero" do
      expect { described_class.from_celsius(-300) }
        .to raise_error(Astronoby::IncompatibleArgumentsError)
    end
  end

  describe "::from_celsius" do
    it "converts degrees Celsius to kelvins" do
      temperature = described_class.from_celsius(10)

      expect(temperature.kelvins).to eq 283.15
    end
  end

  describe "#celsius" do
    it "returns the temperature in degrees Celsius" do
      temperature = described_class.from_kelvins(273.15)

      expect(temperature.celsius).to eq 0
    end
  end

  describe "equality" do
    it "is equal to the same temperature built from another unit" do
      expect(described_class.from_celsius(0))
        .to eq described_class.from_kelvins(273.15)
    end

    it "has the same hash as an equal temperature" do
      expect(described_class.from_celsius(0).hash)
        .to eq described_class.from_kelvins(273.15).hash
    end
  end

  describe "comparison" do
    it "orders temperatures" do
      expect(described_class.from_celsius(-15))
        .to be < described_class.from_celsius(25)
    end
  end
end
