# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Ecliptic do
  describe "#to_true_equatorial" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems, p.95
    context "with real life arguments (book example)" do
      it "computes properly" do
        latitude = Astronoby::Angle.from_dms(1, 12, 0)
        longitude = Astronoby::Angle.from_dms(184, 36, 0)
        epoch = Astronoby::Epoch::J2000

        equatorial_coordinates = described_class.new(
          latitude: latitude,
          longitude: longitude
        ).to_true_equatorial(epoch: epoch)

        expect(equatorial_coordinates.right_ascension.str(:hms)).to(
          eq("12h 18m 47.4954s")
          # Result from the book: 12h 18m 47.5s
        )
        expect(equatorial_coordinates.declination.str(:dms)).to(
          eq("-0° 43′ 35.5062″")
          # Result from the book: -0° 43′ 35.5″
        )
      end
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems, p.106
    context "with real life arguments (book example)" do
      it "computes properly" do
        latitude = Astronoby::Angle.zero
        longitude = Astronoby::Angle.from_dms(120, 30, 30)
        epoch = Astronoby::Epoch::J2000

        equatorial_coordinates = described_class.new(
          latitude: latitude,
          longitude: longitude
        ).to_true_equatorial(epoch: epoch)

        expect(equatorial_coordinates.right_ascension.str(:hms)).to(
          eq("8h 10m 50.4182s")
          # Result from the book: 8h 10m 50s
        )
        expect(equatorial_coordinates.declination.str(:dms)).to(
          eq("+20° 2′ 30.758″")
          # Result from the book: +20° 2′ 31″
        )
      end
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 27 - Ecliptic to equatorial coordinate conversion, p.52
    context "with real life arguments (book example)" do
      it "computes properly" do
        latitude = Astronoby::Angle.from_dms(4, 52, 31)
        longitude = Astronoby::Angle.from_dms(139, 41, 10)
        epoch = Astronoby::Epoch.from_time(Time.utc(2009, 7, 6, 0, 0, 0))

        equatorial_coordinates = described_class.new(
          latitude: latitude,
          longitude: longitude
        ).to_true_equatorial(epoch: epoch)

        expect(equatorial_coordinates.right_ascension.str(:hms)).to(
          eq("9h 34m 53.3205s")
          # Result from the book: 9h 34m 53.32s
        )
        expect(equatorial_coordinates.declination.str(:dms)).to(
          eq("+19° 32′ 5.9833″")
          # Result from the book: +19° 32′ 6.01″
        )
      end
    end
  end
end
