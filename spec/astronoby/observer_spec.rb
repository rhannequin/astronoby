# frozen_string_literal: true

RSpec.describe Astronoby::Observer do
  describe "#pressure" do
    it "returns the computed pression in millibars" do
      latitude = Astronoby::Angle.from_degrees(0)
      longitude = Astronoby::Angle.from_degrees(0)
      elevation = 100
      temperature = 273.15 + 10

      pressure = described_class.new(
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        temperature: temperature
      ).pressure

      expect(pressure.ceil(4)).to eq 1001.0982
    end

    context "when elevation and temperature are not provided" do
      it "returns the computed pression in millibars" do
        latitude = Astronoby::Angle.from_degrees(0)
        longitude = Astronoby::Angle.from_degrees(0)

        pressure = described_class
          .new(latitude: latitude, longitude: longitude)
          .pressure

        expect(pressure).to eq described_class::PRESSURE_AT_SEA_LEVEL
      end
    end
  end
end
