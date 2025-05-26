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

    context "with cache enabled" do
      it "returns the right value for longitude with acceptable precision" do
        Astronoby.configuration.cache_enabled = true
        time = Time.utc(2025, 5, 26, 10, 0, 0)
        instant = Astronoby::Instant.from_time(time)
        rounding = Astronoby.configuration.cache_precision(:nutation)
        rounded_instant = Astronoby::Instant.from_terrestrial_time(
          instant.tt.round(rounding)
        )
        precision = Astronoby::Angle.from_degree_arcseconds(0.001)

        nutation = described_class.new(instant: instant)
        rounded_nutation = described_class.new(instant: rounded_instant)

        aggregate_failures do
          expect(rounded_nutation.nutation_in_longitude.degrees).to(
            be_within(precision.degrees).of(
              nutation.nutation_in_longitude.degrees
            )
          )
        end
      end
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

    context "with cache enabled" do
      it "returns the right value for obliquity with acceptable precision" do
        Astronoby.configuration.cache_enabled = true
        time = Time.utc(2025, 5, 26, 10, 0, 0)
        instant = Astronoby::Instant.from_time(time)
        rounding = Astronoby.configuration.cache_precision(:nutation)
        rounded_instant = Astronoby::Instant.from_terrestrial_time(
          instant.tt.round(rounding)
        )
        precision = Astronoby::Angle.from_degree_arcseconds(0.001)

        nutation = described_class.new(instant: instant)
        rounded_nutation = described_class.new(instant: rounded_instant)

        aggregate_failures do
          expect(rounded_nutation.nutation_in_obliquity.degrees).to(
            be_within(precision.degrees).of(
              nutation.nutation_in_obliquity.degrees
            )
          )
        end

        Astronoby.reset_configuration!
      end
    end
  end
end
