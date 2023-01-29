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

    context "with real life arguments (Betelgeuse, from Virginia, USA)" do
      it "computes properly" do
        expect(Astronoby::Coordinates::Equatorial).to(
          receive(:new).with(
            right_ascension: Astronoby::Angle.as_degrees(
              BigDecimal("5.91611614366334")
            ),
            declination: Astronoby::Angle.as_degrees(
              BigDecimal("7.49824143730992")
            )
          )
        )

        described_class.new(
          azimuth: Astronoby::Angle.as_degrees(BigDecimal("171.083333")),
          altitude: Astronoby::Angle.as_degrees(BigDecimal("59.216667")),
          latitude: BigDecimal("38"),
          longitude: BigDecimal("-78")
        ).to_equatorial(time: Time.new(2016, 1, 21, 21, 45, 0, "-05:00"))
      end
    end

    context "with real life arguments (Venus, from Virginia, USA)" do
      it "computes properly" do
        expect(Astronoby::Coordinates::Equatorial).to(
          receive(:new).with(
            right_ascension: Astronoby::Angle.as_degrees(
              BigDecimal("17.73134982385581")
            ),
            declination: Astronoby::Angle.as_degrees(
              BigDecimal("-22.17638923277082")
            )
          )
        )

        described_class.new(
          azimuth: Astronoby::Angle.as_degrees(BigDecimal("341.5617")),
          altitude: Astronoby::Angle.as_degrees(BigDecimal("-73.46587")),
          latitude: BigDecimal("38"),
          longitude: BigDecimal("-78")
        ).to_equatorial(time: Time.new(2016, 1, 21, 21, 30, 0, "-05:00"))
      end
    end

    context "with real life arguments (Mars, from Valencia, Spain)" do
      it "computes properly" do
        expect(Astronoby::Coordinates::Equatorial).to(
          receive(:new).with(
            right_ascension: Astronoby::Angle.as_degrees(
              BigDecimal("4.97623177977841")
            ),
            declination: Astronoby::Angle.as_degrees(
              BigDecimal("24.99228390281957")
            )
          )
        )

        described_class.new(
          azimuth: Astronoby::Angle.as_degrees(BigDecimal("285.6437")),
          altitude: Astronoby::Angle.as_degrees(BigDecimal("21.0393")),
          latitude: BigDecimal("39.46975"),
          longitude: BigDecimal("-0.377389")
        ).to_equatorial(time: Time.new(2022, 12, 8, 6, 22, 33, "+01:00"))
      end
    end

    context "with real life arguments (Mars, from Paris, France)" do
      it "computes properly" do
        equatorial_coordinates = described_class.new(
          azimuth: Astronoby::Angle.as_degrees(BigDecimal("180.135207714")),
          altitude: Astronoby::Angle.as_degrees(BigDecimal("66.14017303")),
          latitude: BigDecimal("48.854419"),
          longitude: BigDecimal("2.482681")
        ).to_equatorial(time: Time.utc(2022, 12, 6, 23, 48, 0))

        expect(equatorial_coordinates.right_ascension.to_hms.format).to(
          eq("5h 0m 39.427s")
        )
        expect(equatorial_coordinates.declination.to_dms.format).to(
          eq("+24° 59′ 40.6999″")
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
