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

    context "with real life arguments (Virginia, USA)" do
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
  end
end
