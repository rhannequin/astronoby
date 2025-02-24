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
        epoch: Astronoby::Epoch::J1950
      )
      new_epoch = Astronoby::Epoch.from_time(Time.utc(1979, 6, 1, 0, 0, 0))

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
        epoch: Astronoby::Epoch::J1950
      )

      precessed_coordinates = described_class.for_equatorial_coordinates(
        coordinates: coordinates,
        epoch: Astronoby::Epoch.from_time(Time.utc(1979, 6, 1, 0, 0, 0))
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
        epoch: Astronoby::Epoch::J1950
      )

      precessed_coordinates = described_class.for_equatorial_coordinates(
        coordinates: coordinates,
        epoch: Astronoby::Epoch::J2000
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
        epoch: Astronoby::Epoch::J2000
      )

      precessed_coordinates = described_class.for_equatorial_coordinates(
        coordinates: coordinates,
        epoch: Astronoby::Epoch.from_time(Time.utc(2015, 1, 1, 0, 0, 0))
      )

      expect(precessed_coordinates.right_ascension.str(:hms)).to(
        eq("12h 35m 18.383s")
      )
      expect(precessed_coordinates.declination.str(:dms)).to(
        eq("+29° 44′ 10.8629″")
      )
    end
  end

  describe "#matrix" do
    it "returns the right matrix for 2025-08-01" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)

      matrix = described_class.new(instant).matrix

      expect(matrix).to eq(
        Matrix[
          [0.9999805493402671, -0.00572043918489605, -0.002485461057708681],
          [0.0057204392635234564, 0.999983638128416, -7.077398710142457e-06],
          [0.002485460876742937, -7.140667972360681e-06, 0.9999969112118503]]
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

      matrix = described_class.new(instant).matrix

      expect(matrix).to eq(
        Matrix[
          [0.9999256847034389, -0.011181602311713876, -0.004857657882310543],
          [0.011181602603764246, 0.9999374835602728, -2.7099087538506872e-05],
          [0.004857657210054194, -2.7219326363292495e-05, 0.9999882011431624]]
      )
      # Skyfield: [
      #   [ 0.999925685   -0.0111816023   -0.00485765788]
      #   [ 0.0111816026   0.999937484    -2.70990875e-05]
      #   [ 0.00485765721 -2.72193264e-05  0.999988201]
      # ]
    end
  end
end
