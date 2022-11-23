# frozen_string_literal: true

RSpec.describe Astronoby::Angle do
  describe "::as_degrees" do
    subject { described_class.as_degrees(180) }

    it "returns an Angle object" do
      expect(subject).to be_a(described_class)
    end

    it "returns an Angle in Degree" do
      expect(subject).to be_a(Astronoby::Degree)
    end
  end

  describe "::as_radians" do
    subject { described_class.as_radians(described_class::PI) }

    it "returns an Angle object" do
      expect(subject).to be_a(described_class)
    end

    it "returns an Angle in Radian" do
      expect(subject).to be_a(Astronoby::Radian)
    end
  end

  describe "#==" do
    context "when the two angles have the same value and same unit" do
      it "returns true" do
        expect(described_class.as_degrees(1)).to(
          eq(described_class.as_degrees(1))
        )
      end
    end

    context "when the two angles have the same value and different units" do
      it "returns false" do
        expect(described_class.as_degrees(1)).not_to(
          eq(described_class.as_radians(1))
        )
      end
    end

    context "when the two angles have different values and the same unit" do
      it "returns false" do
        expect(described_class.as_degrees(1)).not_to(
          eq(described_class.as_degrees(2))
        )
      end
    end

    context "when the two angles have different values and different units" do
      it "returns false" do
        expect(described_class.as_degrees(1)).not_to(
          eq(described_class.as_radians(2))
        )
      end
    end
  end
end
