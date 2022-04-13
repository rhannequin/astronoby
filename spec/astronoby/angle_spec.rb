# frozen_string_literal: true

RSpec.describe Astronoby::Angle do
  describe "#to_degrees" do
    subject { described_class.new(angle_value, unit: unit).to_degrees }

    context "when angle is already in degrees" do
      let(:angle_value) { 180 }
      let(:unit) { described_class::DEGREES }

      it "returns a value in the same type as provided" do
        expect(subject.class).to eq angle_value.class
      end

      it "returns the angle's value in degrees" do
        expect(subject).to(eq 180)
      end
    end

    context "when angle is in radians" do
      let(:angle_value) { Math::PI }
      let(:unit) { described_class::RADIANS }

      it "returns a rational" do
        expect(subject).to be_a Rational
      end

      it "returns the angle's value in degrees" do
        expect(subject).to eq 180r
      end
    end
  end

  describe "#to_radians" do
    subject { described_class.new(angle_value, unit: unit).to_radians }

    context "when angle is already in radians" do
      let(:angle_value) { Math::PI }
      let(:unit) { described_class::RADIANS }

      it "returns a value in the same type as provided" do
        expect(subject.class).to eq angle_value.class
      end

      it "returns the angle's value in radians" do
        expect(subject).to(eq Math::PI)
      end
    end

    context "when angle is in degrees" do
      let(:angle_value) { 180 }
      let(:unit) { described_class::DEGREES }

      it "returns a rational" do
        expect(subject).to be_a Rational
      end

      it "returns the angle's value in radians" do
        expect(subject).to eq Math::PI
      end
    end
  end
end
