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

        horizontal_coordinates = described_class.new(
          right_ascension_hour: right_ascension_hour,
          right_ascension_minute: right_ascension_minute,
          right_ascension_second: right_ascension_second,
          declination_degree: declination_degree,
          declination_minute: declination_minute,
          declination_second: declination_second
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.azimuth.value).to(
          be_within(BigDecimal("0.000000000000000000000000000000000000000000001"))
            .of(BigDecimal("341.554819847564601665794558955621412349101184798"))
        )

        expect(horizontal_coordinates.altitude.value).to(
          be_within(BigDecimal("0.000000000000000000000000000000000000000000001"))
            .of(BigDecimal("-73.455227377975060334066252338567316435875213177"))
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
        declination_degree = BigDecimal("7")
        declination_minute = BigDecimal("29")
        declination_second = BigDecimal("53.6679")

        horizontal_coordinates = described_class.new(
          right_ascension_hour: right_ascension_hour,
          right_ascension_minute: right_ascension_minute,
          right_ascension_second: right_ascension_second,
          declination_degree: declination_degree,
          declination_minute: declination_minute,
          declination_second: declination_second
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.azimuth.value).to(
          be_within(BigDecimal("0.000000000000000000000000000000000000000000001"))
            .of(BigDecimal("171.083334007099903409713779835440853541719640751"))
        )
        expect(horizontal_coordinates.altitude.value).to(
          be_within(BigDecimal("0.0000000000001"))
            .of(BigDecimal("59.216666707291223847837191742401098246733369818"))
        )
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

        horizontal_coordinates = described_class.new(
          right_ascension_hour: right_ascension_hour,
          right_ascension_minute: right_ascension_minute,
          right_ascension_second: right_ascension_second,
          declination_degree: declination_degree,
          declination_minute: declination_minute,
          declination_second: declination_second
        ).to_horizontal(time: time, latitude: latitude, longitude: longitude)

        expect(horizontal_coordinates.azimuth.value).to(
          be_within(BigDecimal("0.0000000000001"))
            .of(BigDecimal("285.645129859506263511633920560611977661843041078"))
        )
        expect(horizontal_coordinates.altitude.value).to(
          be_within(BigDecimal("0.000000000000000000000000000000000000000000001"))
            .of(BigDecimal("21.037416522636957535635803781804788001504634275"))
        )
      end
    end
  end
end
