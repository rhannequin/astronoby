# frozen_string_literal: true

RSpec.describe Astronoby::Precession do
  describe "::for_equatorial_coordinates" do
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 34 - Precession
    it "returns equatorial coordinates with the right epoch" do
      right_ascension = Astronoby::Angle.as_hms(9, 10, 43)
      declination = Astronoby::Angle.as_dms(14, 23, 25)
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
      right_ascension = Astronoby::Angle.as_hms(9, 10, 43)
      declination = Astronoby::Angle.as_dms(14, 23, 25)
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination,
        epoch: Astronoby::Epoch::J1950
      )

      precessed_coordinates = described_class.for_equatorial_coordinates(
        coordinates: coordinates,
        epoch: Astronoby::Epoch.from_time(Time.utc(1979, 6, 1, 0, 0, 0))
      )

      expect(precessed_coordinates.right_ascension.to_hours.to_hms.format).to(
        eq("9h 12m 20.1577s")
      )
      expect(precessed_coordinates.declination.to_dms.format).to(
        eq("+14° 16′ 7.6506″")
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    it "returns the right new equatorial coordinates" do
      right_ascension = Astronoby::Angle.as_hms(12, 32, 6)
      declination = Astronoby::Angle.as_dms(30, 5, 40)
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination,
        epoch: Astronoby::Epoch::J1950
      )

      precessed_coordinates = described_class.for_equatorial_coordinates(
        coordinates: coordinates,
        epoch: Astronoby::Epoch::J2000
      )

      expect(precessed_coordinates.right_ascension.to_hours.to_hms.format).to(
        eq("12h 34m 34.1434s")
      )
      expect(precessed_coordinates.declination.to_dms.format).to(
        eq("+29° 49′ 8.3259″")
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    it "returns the right new equatorial coordinates" do
      right_ascension = Astronoby::Angle.as_hms(12, 34, 34)
      declination = Astronoby::Angle.as_dms(29, 49, 8)
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination,
        epoch: Astronoby::Epoch::J2000
      )

      precessed_coordinates = described_class.for_equatorial_coordinates(
        coordinates: coordinates,
        epoch: Astronoby::Epoch.from_time(Time.utc(2015, 1, 1, 0, 0, 0))
      )

      expect(precessed_coordinates.right_ascension.to_hours.to_hms.format).to(
        eq("12h 35m 18.383s")
      )
      expect(precessed_coordinates.declination.to_dms.format).to(
        eq("+29° 44′ 10.8629″")
      )
    end
  end
end
