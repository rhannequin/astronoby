# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Equatorial do
  describe "#to_horizontal" do
    it "returns a new instance of Astronoby::Coordinates::Horizontal" do
      time = Time.new
      latitude = BigDecimal("50")
      longitude = BigDecimal("0")

      expect(
        described_class.new(
          right_ascension: Astronoby::Angle.as_degrees(BigDecimal("23.9994")),
          declination: Astronoby::Angle.as_degrees(BigDecimal("-89.9997"))
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      ).to be_an_instance_of(Astronoby::Coordinates::Horizontal)
    end

    context "with real life arguments (Venus, from Virginia, USA)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 30, 0, "-05:00")
        latitude = BigDecimal("38")
        longitude = BigDecimal("-78")

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.as_degrees(
            BigDecimal("17.731666666666667")
          ),
          declination: Astronoby::Angle.as_degrees(
            BigDecimal("-22.166666666666667")
          )
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.azimuth.value).to(
          be_within(BigDecimal("0.00000000000001"))
            .of(BigDecimal("341.554819847564726443269943001564655153971449036"))
        )

        expect(horizontal_coordinates.altitude.value).to(
          be_within(BigDecimal("0.000000000000000000000000000000000000000000001"))
            .of(BigDecimal("-73.45522737797505396786852866275388568052468949"))
        )
      end
    end

    context "with real life arguments (Betelgeuse, from Virginia, USA)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 45, 0, "-05:00")
        latitude = BigDecimal("38")
        longitude = BigDecimal("-78")
        right_ascension_hour = BigDecimal("5")
        right_ascension_minute = BigDecimal("54")
        right_ascension_second = BigDecimal("57.9274")

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.as_degrees(
            BigDecimal("5.916090944444444")
          ),
          declination: Astronoby::Angle.as_degrees(
            BigDecimal("7.498241083333333")
          )
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.azimuth.value).to(
          be_within(BigDecimal("0.0000000000001"))
            .of(BigDecimal("171.083334007099890677318332483813992031018593381"))
        )
        expect(horizontal_coordinates.altitude.value).to(
          be_within(BigDecimal("0.000000000000000000000000000000000000000000001"))
            .of(BigDecimal("59.216666707291217481639468066587667491382846133"))
        )
      end
    end

    context "with real life arguments (Mars, from Valencia, Spain)" do
      it "computes properly" do
        time = Time.new(2022, 12, 8, 6, 22, 33, "+01:00")
        latitude = BigDecimal("39.46975")
        longitude = BigDecimal("-0.377389")

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.as_degrees(BigDecimal("4.97602775")),
          declination: Astronoby::Angle.as_degrees(
            BigDecimal("24.992300833333333")
          )
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.azimuth.value).to(
          be_within(BigDecimal("0.000000000000000000000000000000000000000000001"))
            .of(BigDecimal("285.64512985950623168064530218154482388509042265"))
        )
        expect(horizontal_coordinates.altitude.value).to(
          be_within(BigDecimal("0.000000000000000000000000000000000000000000001"))
            .of(BigDecimal("21.03741652263695116943808010599135724615411059"))
        )
      end
    end
  end
end
