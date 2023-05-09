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
        latitude = Astronoby::Angle.as_degrees(0)
        longitude = Astronoby::Angle.as_dms(120, 30, 30)
        epoch = Astronoby::Epoch::J2000

        equatorial_coordinates = described_class.new(
          latitude: latitude,
          longitude: longitude
        ).to_equatorial(epoch: epoch)

        expect(equatorial_coordinates.right_ascension.to_hms.format).to(
          eq("8h 10m 50.4182s")
        )
        expect(equatorial_coordinates.declination.to_dms.format).to(
          eq("+20° 2′ 30.758″")
        )
      end
    end
  end
end
