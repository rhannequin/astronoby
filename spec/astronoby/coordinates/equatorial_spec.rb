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

        expect(Astronoby::Coordinates::Horizontal).to(
          receive(:new).with(
            azimuth: Astronoby::Angle.as_degrees(
              BigDecimal("341.554819847564726443269943001564655153971449036")
            ),
            altitude: Astronoby::Angle.as_degrees(
              BigDecimal("-73.45522737797505396786852866275388568052468949")
            ),
            latitude: latitude,
            longitude: longitude
          )
        )

        described_class.new(
          right_ascension: Astronoby::Angle.as_degrees(
            BigDecimal("17.731666666666667")
          ),
          declination: Astronoby::Angle.as_degrees(
            BigDecimal("-22.166666666666667")
          )
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      end
    end

    context "with real life arguments (Betelgeuse, from Virginia, USA)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 45, 0, "-05:00")
        latitude = BigDecimal("38")
        longitude = BigDecimal("-78")

        expect(Astronoby::Coordinates::Horizontal).to(
          receive(:new).with(
            azimuth: Astronoby::Angle.as_degrees(
              BigDecimal("171.083334007099890677318332483813992031018593381")
            ),
            altitude: Astronoby::Angle.as_degrees(
              BigDecimal("59.216666707291217481639468066587667491382846133")
            ),
            latitude: latitude,
            longitude: longitude
          )
        )

        described_class.new(
          right_ascension: Astronoby::Angle.as_degrees(
            BigDecimal("5.916090944444444")
          ),
          declination: Astronoby::Angle.as_degrees(
            BigDecimal("7.498241083333333")
          )
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      end
    end

    context "with real life arguments (Mars, from Valencia, Spain)" do
      it "computes properly" do
        time = Time.new(2022, 12, 8, 6, 22, 33, "+01:00")
        latitude = BigDecimal("39.46975")
        longitude = BigDecimal("-0.377389")

        expect(Astronoby::Coordinates::Horizontal).to(
          receive(:new).with(
            azimuth: Astronoby::Angle.as_degrees(
              BigDecimal("285.64512985950623168064530218154482388509042265")
            ),
            altitude: Astronoby::Angle.as_degrees(
              BigDecimal("21.03741652263695116943808010599135724615411059")
            ),
            latitude: latitude,
            longitude: longitude
          )
        )

        described_class.new(
          right_ascension: Astronoby::Angle.as_degrees(BigDecimal("4.97602775")),
          declination: Astronoby::Angle.as_degrees(
            BigDecimal("24.992300833333333")
          )
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      end
    end

    context "with real life arguments (Mars, from Paris, France)" do
      it "computes properly" do
        time = Time.utc(2022, 12, 6, 23, 48, 0)
        latitude = BigDecimal("48.854419")
        longitude = BigDecimal("2.482681")

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.as_degrees(BigDecimal("5.0109194444")),
          declination: Astronoby::Angle.as_degrees(BigDecimal("24.99463888"))
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.altitude.to_dms.format).to(
          eq("66° 8′ 24.6229″")
        )
        expect(horizontal_coordinates.azimuth.to_dms.format).to(
          eq("180° 8′ 6.7477″")
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
        time = Time.new(2015, 12, 1, 9, 0, 0, "-08:00")
        latitude = 45
        longitude = -100

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.as_degrees(6),
          declination: Astronoby::Angle.as_degrees(-60)
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.altitude.to_dms.format).to(
          eq("-59° 41′ 57.6518″")
        )
        expect(horizontal_coordinates.azimuth.to_dms.format).to(
          eq("224° 15′ 27.0033″")
        )
      end
    end
  end
end
