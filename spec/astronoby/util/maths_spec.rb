# frozen_string_literal: true

RSpec.describe Astronoby::Util::Maths do
  describe ".dot_product" do
    it "returns the dot product of two arrays" do
      a = [1, 2, 3]
      b = [4, 5, 6]

      expect(described_class.dot_product(a, b)).to eq(32)
    end
  end

  describe ".quadratic_maximum" do
    it "finds the maximum of a simple parabola" do
      # Parabola: y = -x² + 10x - 20 (maximum at x=5, y=5)
      t1 = Time.at(3)  # Before maximum
      t2 = Time.at(5)  # At maximum
      t3 = Time.at(7)  # After maximum
      y1 = -3**2 + 10 * 3 - 20  # -9 + 30 - 20 = 1
      y2 = -5**2 + 10 * 5 - 20  # -25 + 50 - 20 = 5
      y3 = -7**2 + 10 * 7 - 20  # -49 + 70 - 20 = 1

      result = described_class.quadratic_maximum(t1, t2, t3, y1, y2, y3)

      expect(result.to_f).to be_within(0.001).of(t2.to_f)
    end

    it "finds the maximum when it's between input points" do
      # Parabola: y = -x² + 8x - 12 (maximum at x=4, y=4)
      t1 = Time.at(2)
      t2 = Time.at(5)
      t3 = Time.at(7)
      y1 = -2**2 + 8 * 2 - 12  # -4 + 16 - 12 = 0
      y2 = -5**2 + 8 * 5 - 12  # -25 + 40 - 12 = 3
      y3 = -7**2 + 8 * 7 - 12  # -49 + 56 - 12 = -5

      result = described_class.quadratic_maximum(t1, t2, t3, y1, y2, y3)

      expect(result.to_f).to be_within(0.001).of(Time.at(4).to_f)
    end

    it "handles steep parabolas correctly" do
      # Parabola: y = -100x² + 1000x - 2480 (maximum at x=5, y=30)
      t1 = Time.at(4.9)
      t2 = Time.at(5.0)
      t3 = Time.at(5.1)
      y1 = -100 * 4.9**2 + 1000 * 4.9 - 2480  # 29.0
      y2 = -100 * 5.0**2 + 1000 * 5.0 - 2480  # 30.0
      y3 = -100 * 5.1**2 + 1000 * 5.1 - 2480  # 29.0

      result = described_class.quadratic_maximum(t1, t2, t3, y1, y2, y3)

      expect(result.to_f).to be_within(0.001).of(t2.to_f)
    end

    it "handles flat parabolas correctly" do
      # Parabola: y = -0.01x² + 0.1x + 5 (maximum at x=5, y=5.25)
      t1 = Time.at(0)
      t2 = Time.at(5)
      t3 = Time.at(10)
      y1 = -0.01 * 0**2 + 0.1 * 0 + 5    # 5.0
      y2 = -0.01 * 5**2 + 0.1 * 5 + 5    # 5.25
      y3 = -0.01 * 10**2 + 0.1 * 10 + 5  # 5.0

      result = described_class.quadratic_maximum(t1, t2, t3, y1, y2, y3)

      expect(result.to_f).to be_within(0.001).of(Time.at(5).to_f)
    end

    it "works with unevenly spaced time points" do
      # Parabola: y = -x² + 6x - 5 (maximum at x=3, y=4)
      t1 = Time.at(1)
      t2 = Time.at(4)   # Further from t1 than t3
      t3 = Time.at(5)   # Closer to t2 than t1
      y1 = -1**2 + 6 * 1 - 5  # -1 + 6 - 5 = 0
      y2 = -4**2 + 6 * 4 - 5  # -16 + 24 - 5 = 3
      y3 = -5**2 + 6 * 5 - 5  # -25 + 30 - 5 = 0

      result = described_class.quadratic_maximum(t1, t2, t3, y1, y2, y3)

      expect(result.to_f).to be_within(0.001).of(Time.at(3).to_f)
    end

    it "finds maximum outside the range of input points" do
      # Parabola: y = -0.5x² + 6x - 10 (maximum at x=6, y=8)
      t1 = Time.at(2)
      t2 = Time.at(3)
      t3 = Time.at(4)  # All points before the maximum
      y1 = -0.5 * 2**2 + 6 * 2 - 10  # -2 + 12 - 10 = 0
      y2 = -0.5 * 3**2 + 6 * 3 - 10  # -4.5 + 18 - 10 = 3.5
      y3 = -0.5 * 4**2 + 6 * 4 - 10  # -8 + 24 - 10 = 6

      result = described_class.quadratic_maximum(t1, t2, t3, y1, y2, y3)

      expect(result.to_f).to be_within(0.001).of(Time.at(6).to_f)
    end

    it "handles near-linear relationships gracefully" do
      # Near-linear: y = -0.001x² + x + 10 (very small quadratic term)
      t1 = Time.at(0)
      t2 = Time.at(100)
      t3 = Time.at(200)
      y1 = -0.001 * 0**2 + 0 + 10      # 10
      y2 = -0.001 * 100**2 + 100 + 10  # -10 + 100 + 10 = 100
      y3 = -0.001 * 200**2 + 200 + 10  # -40 + 200 + 10 = 170

      result = described_class.quadratic_maximum(t1, t2, t3, y1, y2, y3)

      expect(result.to_f).to be_within(1.0).of(Time.at(500).to_f)
    end

    it "handles upward-opening parabolas by returning the middle point" do
      # Upward parabola: y = x² - 6x + 10 (minimum at x=3, y=1)
      t1 = Time.at(1)
      t2 = Time.at(3)  # At the minimum
      t3 = Time.at(5)
      y1 = 1**2 - 6 * 1 + 10  # 1 - 6 + 10 = 5
      y2 = 3**2 - 6 * 3 + 10  # 9 - 18 + 10 = 1
      y3 = 5**2 - 6 * 5 + 10  # 25 - 30 + 10 = 5

      result = described_class.quadratic_maximum(t1, t2, t3, y1, y2, y3)

      expect(result.to_f).to eq(t2.to_f)
    end

    it "handles non-symmetric altitude patterns" do
      # Simulate an object that rises quickly but sets slowly
      morning = Time.utc(2023, 3, 21, 8, 0, 0)
      peak = Time.utc(2023, 3, 21, 13, 0, 0)  # Peak is closer to afternoon
      evening = Time.utc(2023, 3, 21, 20, 0, 0)
      morning_alt = 20.0
      peak_alt = 70.0
      evening_alt = 10.0

      result = described_class.quadratic_maximum(
        morning,
        peak,
        evening,
        morning_alt,
        peak_alt,
        evening_alt
      )

      expect(result.to_f).to be_within(2700).of(peak.to_f)  # Within 45 minutes
    end
  end

  describe ".linear_interpolate" do
    it "interpolates correctly with a positive slope" do
      result = described_class.linear_interpolate(0, 10, 0, 10, 5)

      expect(result).to eq(5.0)
    end

    it "interpolates correctly with a negative slope" do
      result = described_class.linear_interpolate(0, 10, 10, 0, 5)

      expect(result).to eq(5.0)
    end

    it "finds the x-intercept when no target_y is provided" do
      result = described_class.linear_interpolate(5, 15, 10, -10)

      expect(result).to eq(10.0)
    end

    it "extrapolates correctly beyond the given points" do
      result = described_class.linear_interpolate(0, 10, 0, 10, 15)

      expect(result).to eq(15.0)
    end

    it "handles horizontal lines appropriately" do
      result = described_class.linear_interpolate(5, 15, 10, 10, 10)

      expect(result).to be_between(5, 15).inclusive

      expect {
        described_class.linear_interpolate(5, 15, 10, 10, 20)
      }.not_to raise_error
    end

    it "handles nearly vertical lines with precision" do
      result = described_class.linear_interpolate(10, 10.001, 0, 100, 50)

      expect(result).to be_within(0.0001).of(10.0005)
    end

    it "handles nearly horizontal lines with precision" do
      result = described_class.linear_interpolate(0, 1000, 5, 5.001, 5.0005)

      expect(result).to be_within(1.0).of(500)
    end

    it "handles interpolation with large numbers" do
      result = described_class.linear_interpolate(
        1600000000, 1600086400,  # 1 day apart in Unix time
        100, 200,                # Values changing over that day
        150                      # Target value
      )

      expected = 1600000000 + (1600086400 - 1600000000) / 2.0
      expect(result).to be_within(0.001).of(expected)
    end

    it "handles interpolation with small fractional numbers" do
      result = described_class.linear_interpolate(1, 2, 0.0001, 0.0002, 0.00015)

      expect(result).to be_within(0.0000001).of(1.5)
    end

    it "maintains precision for values near zero" do
      result = described_class.linear_interpolate(10, 20, -0.0001, 0.0001, 0)

      expect(result).to be_within(0.0000001).of(15)
    end

    it "works correctly with reversed point order" do
      result1 = described_class.linear_interpolate(0, 10, 0, 10, 5)
      result2 = described_class.linear_interpolate(10, 0, 10, 0, 5)

      expect(result1).to eq(result2)
    end

    it "returns the correct x when target_y equals an endpoint y value" do
      result1 = described_class.linear_interpolate(5, 10, 0, 5, 0)
      expect(result1).to eq(5)

      result2 = described_class.linear_interpolate(5, 10, 0, 5, 5)
      expect(result2).to eq(10)
    end

    it "handles vertical lines appropriately" do
      # When x1 = x2 but y1 ≠ y2, no value of x can map to an intermediate y
      expect {
        result = described_class.linear_interpolate(5, 5, 0, 10, 5)
        expect(result).to eq(5)
      }.not_to raise_error
    end
  end

  describe ".linspace" do
    it "generates 50 evenly spaced values by default" do
      result = described_class.linspace(0, 1)

      expect(result.length).to eq(50)
      expect(result.first).to eq(0.0)
      expect(result.last).to eq(1.0)
    end

    it "generates the specified number of evenly spaced values" do
      result = described_class.linspace(0, 1, 5)

      expect(result).to eq([0.0, 0.25, 0.5, 0.75, 1.0])
    end

    it "works with negative values" do
      result = described_class.linspace(-1, -5, 5)

      expect(result).to eq([-1.0, -2.0, -3.0, -4.0, -5.0])
    end

    it "handles floating point values correctly" do
      result = described_class.linspace(0.5, 1.5, 3)

      expect(result).to eq([0.5, 1.0, 1.5])
    end

    context "when the endpoint is specified" do
      it "excludes it" do
        result = described_class.linspace(0, 1, 8, false)

        expect(result).to eq([0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875])
      end
    end

    context "when num is 1" do
      it "returns an array with only the start value" do
        result = described_class.linspace(42, 100, 1)

        expect(result).to eq([42])
      end
    end

    context "when num is less than 1" do
      it "raises an error" do
        expect { described_class.linspace(0, 1, 0) }
          .to raise_error(ArgumentError, "Number of samples must be at least 1")
      end
    end
  end
end
