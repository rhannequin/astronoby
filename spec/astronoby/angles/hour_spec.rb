# frozen_string_literal: true

require "bigdecimal/util"

RSpec.describe Astronoby::Hour do
  describe "#to_hours" do
    it "returns itself" do
      angle = described_class.new(1.234)

      expect(angle).to be(angle)
    end
  end

  describe "#to_degrees" do
    it "returns a new Degree instance" do
      angle = described_class.new(1)

      expect(angle.to_degrees).to be_a(Astronoby::Degree)
    end

    it "converted the degrees value into radians" do
      angle = described_class.new(23)

      expect(angle.to_degrees.value).to eq(345)
    end
  end

  describe "#to_radians" do
    it "returns a new Radian instance" do
      angle = described_class.new(1)

      expect(angle.to_radians).to be_a(Astronoby::Radian)
    end

    it "converted the hours value into radians" do
      angle = described_class.new(12)

      expect(angle.to_radians.value).to(
        eq described_class::PI.ceil(described_class::PRECISION)
      )
    end
  end
end
