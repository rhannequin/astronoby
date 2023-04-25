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

  describe "#rising_azimuth" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns the body's rising azimuth" do
      right_ascension = Astronoby::Angle.as_hours(BigDecimal("5.916667"))
      declination = Astronoby::Angle.as_degrees(BigDecimal("7.5"))
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination
      )
      body = described_class.new(coordinates)

      rising_azimuth = body.rising_azimuth(
        latitude: Astronoby::Angle.as_degrees(BigDecimal("38"))
      )

      expect(rising_azimuth.to_degrees.value).to(
        be_within(10**-9).of(80.465577913)
      )
    end
  end

  describe "#setting_time" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns the body's setting time" do
      right_ascension = Astronoby::Angle.as_hours(BigDecimal("5.916667"))
      declination = Astronoby::Angle.as_degrees(BigDecimal("7.5"))
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination
      )
      body = described_class.new(coordinates)

      setting_time = body.setting_time(
        latitude: Astronoby::Angle.as_degrees(BigDecimal("38")),
        longitude: Astronoby::Angle.as_degrees(BigDecimal("-78")),
        date: Date.new(2016, 1, 21)
      )

      expect(setting_time).to eq(Time.utc(2016, 1, 21, 9, 29, 50))
    end
  end

  describe "#setting_azimuth" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns the body's setting azimuth" do
      right_ascension = Astronoby::Angle.as_hours(BigDecimal("5.916667"))
      declination = Astronoby::Angle.as_degrees(BigDecimal("7.5"))
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination
      )
      body = described_class.new(coordinates)

      setting_azimuth = body.setting_azimuth(
        latitude: Astronoby::Angle.as_degrees(BigDecimal("38"))
      )

      expect(setting_azimuth.to_degrees.value).to(
        be_within(10**-7).of(279.534422)
      )
    end
  end
end
