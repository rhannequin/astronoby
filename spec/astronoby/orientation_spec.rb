# frozen_string_literal: true

RSpec.describe Astronoby::Orientation do
  include TestEphemHelper

  describe ".load" do
    it "loads a binary PCK orientation kernel" do
      orientation = described_class.load(
        File.path("#{__dir__}/../support/data/moon_pa_de440_excerpt.bpc")
      )

      expect(orientation).to be_a(described_class)
      orientation.close
    end
  end

  describe "#rotation_for" do
    it "returns an orthonormal 3x3 rotation matrix" do
      instant = Astronoby::Instant.from_time(Time.utc(2001, 6, 15))

      matrix = test_orientation.rotation_for(instant)

      aggregate_failures do
        expect(matrix).to be_a(Matrix)
        expect(matrix.row_count).to eq(3)
        expect(matrix.column_count).to eq(3)
        expect(matrix.determinant.round(10)).to eq(1)
        expect((matrix * matrix.transpose).round(10)).to eq(Matrix.identity(3))
      end
    end

    it "raises when the kernel does not cover the instant" do
      instant = Astronoby::Instant.from_time(Time.utc(1995, 1, 1))

      expect { test_orientation.rotation_for(instant) }.to raise_error(
        Astronoby::OrientationOutOfRangeError, /Orientation kernel covers/
      )
    end
  end
end
