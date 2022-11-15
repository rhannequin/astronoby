# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Equatorial do
  describe "#to_horizontal" do
    it "returns a new instance of Astronoby::Coordinates::Horizontal" do
      time = Time.new
      latitude = BigDecimal("50")
      longitude = BigDecimal("0")
      right_ascension_hour = BigDecimal("23")
      right_ascension_minute = BigDecimal("59")
      right_ascension_second = BigDecimal("58")
      declination_degree = BigDecimal("-359")
      declination_minute = BigDecimal("59")
      declination_second = BigDecimal("58")

      expect(
        described_class.new(
          right_ascension_hour: right_ascension_hour,
          right_ascension_minute: right_ascension_minute,
          right_ascension_second: right_ascension_second,
          declination_degree: declination_degree,
          declination_minute: declination_minute,
          declination_second: declination_second
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      ).to be_an_instance_of(Astronoby::Coordinates::Horizontal)
    end

    context "with real life arguments (Venus, from Virginia, USA)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 30, 0, "-05:00")
        latitude = BigDecimal("38")
        longitude = BigDecimal("-78")
        right_ascension_hour = BigDecimal("17")
        right_ascension_minute = BigDecimal("43")
        right_ascension_second = BigDecimal("54")
        declination_degree = BigDecimal("-22")
        declination_minute = BigDecimal("10")
        declination_second = BigDecimal("0")

        expect(Astronoby::Coordinates::Horizontal).to(
          receive(:new).with(
            azimuth_degree: 341,
            azimuth_minute: 33,
            azimuth_second: kind_of(Numeric),
            altitude_degree: -73,
            altitude_minute: 27,
            altitude_second: kind_of(Numeric),
            latitude: latitude,
            longitude: longitude
          )
        )

        described_class.new(
          right_ascension_hour: right_ascension_hour,
          right_ascension_minute: right_ascension_minute,
          right_ascension_second: right_ascension_second,
          declination_degree: declination_degree,
          declination_minute: declination_minute,
          declination_second: declination_second
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
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
        declination_degree = BigDecimal("7")
        declination_minute = BigDecimal("29")
        declination_second = BigDecimal("53.6679")

        expect(Astronoby::Coordinates::Horizontal).to(
          receive(:new).with(
            azimuth_degree: 171,
            azimuth_minute: 5,
            azimuth_second: kind_of(Numeric),
            altitude_degree: 59,
            altitude_minute: 13,
            altitude_second: kind_of(Numeric),
            latitude: latitude,
            longitude: longitude
          )
        )

        described_class.new(
          right_ascension_hour: right_ascension_hour,
          right_ascension_minute: right_ascension_minute,
          right_ascension_second: right_ascension_second,
          declination_degree: declination_degree,
          declination_minute: declination_minute,
          declination_second: declination_second
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      end
    end

    context "with real life arguments (Mars, from Valencia, Spain)" do
      it "computes properly" do
        time = Time.new(2022, 12, 8, 6, 22, 33, "+01:00")
        latitude = BigDecimal("39.46975")
        longitude = BigDecimal("-0.377389")
        right_ascension_hour = BigDecimal("4")
        right_ascension_minute = BigDecimal("58")
        right_ascension_second = BigDecimal("33.6999")
        declination_degree = BigDecimal("24")
        declination_minute = BigDecimal("59")
        declination_second = BigDecimal("32.283")

        expect(Astronoby::Coordinates::Horizontal).to(
          receive(:new).with(
            azimuth_degree: 285,
            azimuth_minute: 38,
            azimuth_second: kind_of(Numeric),
            altitude_degree: 21,
            altitude_minute: 2,
            altitude_second: kind_of(Numeric),
            latitude: latitude,
            longitude: longitude
          )
        )

        described_class.new(
          right_ascension_hour: right_ascension_hour,
          right_ascension_minute: right_ascension_minute,
          right_ascension_second: right_ascension_second,
          declination_degree: declination_degree,
          declination_minute: declination_minute,
          declination_second: declination_second
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)
      end
    end
  end
end
