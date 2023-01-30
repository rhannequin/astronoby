# frozen_string_literal: true

RSpec.describe Astronoby::Util::Trigonometry do
  describe "::to_radians" do
    it "returns a BigDecimal" do
      expect(described_class.to_radians(3)).to be_an_instance_of(BigDecimal)
    end

    it "returns a converts an degrees angle to a radians one" do
      expect(described_class.to_radians(BigDecimal("180"))).to eq(BigMath.PI(10))
    end
  end

  describe "::to_degrees" do
    it "returns a BigDecimal" do
      expect(described_class.to_degrees(90)).to be_an_instance_of(BigDecimal)
    end

    it "returns a converts an radians angle to a degrees one" do
      expect(described_class.to_degrees(BigMath.PI(10))).to eq(BigDecimal("180"))
    end
  end

  # Source:
  #  Title: Celestial Calculations
  #  Author: J. L. Lawrence
  #  Edition: MIT Press
  #  Chapter: 4 - Orbits and Coordinate Systems
  describe "::adjustement_for_arctangent" do
    it "returns an Angle" do
      adjustement = described_class.adjustement_for_arctangent(
        Astronoby::Angle.as_degrees(0),
        Astronoby::Angle.as_degrees(0),
        Astronoby::Angle.as_degrees(0)
      )

      expect(adjustement).to be_kind_of(Astronoby::Angle)
    end

    context "when term1 is positive and term2 is positive" do
      it "doesn't adjust" do
        initial_angle = Astronoby::Angle.as_degrees(0)
        adjustement = described_class.adjustement_for_arctangent(
          Astronoby::Angle.as_degrees(1),
          Astronoby::Angle.as_degrees(1),
          initial_angle
        )

        expect(adjustement).to eq(initial_angle)
      end
    end

    context "when term1 is positive and term2 is negative" do
      it "adjusts by 180°" do
        adjustement = described_class.adjustement_for_arctangent(
          Astronoby::Angle.as_degrees(1),
          Astronoby::Angle.as_degrees(-1),
          Astronoby::Angle.as_degrees(0)
        )

        expect(adjustement).to eq(Astronoby::Angle.as_degrees(180))
      end
    end

    context "when term1 is negative and term2 is positive" do
      it "adjusts by 360" do
        adjustement = described_class.adjustement_for_arctangent(
          Astronoby::Angle.as_degrees(-1),
          Astronoby::Angle.as_degrees(1),
          Astronoby::Angle.as_degrees(0)
        )

        expect(adjustement).to eq(Astronoby::Angle.as_degrees(360))
      end
    end

    context "when term1 is negative and term2 is negative" do
      it "adjusts by 180" do
        adjustement = described_class.adjustement_for_arctangent(
          Astronoby::Angle.as_degrees(-1),
          Astronoby::Angle.as_degrees(-1),
          Astronoby::Angle.as_degrees(0)
        )

        expect(adjustement).to eq(Astronoby::Angle.as_degrees(180))
      end
    end
  end
end
