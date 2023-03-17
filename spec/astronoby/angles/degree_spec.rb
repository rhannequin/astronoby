# frozen_string_literal: true

require "bigdecimal/util"

RSpec.describe Astronoby::Degree do
  let(:instance) { described_class.new(value) }
  let(:value) { 180 }

  describe "#value" do
    subject { instance.value }

    it "returns the angle's numeric value in the current unit" do
      expect(subject).to eq(180)
    end
  end

  describe "#to_degrees" do
    subject { instance.to_degrees }

    it "returns itself" do
      expect(subject).to eq(instance)
    end
  end

  describe "#to_hours" do
    it "returns a new Hour instance" do
      angle = described_class.new(1)

      expect(angle.to_hours).to be_a(Astronoby::Hour)
    end

    it "converted the degrees value into hours" do
      angle = described_class.new(330)

      expect(angle.to_hours.value).to eq(22)
    end
  end

  describe "#to_radians" do
    subject { instance.to_radians }

    it "returns a new Radian instance" do
      expect(subject).to be_a(Astronoby::Radian)
    end

    it "converted the degrees value into radians" do
      expect(subject.value).to eq(described_class::PI.ceil(described_class::PRECISION))
    end
  end

  describe "#to_dms" do
    subject { instance.to_dms }

    it "returns an new Dms instance" do
      expect(subject).to be_a(Astronoby::Dms)
    end

    context "when ange is positive" do
      let(:value) { BigDecimal("10.2958") }

      it "converts properly" do
        expect(subject.degrees).to eq(10)
        expect(subject.minutes).to eq(17)
        expect(subject.seconds).to eq(44.88)
      end
    end
  end
end
