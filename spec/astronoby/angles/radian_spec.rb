# frozen_string_literal: true

RSpec.describe Astronoby::Radian do
  let(:instance) { described_class.new(value) }
  let(:value) { described_class::PI }

  describe "#value" do
    subject { instance.value }

    it "returns the angle's numeric value in the current unit" do
      expect(instance.value).to eq(described_class::PI.ceil(described_class::PRECISION))
    end
  end

  describe "#to_degrees" do
    subject { instance.to_degrees }

    it "returns a new Degree instance" do
      expect(subject).to be_a(Astronoby::Degree)
    end

    it "converted the degrees value into degrees" do
      expect(subject.value).to be_within(0.1).of(180)
    end
  end

  describe "#to_hours" do
    it "returns a new Hour instance" do
      angle = described_class.new(1)

      expect(angle.to_hours).to be_a(Astronoby::Hour)
    end

    it "converted the degrees value into degrees" do
      angle = described_class.new(
        described_class::PI.ceil(described_class::PRECISION)
      )

      expect(angle.to_hours.value).to be_within(0.1).of(12)
    end
  end

  describe "#to_radians" do
    subject { instance.to_radians }

    it "returns itself" do
      expect(subject).to eq(instance)
    end
  end

  describe "#to_dms" do
    subject { instance.to_dms }

    it "returns an new Dms instance" do
      expect(subject).to be_a(Astronoby::Dms)
    end

    context "when angle is positive" do
      let(:value) { described_class::PI / 7r }

      it "converts properly" do
        expect(subject.sign).to eq("+")
        expect(subject.degrees).to eq(25)
        expect(subject.minutes).to eq(42)
        expect(subject.seconds).to eq(51.4285)
      end
    end
  end
end
