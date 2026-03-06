# frozen_string_literal: true

RSpec.describe Astronoby::EarthRotation do
  describe "::matrix_for" do
    it "returns a 3x3 matrix" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)

      matrix = described_class.matrix_for(instant)

      expect(matrix.row_size).to eq(3)
      expect(matrix.column_size).to eq(3)
    end

    it "returns a proper rotation matrix (determinant = 1)" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)

      matrix = described_class.matrix_for(instant)

      expect(matrix.determinant).to be_within(1e-15).of(1.0)
    end

    it "returns an orthogonal matrix (M * Mᵀ = I)" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)

      matrix = described_class.matrix_for(instant)
      product = matrix * matrix.transpose

      3.times do |i|
        3.times do |j|
          expected = (i == j) ? 1.0 : 0.0
          expect(product[i, j]).to be_within(1e-15).of(expected)
        end
      end
    end
  end

  describe "::mean_matrix_for" do
    it "returns a 3x3 matrix" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)

      matrix = described_class.mean_matrix_for(instant)

      expect(matrix.row_size).to eq(3)
      expect(matrix.column_size).to eq(3)
    end

    it "returns a proper rotation matrix (determinant = 1)" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)

      matrix = described_class.mean_matrix_for(instant)

      expect(matrix.determinant).to be_within(1e-15).of(1.0)
    end

    it "returns an orthogonal matrix (M * Mᵀ = I)" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)

      matrix = described_class.mean_matrix_for(instant)
      product = matrix * matrix.transpose

      3.times do |i|
        3.times do |j|
          expected = (i == j) ? 1.0 : 0.0
          expect(product[i, j]).to be_within(1e-15).of(expected)
        end
      end
    end
  end

  describe "apparent vs mean" do
    it "differ by the equation of the equinoxes" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)

      apparent = described_class.matrix_for(instant)
      mean = described_class.mean_matrix_for(instant)

      expect(apparent).not_to eq(mean)
    end
  end

  describe "numerical consistency with Observer" do
    it "matches the R₃(GAST) component of Observer#earth_fixed_rotation_matrix_for" do
      time = Time.utc(2025, 6, 15, 12, 0, 0)
      instant = Astronoby::Instant.from_time(time)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      earth_rotation = described_class.matrix_for(instant)
      full_matrix = observer.earth_fixed_rotation_matrix_for(instant)

      # Polar motion corrections are tiny (< 1 arcsecond), so the
      # dominant R₃(GAST) rotation should produce very similar matrix elements
      expect(earth_rotation[0, 0]).to be_within(1e-5).of(full_matrix[0, 0])
      expect(earth_rotation[1, 0]).to be_within(1e-5).of(full_matrix[1, 0])
    end
  end
end
