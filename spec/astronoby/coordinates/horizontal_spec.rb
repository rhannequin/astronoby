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
              BigDecimal("5.91609097641387291426752721863278366111796324076365910699004928974697367699826004")
            ),
            declination: Astronoby::Angle.as_degrees(
              BigDecimal("7.498241437309588048592368613383447444821398406")
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
              BigDecimal("17.73132463394382755856514935033592556443336097643032577299004928974697367699826004")
            ),
            declination: Astronoby::Angle.as_degrees(
              BigDecimal("-22.176389232771255649163165251090212578096123879")
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
              BigDecimal("4.97619753391364389618136066429519005879696918499423711422304723167399149504736741")
            ),
            declination: Astronoby::Angle.as_degrees(
              BigDecimal("24.992283902819092167127797068836316430186077032")
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
          eq("16h 14m 41.7252s")
        )
        expect(equatorial_coordinates.declination.to_dms.format).to(
          eq("25° 57′ 41.0393″")
        )
      end
    end
  end
end
