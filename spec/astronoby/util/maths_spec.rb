# frozen_string_literal: true

RSpec.describe Astronoby::Util::Maths do
  describe ".dot_product" do
    it "returns the dot product of two arrays" do
      a = [1, 2, 3]
      b = [4, 5, 6]

      expect(described_class.dot_product(a, b)).to eq(32)
    end
  end
end
