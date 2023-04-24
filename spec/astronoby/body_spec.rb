# frozen_string_literal: true

RSpec.describe Astronoby::Body do
  describe "#rising_time" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns the body's rising time" do
      right_ascension = Astronoby::Angle.as_hours(BigDecimal("5.916667"))
      declination = Astronoby::Angle.as_degrees(BigDecimal("7.5"))
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination
      )
      body = described_class.new(coordinates)

      rising_time = body.rising_time(
        latitude: Astronoby::Angle.as_degrees(BigDecimal("38")),
        longitude: Astronoby::Angle.as_degrees(BigDecimal("-78")),
        date: Date.new(2016, 1, 21)
      )

      expect(rising_time).to eq(Time.utc(2016, 1, 21, 20, 40, 46))
    end
  end
end
