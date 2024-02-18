# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Ecliptic do
  describe "#to_equatorial" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    context "with real life arguments (book example)" do
      it "computes properly" do
        latitude = Astronoby::Angle.as_dms(1, 12, 0)
        longitude = Astronoby::Angle.as_dms(184, 36, 0)
        epoch = Astronoby::Epoch::J2000

        equatorial_coordinates = described_class.new(
          latitude: latitude,
          longitude: longitude
        ).to_equatorial(epoch: epoch)

        expect(equatorial_coordinates.right_ascension.str(:hms)).to(
          eq("12h 18m 47.4954s")
        )
        expect(equatorial_coordinates.declination.str(:dms)).to(
          eq("-0° 43′ 35.5098″")
        )
      end
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    context "with real life arguments (book example)" do
      it "computes properly" do
        latitude = Astronoby::Angle.as_degrees(0)
        longitude = Astronoby::Angle.as_dms(120, 30, 30)
        epoch = Astronoby::Epoch::J2000

        equatorial_coordinates = described_class.new(
          latitude: latitude,
          longitude: longitude
        ).to_equatorial(epoch: epoch)

        expect(equatorial_coordinates.right_ascension.str(:hms)).to(
          eq("8h 10m 50.4188s")
        )
        expect(equatorial_coordinates.declination.str(:dms)).to(
          eq("+20° 2′ 30.795″")
        )
      end
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 27 - Ecliptic to equatorial coordinate conversion
    context "with real life arguments (book example)" do
      it "computes properly" do
        latitude = Astronoby::Angle.as_dms(4, 52, 31)
        longitude = Astronoby::Angle.as_dms(139, 41, 10)
        epoch = Astronoby::Epoch.from_time(Time.utc(2009, 7, 6, 0, 0, 0))

        equatorial_coordinates = described_class.new(
          latitude: latitude,
          longitude: longitude
        ).to_equatorial(epoch: epoch)

        expect(equatorial_coordinates.right_ascension.str(:hms)).to(
          eq("9h 34m 53.3214s")
        )
        expect(equatorial_coordinates.declination.str(:dms)).to(
          eq("+19° 32′ 6.0105″")
        )
      end
    end
  end
end
