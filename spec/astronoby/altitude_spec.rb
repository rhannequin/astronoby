# frozen_string_literal: true

RSpec.describe Astronoby::Altitude do
  describe "::apparent" do
    it "returns an altitude with refraction included" do
      altitude = described_class.apparent(degrees: 5)

      expect(altitude.angle).to eq(Astronoby::Angle.from_degrees(5))
      expect(altitude).to be_apparent
    end
  end

  describe "::true" do
    it "returns a geometric altitude" do
      altitude = described_class.true(degrees: -6)

      expect(altitude.angle).to eq(Astronoby::Angle.from_degrees(-6))
      expect(altitude).not_to be_apparent
    end
  end

  describe "#==" do
    it "is equal to an altitude with the same angle and kind" do
      expect(described_class.apparent(degrees: 5))
        .to eq(described_class.apparent(degrees: 5))
    end

    it "is not equal to the same angle of the other kind" do
      expect(described_class.apparent(degrees: 5))
        .not_to eq(described_class.true(degrees: 5))
    end
  end

  describe "#hash" do
    it "is the same for equal altitudes" do
      expect(described_class.true(degrees: 5).hash)
        .to eq(described_class.true(degrees: 5).hash)
    end
  end

  describe "#inspect" do
    it "shows the kind and the angle" do
      expect(described_class.apparent(degrees: 5).inspect)
        .to eq("#<Astronoby::Altitude apparent 5.0°>")
    end
  end
end
