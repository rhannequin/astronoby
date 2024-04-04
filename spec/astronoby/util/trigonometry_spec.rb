# frozen_string_literal: true

RSpec.describe Astronoby::Util::Trigonometry do
  # Source:
  #  Title: Celestial Calculations
  #  Author: J. L. Lawrence
  #  Edition: MIT Press
  #  Chapter: 4 - Orbits and Coordinate Systems
  describe "::adjustement_for_arctangent" do
    it "returns an Angle" do
      adjustement = described_class.adjustement_for_arctangent(
        Astronoby::Angle.zero,
        Astronoby::Angle.zero,
        Astronoby::Angle.zero
      )

      expect(adjustement).to be_kind_of(Astronoby::Angle)
    end

    context "when term1 is positive and term2 is positive" do
      it "doesn't adjust" do
        initial_angle = Astronoby::Angle.zero
        adjustement = described_class.adjustement_for_arctangent(
          Astronoby::Angle.from_degrees(1),
          Astronoby::Angle.from_degrees(1),
          initial_angle
        )

        expect(adjustement).to eq(initial_angle)
      end
    end

    context "when term1 is positive and term2 is negative" do
      it "adjusts by 180°" do
        adjustement = described_class.adjustement_for_arctangent(
          Astronoby::Angle.from_degrees(1),
          Astronoby::Angle.from_degrees(-1),
          Astronoby::Angle.zero
        )

        expect(adjustement.radians).to eq Math::PI
      end
    end

    context "when term1 is negative and term2 is positive" do
      it "adjusts by 360°" do
        adjustement = described_class.adjustement_for_arctangent(
          Astronoby::Angle.from_degrees(-1),
          Astronoby::Angle.from_degrees(1),
          Astronoby::Angle.from_degrees(-90)
        )

        expect(adjustement.degrees).to eq 270
      end
    end

    context "when term1 is negative and term2 is negative" do
      it "adjusts by 180°" do
        adjustement = described_class.adjustement_for_arctangent(
          Astronoby::Angle.from_degrees(-1),
          Astronoby::Angle.from_degrees(-1),
          Astronoby::Angle.zero
        )

        expect(adjustement.radians).to eq Math::PI
      end
    end
  end
end
