# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Horizontal do
  describe "#to_equatorial" do
    it "returns a new instance of Astronoby::Coordinates::Equatorial" do
      time = Time.new
      latitude = BigDecimal("50")
      longitude = BigDecimal("0")
      azimuth_degree = BigDecimal("100")
      azimuth_minute = BigDecimal("50")
      azimuth_second = BigDecimal("25")
      altitude_degree = BigDecimal("80")
      altitude_minute = BigDecimal("40")
      altitude_second = BigDecimal("20")

      expect(
        described_class.new(
          azimuth_degree: azimuth_degree,
          azimuth_minute: azimuth_minute,
          azimuth_second: azimuth_second,
          altitude_degree: altitude_degree,
          altitude_minute: altitude_minute,
          altitude_second: altitude_second,
          latitude: latitude,
          longitude: longitude
        ).to_equatorial(time: time)
      ).to be_a(Astronoby::Coordinates::Equatorial)
    end

    context "with real life arguments (Betelgeuse, from Virginia, USA)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 45, 0, "-05:00")
        latitude = BigDecimal("38")
        longitude = BigDecimal("-78")
        azimuth_degree = BigDecimal("171")
        azimuth_minute = BigDecimal("5")
        azimuth_second = BigDecimal("0")
        altitude_degree = BigDecimal("59")
        altitude_minute = BigDecimal("13")
        altitude_second = BigDecimal("0")

        expect(Astronoby::Coordinates::Equatorial).to(
          receive(:new).with(
            right_ascension_hour: 5,
            right_ascension_minute: 54,
            right_ascension_second: kind_of(Numeric),
            declination_degree: 7,
            declination_minute: 29,
            declination_second: kind_of(Numeric)
          )
        )

        described_class.new(
          azimuth_degree: azimuth_degree,
          azimuth_minute: azimuth_minute,
          azimuth_second: azimuth_second,
          altitude_degree: altitude_degree,
          altitude_minute: altitude_minute,
          altitude_second: altitude_second,
          latitude: latitude,
          longitude: longitude
        ).to_equatorial(time: time)
      end
    end

    context "with real life arguments (Venus, from Virginia, USA)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 30, 0, "-05:00")
        latitude = BigDecimal("38")
        longitude = BigDecimal("-78")
        azimuth_degree = BigDecimal("341")
        azimuth_minute = BigDecimal("33")
        azimuth_second = BigDecimal("42.1499")
        altitude_degree = BigDecimal("-73")
        altitude_minute = BigDecimal("27")
        altitude_second = BigDecimal("57.1321")

        expect(Astronoby::Coordinates::Equatorial).to(
          receive(:new).with(
            right_ascension_hour: 17,
            right_ascension_minute: 43,
            right_ascension_second: kind_of(Numeric),
            declination_degree: -22,
            declination_minute: 10,
            declination_second: kind_of(Numeric)
          )
        )

        described_class.new(
          azimuth_degree: azimuth_degree,
          azimuth_minute: azimuth_minute,
          azimuth_second: azimuth_second,
          altitude_degree: altitude_degree,
          altitude_minute: altitude_minute,
          altitude_second: altitude_second,
          latitude: latitude,
          longitude: longitude
        ).to_equatorial(time: time)
      end
    end

    context "with real life arguments (Mars, from Valencia, Spain)" do
      it "computes properly" do
        time = Time.new(2022, 12, 8, 6, 22, 33, "+01:00")
        latitude = BigDecimal("39.46975")
        longitude = BigDecimal("-0.377389")
        azimuth_degree = BigDecimal("285")
        azimuth_minute = BigDecimal("38")
        azimuth_second = BigDecimal("37.32")
        altitude_degree = BigDecimal("21")
        altitude_minute = BigDecimal("2")
        altitude_second = BigDecimal("21.480")

        expect(Astronoby::Coordinates::Equatorial).to(
          receive(:new).with(
            right_ascension_hour: 4,
            right_ascension_minute: 58,
            right_ascension_second: kind_of(Numeric),
            declination_degree: 24,
            declination_minute: 59,
            declination_second: kind_of(Numeric)
          )
        )

        described_class.new(
          azimuth_degree: azimuth_degree,
          azimuth_minute: azimuth_minute,
          azimuth_second: azimuth_second,
          altitude_degree: altitude_degree,
          altitude_minute: altitude_minute,
          altitude_second: altitude_second,
          latitude: latitude,
          longitude: longitude
        ).to_equatorial(time: time)
      end
    end
  end
end
