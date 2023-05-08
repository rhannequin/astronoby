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

  describe "::as_dms" do
    it "returns an Angle object" do
      angle = described_class.as_dms(180, 15, 10)
      expect(angle).to be_a(described_class)
    end

    it "returns an Angle in Degree" do
      angle = described_class.as_dms(180, 15, 10)
      expect(angle).to be_a(Astronoby::Degree)
    end

    it "converts HMS format into decimal format" do
      angle = described_class.as_dms(180, 15, 45)
      expect(angle.value).to eq(180.2625)
    end

    it "converts HMS format into decimal format when negative" do
      angle = described_class.as_dms(-180, 15, 45)
      expect(angle.value).to eq(-180.2625)
    end
  end

  describe "::as_hms" do
    it "returns an Angle object" do
      angle = described_class.as_hms(12, 15, 10)
      expect(angle).to be_a(described_class)
    end

    it "returns an Angle in Hour" do
      angle = described_class.as_hms(12, 15, 10)
      expect(angle).to be_a(Astronoby::Hour)
    end

    it "converts HMS format into decimal format" do
      angle = described_class.as_hms(12, 15, 45)
      expect(angle.value).to eq(12.2625)
    end
  end

  describe "::as_hours" do
    subject { described_class.as_hours(180) }

    it "returns an Angle object" do
      expect(subject).to be_a(described_class)
    end

    it "returns an Angle in Hour" do
      expect(subject).to be_a(Astronoby::Hour)
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
