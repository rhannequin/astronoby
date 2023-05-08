# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Horizontal do
  describe "#to_equatorial" do
    it "returns a new instance of Astronoby::Coordinates::Equatorial" do
      expect(
        described_class.new(
          azimuth: Astronoby::Angle.as_degrees(BigDecimal("100.8403")),
          altitude: Astronoby::Angle.as_degrees(BigDecimal("80.67222")),
          latitude: BigDecimal("50"),
          longitude: BigDecimal("0")
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
          azimuth: Astronoby::Angle.as_degrees(BigDecimal("171.0833")),
          altitude: Astronoby::Angle.as_degrees(BigDecimal("59.2167")),
          latitude: 38,
          longitude: -78
        ).to_equatorial(time: Time.new(2016, 1, 21, 21, 45, 0, "-05:00"))

        expect(equatorial_coordinates.right_ascension.to_hms.format).to(
          eq("5h 54m 58.0211s")
        )
        expect(equatorial_coordinates.declination.to_dms.format).to(
          eq("+7° 29′ 53.7945″")
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
          azimuth: Astronoby::Angle.as_degrees(BigDecimal("341.55472")),
          altitude: Astronoby::Angle.as_degrees(BigDecimal("-73.455278")),
          latitude: 38,
          longitude: -78
        ).to_equatorial(time: Time.new(2016, 1, 21, 21, 30, 0, "-05:00"))

        expect(equatorial_coordinates.right_ascension.to_hms.format).to(
          eq("17h 43m 54.0942s")
        )
        expect(equatorial_coordinates.declination.to_dms.format).to(
          eq("-22° 10′ 0.203″")
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
          latitude: 38.25,
          longitude: -78.3
        ).to_equatorial(time: Time.new(2015, 6, 6, 21, 0, 0, "-04:00"))

        expect(equatorial_coordinates.right_ascension.to_hms.format).to(
          eq("16h 14m 41.8276s")
        )
        expect(equatorial_coordinates.declination.to_dms.format).to(
          eq("+25° 57′ 41.0393″")
        )
      end
    end
  end
end
