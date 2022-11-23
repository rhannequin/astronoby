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
            right_ascension_hour: 5,
            right_ascension_minute: 54,
            right_ascension_second: be_within(BigDecimal("0.00000000000000000001")).of(
              BigDecimal(
                "57.927515089942574965407695718239316889617458509172783964177443089105237193736144"
              )
            ),
            declination_degree: 7,
            declination_minute: 29,
            declination_second: BigDecimal(
              "53.6691743144983974068165248851699096"
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
            right_ascension_hour: 17,
            right_ascension_minute: 43,
            right_ascension_second: be_within(BigDecimal("0.0000000001")).of(
              BigDecimal(
                "52.768682197734780391536794761910603689617460909172783964177443089105237193736144"
              )
            ),
            declination_degree: -22,
            declination_minute: 10,
            declination_second: BigDecimal(
              "35.00123797650577038388647268331145"
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
            right_ascension_hour: 4,
            right_ascension_minute: 58,
            right_ascension_second: be_within(BigDecimal("0.00000000000001")).of(
              BigDecimal(
                "34.311122089116521999792760386741776096699197819253612402970034026369382170522676"
              )
            ),
            declination_degree: 24,
            declination_minute: 59,
            declination_second: BigDecimal(
              "32.2220501487386310031025516931609456"
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
  end
end
