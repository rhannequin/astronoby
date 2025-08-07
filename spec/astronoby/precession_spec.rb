# frozen_string_literal: true

RSpec.describe Astronoby::Precession do
  describe "::for_equatorial_coordinates" do
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 34 - Precession
    it "returns equatorial coordinates with the right epoch" do
      right_ascension = Astronoby::Angle.from_hms(9, 10, 43)
      declination = Astronoby::Angle.from_dms(14, 23, 25)
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination,
        epoch: Astronoby::JulianDate::J1950
      )
      new_epoch = Astronoby::JulianDate.from_time(Time.utc(1979, 6, 1, 0, 0, 0))

      precessed_coordinates = described_class.for_equatorial_coordinates(
        coordinates: coordinates,
        epoch: new_epoch
      )

      expect(precessed_coordinates).to be_a(Astronoby::Coordinates::Equatorial)
      expect(precessed_coordinates.epoch).to eq(new_epoch)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 34 - Precession
    it "returns the right new equatorial coordinates" do
      right_ascension = Astronoby::Angle.from_hms(9, 10, 43)
      declination = Astronoby::Angle.from_dms(14, 23, 25)
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination,
        epoch: Astronoby::JulianDate::J1950
      )

      precessed_coordinates = described_class.for_equatorial_coordinates(
        coordinates: coordinates,
        epoch: Astronoby::JulianDate.from_time(Time.utc(1979, 6, 1, 0, 0, 0))
      )

      expect(precessed_coordinates.right_ascension.str(:hms)).to(
        eq("9h 12m 20.1577s")
      )
      expect(precessed_coordinates.declination.str(:dms)).to(
        eq("+14° 16′ 7.6506″")
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    it "returns the right new equatorial coordinates" do
      right_ascension = Astronoby::Angle.from_hms(12, 32, 6)
      declination = Astronoby::Angle.from_dms(30, 5, 40)
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination,
        epoch: Astronoby::JulianDate::J1950
      )

      precessed_coordinates = described_class.for_equatorial_coordinates(
        coordinates: coordinates,
        epoch: Astronoby::JulianDate::J2000
      )

      expect(precessed_coordinates.right_ascension.str(:hms)).to(
        eq("12h 34m 34.1434s")
      )
      expect(precessed_coordinates.declination.str(:dms)).to(
        eq("+29° 49′ 8.3259″")
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    it "returns the right new equatorial coordinates" do
      right_ascension = Astronoby::Angle.from_hms(12, 34, 34)
      declination = Astronoby::Angle.from_dms(29, 49, 8)
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination,
        epoch: Astronoby::JulianDate::J2000
      )

      precessed_coordinates = described_class.for_equatorial_coordinates(
        coordinates: coordinates,
        epoch: Astronoby::JulianDate.from_time(Time.utc(2015, 1, 1, 0, 0, 0))
      )

      expect(precessed_coordinates.right_ascension.str(:hms)).to(
        eq("12h 35m 18.383s")
      )
      expect(precessed_coordinates.declination.str(:dms)).to(
        eq("+29° 44′ 10.8629″")
      )
    end
  end

  describe "::matrix_for" do
    it "returns the right matrix for 2025-08-01" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)

      matrix = described_class.matrix_for(instant)

      expect(matrix.round(10)).to eq(
        Matrix[
          [0.9999805493, -0.0057204392, -0.0024854611],
          [0.0057204393, 0.9999836381, -7.0774e-06],
          [0.0024854609, -7.1407e-06, 0.9999969112]
        ]
      )
      # Skyfield: [
      #   [ 0.999980549   -0.00572043919 -0.00248546106]
      #   [ 0.00572043926  0.999983638   -7.07739871e-06]
      #   [ 0.00248546088 -7.14066798e-06 0.999996911]
      # ]
    end

    it "returns the right matrix for 2050-01-01" do
      time = Time.utc(2050, 1, 1)
      instant = Astronoby::Instant.from_time(time)

      matrix = described_class.matrix_for(instant)

      expect(matrix.round(10)).to eq(
        Matrix[
          [0.9999256847, -0.0111816023, -0.0048576579],
          [0.0111816026, 0.9999374836, -2.70991e-05],
          [0.0048576572, -2.72193e-05, 0.9999882011]]
      )
      # Skyfield: [
      #   [ 0.999925685   -0.0111816023   -0.00485765788]
      #   [ 0.0111816026   0.999937484    -2.70990875e-05]
      #   [ 0.00485765721 -2.72193264e-05  0.999988201]
      # ]
    end

    context "with cache enabled" do
      it "returns a matrix with acceptable precision" do
        Astronoby.configuration.cache_enabled = true
        time = Time.utc(2025, 5, 26, 10, 0, 0)
        instant = Astronoby::Instant.from_time(time)
        rounding = Astronoby.configuration.cache_precision(:precession)
        rounded_instant = Astronoby::Instant.from_terrestrial_time(
          instant.tt.round(rounding)
        )
        precision = 0.00000001

        matrix = described_class.matrix_for(instant)
        rounded_matrix = described_class.matrix_for(rounded_instant)

        aggregate_failures do
          original_matrix = matrix.to_a
          rounded_matrix.to_a.each_with_index do |row, i|
            row.each_with_index do |value, j|
              expect(value).to be_within(precision).of(original_matrix[i][j])
            end
          end
        end

        Astronoby.reset_configuration!
      end
    end
  end
end
