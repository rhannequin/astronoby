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
end
