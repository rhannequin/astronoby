# frozen_string_literal: true

RSpec.describe Astronoby::Radian do
  let(:instance) { described_class.new(value) }
  let(:value) { described_class::PI }

  describe "#value" do
    subject { instance.value }

    it "returns the angle's numeric value in the current unit" do
      expect(subject).to eq(described_class::PI)
    end
  end

  describe "#to_degrees" do
    subject { instance.to_degrees }

    it "returns a new Degree instance" do
      expect(subject).to be_a(Astronoby::Degree)
    end

    it "converted the degrees value into degrees" do
      expect(subject.value).to eq(180)
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

    context "when ange is positive" do
      let(:value) { described_class::PI / 7r }

      it "converts properly" do
        expect(subject.degrees).to eq(25)
        expect(subject.minutes).to eq(42)
        expect(subject.seconds).to eq(51.42)
      end
    end
  end
end
