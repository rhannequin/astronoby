# frozen_string_literal: true

RSpec.describe Astronoby::Obliquity do
  describe "::for_epoch" do
    it "returns an angle" do
      obliquity = described_class.for_epoch(Astronoby::Epoch::J2000).value

      expect(obliquity).to be_kind_of(Astronoby::Angle)
    end

    it "returns the obliquity angle for standard epoch" do
      expect(described_class.for_epoch(Astronoby::Epoch::J2000).value).to(
        eq(Astronoby::Angle.as_degrees(23.4392794))
      )
    end

    it "returns the obliquity angle for epoch 1950" do
      expect(described_class.for_epoch(Astronoby::Epoch::J1950).value).to(
        eq(Astronoby::Angle.as_degrees(23.445784589093))
      )
    end
  end
end
