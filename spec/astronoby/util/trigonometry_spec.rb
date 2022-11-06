# frozen_string_literal: true

RSpec.describe Astronoby::Util::Trigonometry do
  describe "::to_radians" do
    it "returns a BigDecimal" do
      expect(described_class.to_radians(3)).to be_an_instance_of(BigDecimal)
    end

    it "returns a converts an degrees angle to a radians one" do
      expect(described_class.to_radians(BigDecimal("180"))).to eq(Math::PI)
    end
  end

  describe "::to_degrees" do
    it "returns a BigDecimal" do
      expect(described_class.to_degrees(90)).to be_an_instance_of(BigDecimal)
    end

    it "returns a converts an radians angle to a degrees one" do
      expect(described_class.to_degrees(Math::PI)).to eq(BigDecimal("180"))
    end
  end
end
