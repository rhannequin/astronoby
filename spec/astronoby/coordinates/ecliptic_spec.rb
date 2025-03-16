# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Ecliptic do
  describe "::zero" do
    it "returns a new instance with zero angles" do
      coordinates = described_class.zero

      expect(coordinates.latitude).to eq(Astronoby::Angle.zero)
      expect(coordinates.longitude).to eq(Astronoby::Angle.zero)
    end
  end
end
