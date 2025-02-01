# frozen_string_literal: true

RSpec.describe Astronoby::Vector do
  describe ".new" do
    it "creates a new vector with valid numeric inputs" do
      vector = described_class[1, 2, 3]

      expect(vector.x).to eq(1)
      expect(vector.y).to eq(2)
      expect(vector.z).to eq(3)
    end

    it "freezes the object" do
      vector = described_class[1, 2, 3]

      expect(vector).to be_frozen
    end
  end

  describe "#+" do
    it "adds two vectors" do
      vector1 = described_class[1, 2, 3]
      vector2 = described_class[4, 5, 6]

      result = vector1 + vector2

      expect(result.to_a).to eq([5, 7, 9])
      expect(result).to be_a(described_class)
      expect(result).not_to equal(vector1)
    end
  end

  describe "#-" do
    it "subtracts two vectors" do
      vector1 = described_class[1, 2, 3]
      vector2 = described_class[4, 5, 6]

      result = vector1 - vector2

      expect(result.to_a).to eq([-3, -3, -3])
    end
  end

  describe "#dot" do
    it "calculates dot product correctly" do
      vector1 = described_class[1, 2, 3]
      vector2 = described_class[4, 5, 6]

      result = vector1.dot(vector2)

      expect(result).to eq(32) # (1*4 + 2*5 + 3*6)
    end
  end

  describe "#cross" do
    it "calculates cross product correctly" do
      vector1 = described_class[1, 2, 3]
      vector2 = described_class[4, 5, 6]

      result = vector1.cross(vector2)

      expect(result.to_a).to eq([-3, 6, -3])
    end
  end

  describe "#magnitude" do
    it "calculates the magnitude correctly" do
      vector = described_class[3, 4, 0]

      result = vector.magnitude

      expect(result).to eq(5)
    end
  end

  describe "#[]" do
    it "accesses coordinates by index" do
      vector = described_class[1, 2, 3]

      expect(vector[0]).to eq(1)
      expect(vector[1]).to eq(2)
      expect(vector[2]).to eq(3)
    end
  end

  describe "#to_a" do
    it "returns array representation" do
      vector = described_class[1, 2, 3]

      expect(vector.to_a).to eq([1, 2, 3])
    end
  end

  describe "#inspect and #to_s" do
    it "returns formatted string representation" do
      vector = described_class[1, 2, 3]

      expect(vector.inspect).to eq("Vector[1, 2, 3]")
      expect(vector.to_s).to eq("Vector[1, 2, 3]")
    end
  end

  describe "#hash" do
    it "returns consistent hash values for equal vectors" do
      vector1 = described_class[1, 2, 3]
      vector2 = described_class[1, 2, 3]

      expect(vector1.hash).to eq(vector2.hash)
    end

    it "returns different hash values for different vectors" do
      vector1 = described_class[1, 2, 3]
      vector2 = described_class[4, 5, 6]

      expect(vector1.hash).not_to eq(vector2.hash)
    end
  end

  describe "#==" do
    it "returns true for equal vectors" do
      vector1 = described_class[1, 2, 3]
      vector2 = described_class[1, 2, 3]

      expect(vector1 == vector2).to be(true)
    end

    it "returns false for different vectors" do
      vector1 = described_class[1, 2, 3]
      vector2 = described_class[4, 5, 6]

      expect(vector1 == vector2).to be(false)
    end

    it "returns false for non-vector comparison" do
      vector1 = described_class[1, 2, 3]
      vector2 = described_class[4, 5, 6]

      expect(vector1 == vector2).to be(false)
    end
  end
end
