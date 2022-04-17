# frozen_string_literal: true

RSpec.describe Astronoby::Degree do
  let(:instance) { described_class.new(180) }

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

  describe "#to_radians" do
    subject { instance.to_radians }

    it "returns a new Radian instance" do
      expect(subject).to be_a(Astronoby::Radian)
    end

    it "converted the degrees value into radians" do
      expect(subject.value).to eq(Math::PI)
    end
  end
end
