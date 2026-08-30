# frozen_string_literal: true

require "timeout"

RSpec.describe Astronoby::RootFinder do
  describe "#roots" do
    it "locates a root to better than a millisecond" do
      root = 2460748.5
      finder = described_class.new(
        value_at: ->(jd) { jd - root },
        period: 1.0,
        samples_per_period: 20
      )

      located = finder.roots(root - 0.53, root + 0.61)

      expect(located.size).to eq(1)
      expect(located.first).to be_within(1e-8).of(root)
    end

    it "finds a root that a sample lands exactly on" do
      root = 2460748.5
      finder = described_class.new(
        value_at: ->(jd) { jd - root },
        period: 1.0,
        samples_per_period: 20
      )

      located = finder.roots(root - 0.5, root + 0.5)

      expect(located).to eq([root])
    end

    it "counts a root a sample lands on only once" do
      root = 2460748.5
      finder = described_class.new(
        value_at: ->(jd) { jd - root },
        period: 1.0,
        samples_per_period: 20
      )

      expect(finder.roots(root - 0.5, root + 0.5).size).to eq(1)
    end

    it "returns roots in time order" do
      first = 2460748.2
      second = 2460748.8
      finder = described_class.new(
        value_at: ->(jd) { (jd - first) * (jd - second) },
        period: 1.0,
        samples_per_period: 40
      )

      located = finder.roots(2460748.0, 2460749.0)

      expect(located.size).to eq(2)
      expect(located).to eq(located.sort)
      expect(located.first).to be_within(1e-6).of(first)
      expect(located.last).to be_within(1e-6).of(second)
    end

    it "terminates when the bracket reaches the resolution of a Float" do
      stub_const("#{described_class}::BISECTION_TOLERANCE_DAYS", 1e-30)
      root = 2460748.5
      finder = described_class.new(
        value_at: ->(jd) { jd - root },
        period: 1.0,
        samples_per_period: 20
      )

      located = nil
      expect {
        Timeout.timeout(5) { located = finder.roots(root - 0.53, root + 0.61) }
      }.not_to raise_error
      expect(located.first).to be_within(1e-6).of(root)
    end
  end
end
