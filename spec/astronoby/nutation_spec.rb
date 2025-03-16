# frozen_string_literal: true

RSpec.describe Astronoby::Nutation do
  describe "::matrix_for" do
    it "returns a matrix of 3x3" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)

      matrix = described_class.matrix_for(instant)

      expect(matrix.row_size).to eq(3)
      expect(matrix.column_size).to eq(3)
    end
  end

  describe "#nutation_in_longitude" do
    it "returns the right value for 2025-08-01" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      nutation = described_class.new(instant: instant)

      nutation_in_longitude = nutation.nutation_in_longitude

      expect(nutation_in_longitude.str(:dms))
        .to eq("+0° 0′ 3.8211″")
      # Skyfield: +0° 0′ 3.8213″
    end

    it "returns the right value for 2050-01-01" do
      time = Time.utc(2050, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      nutation = described_class.new(instant: instant)

      nutation_in_longitude = nutation.nutation_in_longitude

      expect(nutation_in_longitude.str(:dms))
        .to eq("+0° 0′ 15.1713″")
      # Skyfield: +0° 0′ 15.1714″
    end
  end

  describe "#nutation_in_obliquity" do
    it "returns the right value for 2025-08-01" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      nutation = described_class.new(instant: instant)

      nutation_in_obliquity = nutation.nutation_in_obliquity

      expect(nutation_in_obliquity.str(:dms))
        .to eq("+0° 0′ 8.9108″")
      # Skyfield: +0° 0′ 8.9108″
    end

    it "returns the right value for 2050-01-01" do
      time = Time.utc(2050, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      nutation = described_class.new(instant: instant)

      nutation_in_obliquity = nutation.nutation_in_obliquity

      expect(nutation_in_obliquity.str(:dms))
        .to eq("-0° 0′ 5.3301″")
      # Skyfield: -0° 0′ 5.3297″
    end
  end
end
