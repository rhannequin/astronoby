# frozen_string_literal: true

RSpec.describe Astronoby::Rotation do
  describe ".about_x" do
    it "rotates a vector about the x-axis (passive convention)" do
      matrix = described_class.about_x(Astronoby::Angle.from_degrees(90))

      rotated = matrix * Vector[0, 1, 0]

      expect(rotated[0].round(10)).to eq(0)
      expect(rotated[1].round(10)).to eq(0)
      expect(rotated[2].round(10)).to eq(-1)
    end
  end

  describe ".about_y" do
    it "rotates a vector about the y-axis (passive convention)" do
      matrix = described_class.about_y(Astronoby::Angle.from_degrees(90))

      rotated = matrix * Vector[0, 0, 1]

      expect(rotated[0].round(10)).to eq(-1)
      expect(rotated[1].round(10)).to eq(0)
      expect(rotated[2].round(10)).to eq(0)
    end
  end

  describe ".about_z" do
    it "rotates a vector about the z-axis (passive convention)" do
      matrix = described_class.about_z(Astronoby::Angle.from_degrees(90))

      rotated = matrix * Vector[1, 0, 0]

      expect(rotated[0].round(10)).to eq(0)
      expect(rotated[1].round(10)).to eq(-1)
      expect(rotated[2].round(10)).to eq(0)
    end
  end
end
