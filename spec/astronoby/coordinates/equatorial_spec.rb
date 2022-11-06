# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Equatorial do
  describe "#to_horizontal" do
    it "returns a new instance of Astronoby::Coordinates::Horizontal" do
      time = Time.new
      latitude = BigDecimal("50")
      longitude = BigDecimal("0")
      right_ascension_hour = 23
      right_ascension_minute = 59
      right_ascension_second = 58
      declination_degree = -359
      declination_minute = 59
      declination_second = 58

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

    context "with real life arguments (Etretat, France)" do
      it "computes properly" do
        time = Time.new(2022, 6, 26, 3, 10, 5, "+02:00")
        latitude = BigDecimal("49.70911954641343")
        longitude = BigDecimal("0.20271537957527094")
        right_ascension_hour = 21
        right_ascension_minute = 49
        right_ascension_second = 8.6
        declination_degree = -14
        declination_minute = 26
        declination_second = 57.4

        expect(Astronoby::Coordinates::Horizontal).to(
          receive(:new).with(
            azimuth: BigDecimal("143.30560194994206306769645376972241902"),
            horizon: BigDecimal("19.490674347775627009146296733268613935")
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
