# frozen_string_literal: true

RSpec.describe Astronoby::Body do
  describe "#rising_time" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns the body's rising time" do
      right_ascension = Astronoby::Angle.as_hms(5, 55, 0)
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

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns nil as the body doesn't rise for the observer" do
      right_ascension = Astronoby::Angle.as_hms(6, 0, 0)
      declination = Astronoby::Angle.as_degrees(BigDecimal("-60"))
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination
      )
      body = described_class.new(coordinates)

      rising_time = body.rising_time(
        latitude: Astronoby::Angle.as_degrees(BigDecimal("45")),
        longitude: Astronoby::Angle.as_degrees(BigDecimal("-100")),
        date: Date.new(2015, 12, 1)
      )

      expect(rising_time).to be_nil
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns the body's rising time" do
      coordinates = Astronoby::Coordinates::Horizontal.new(
        azimuth: Astronoby::Angle.as_degrees(90),
        altitude: Astronoby::Angle.as_degrees(45),
        latitude: 38.25,
        longitude: -78.3
      ).to_equatorial(time: Time.new(2015, 6, 6, 21, 0, 0, "-04:00"))
      body = described_class.new(coordinates)

      rising_time = body.rising_time(
        latitude: Astronoby::Angle.as_degrees(BigDecimal("38.25")),
        longitude: Astronoby::Angle.as_degrees(BigDecimal("-78.3")),
        date: Date.new(2015, 6, 6)
      )

      expect(rising_time).to eq(Time.utc(2015, 6, 6, 20, 57, 48))
    end
  end

  describe "#rising_azimuth" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns the body's rising azimuth" do
      right_ascension = Astronoby::Angle.as_hms(5, 55, 0)
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
      right_ascension = Astronoby::Angle.as_hms(5, 55, 0)
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

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns nil as the body doesn't set for the observer" do
      right_ascension = Astronoby::Angle.as_hms(6, 0, 0)
      declination = Astronoby::Angle.as_degrees(BigDecimal("-60"))
      coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: right_ascension,
        declination: declination
      )
      body = described_class.new(coordinates)

      setting_time = body.setting_time(
        latitude: Astronoby::Angle.as_degrees(BigDecimal("45")),
        longitude: Astronoby::Angle.as_degrees(BigDecimal("-100")),
        date: Date.new(2015, 12, 1)
      )

      expect(setting_time).to be_nil
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns the body's setting time" do
      coordinates = Astronoby::Coordinates::Horizontal.new(
        azimuth: Astronoby::Angle.as_degrees(90),
        altitude: Astronoby::Angle.as_degrees(45),
        latitude: 38.25,
        longitude: -78.3
      ).to_equatorial(time: Time.new(2015, 6, 6, 21, 0, 0, "-04:00"))
      body = described_class.new(coordinates)

      setting_time = body.setting_time(
        latitude: Astronoby::Angle.as_degrees(BigDecimal("38.25")),
        longitude: Astronoby::Angle.as_degrees(BigDecimal("-78.3")),
        date: Date.new(2015, 6, 6)
      )

      expect(setting_time).to eq(Time.utc(2015, 6, 6, 11, 59, 51))
    end
  end

  describe "#setting_azimuth" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    it "returns the body's setting azimuth" do
      right_ascension = Astronoby::Angle.as_hms(5, 55, 0)
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
