# frozen_string_literal: true

RSpec.describe Astronoby::Libration do
  describe "#longitude" do
    it "returns the libration in longitude" do
      longitude = Astronoby::Angle.from_degrees(-1.23)
      libration = described_class.new(
        longitude: longitude,
        latitude: Astronoby::Angle.from_degrees(4.20)
      )

      expect(libration.longitude).to eq(longitude)
    end
  end

  describe "#latitude" do
    it "returns the libration in latitude" do
      latitude = Astronoby::Angle.from_degrees(4.20)
      libration = described_class.new(
        longitude: Astronoby::Angle.from_degrees(-1.23),
        latitude: latitude
      )

      expect(libration.latitude).to eq(latitude)
    end
  end
end
