# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Horizontal do
  describe "#to_equatorial" do
    it "returns a new instance of Astronoby::Coordinates::Equatorial" do
      expect(
        described_class.new(
          azimuth: Astronoby::Angle.as_degrees(100),
          altitude: Astronoby::Angle.as_degrees(80),
          latitude: Astronoby::Angle.as_degrees(50),
          longitude: Astronoby::Angle.as_degrees(0)
        ).to_equatorial(time: Time.new)
      ).to be_a(Astronoby::Coordinates::Equatorial)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    context "with real life arguments (book example)" do
      it "computes properly" do
        equatorial_coordinates = described_class.new(
          azimuth: Astronoby::Angle.as_dms(171, 5, 0),
          altitude: Astronoby::Angle.as_dms(59, 13, 0),
          latitude: Astronoby::Angle.as_degrees(38),
          longitude: Astronoby::Angle.as_degrees(-78)
        ).to_equatorial(time: Time.new(2016, 1, 21, 21, 45, 0, "-05:00"))

        expect(equatorial_coordinates.right_ascension.str(:hms)).to(
          eq("5h 54m 58.0175s")
        )
        expect(equatorial_coordinates.declination.str(:dms)).to(
          eq("+7° 29′ 53.6679″")
        )
      end
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    context "with real life arguments (book example)" do
      it "computes properly" do
        equatorial_coordinates = described_class.new(
          azimuth: Astronoby::Angle.as_dms(341, 33, 17),
          altitude: Astronoby::Angle.as_dms(-73, 27, 19),
          latitude: Astronoby::Angle.as_degrees(38),
          longitude: Astronoby::Angle.as_degrees(-78)
        ).to_equatorial(time: Time.new(2016, 1, 21, 21, 30, 0, "-05:00"))

        expect(equatorial_coordinates.right_ascension.str(:hms)).to(
          eq("17h 43m 54.0935s")
        )
        expect(equatorial_coordinates.declination.str(:dms)).to(
          eq("-22° 10′ 0.2016″")
        )
      end
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    context "with real life arguments (book example)" do
      it "computes properly" do
        equatorial_coordinates = described_class.new(
          azimuth: Astronoby::Angle.as_degrees(90),
          altitude: Astronoby::Angle.as_degrees(45),
          latitude: Astronoby::Angle.as_degrees(38.25),
          longitude: Astronoby::Angle.as_degrees(-78.3)
        ).to_equatorial(time: Time.new(2015, 6, 6, 21, 0, 0, "-04:00"))

        expect(equatorial_coordinates.right_ascension.str(:hms)).to(
          eq("16h 14m 41.827s")
        )
        expect(equatorial_coordinates.declination.str(:dms)).to(
          eq("+25° 57′ 41.0393″")
        )
      end
    end
  end
end
