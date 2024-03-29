# frozen_string_literal: true

RSpec.describe Astronoby::Refraction do
  describe "::angle" do
    it "returns an Angle" do
      coordinates = Astronoby::Coordinates::Horizontal.new(
        azimuth: Astronoby::Angle.from_degrees(100),
        altitude: Astronoby::Angle.from_degrees(80),
        latitude: Astronoby::Angle.from_degrees(50),
        longitude: Astronoby::Angle.zero
      )
      observer = instance_double(
        Astronoby::Observer,
        pressure: Astronoby::Observer::DEFAULT_TEMPERATURE,
        temperature: Astronoby::Observer::PRESSURE_AT_SEA_LEVEL
      )

      angle = described_class.angle(
        coordinates: coordinates,
        observer: observer
      )

      expect(angle).to be_a Astronoby::Angle
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 37 - Refraction

    # The book example expects a refraction angle of +0° 10′ 11.2464″
    it "computes the refraction angle" do
      time = Time.utc(1987, 3, 23, 1, 1, 24)
      latitude = Astronoby::Angle.from_degrees(BigDecimal("51.203611"))
      longitude = Astronoby::Angle.from_degrees(BigDecimal("0.17"))
      true_equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(23, 14, 0),
        declination: Astronoby::Angle.from_dms(40, 10, 0)
      )
      true_horizontal_coordinates = true_equatorial_coordinates.to_horizontal(
        time: time,
        latitude: latitude,
        longitude: longitude
      )
      observer = instance_double(
        Astronoby::Observer,
        pressure: 1012,
        temperature: 294.85
      )

      angle = described_class.angle(
        coordinates: true_horizontal_coordinates,
        observer: observer
      )

      expect(angle.str(:dms)).to eq "+0° 10′ 29.3991″"
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 37 - Refraction
    it "computes the refraction angle" do
      coordinates = Astronoby::Coordinates::Horizontal.new(
        azimuth: Astronoby::Angle.from_dms(283, 16, 15.70),
        altitude: Astronoby::Angle.from_dms(19, 20, 3.64),
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      observer = instance_double(
        Astronoby::Observer,
        pressure: 1008,
        temperature: 273.15 + 13
      )

      angle = described_class.angle(
        coordinates: coordinates,
        observer: observer
      )

      expect(angle.str(:dms)).to eq "+0° 2′ 43.3668″"
    end
  end

  describe "::correct_horizontal_coordinates" do
    it "returns horizontal coordinates" do
      true_coordinates = Astronoby::Coordinates::Horizontal.new(
        azimuth: Astronoby::Angle.from_degrees(100),
        altitude: Astronoby::Angle.from_degrees(80),
        latitude: Astronoby::Angle.from_degrees(50),
        longitude: Astronoby::Angle.zero
      )
      observer = instance_double(
        Astronoby::Observer,
        pressure: 0,
        temperature: 0
      )

      apparent_coordinates = described_class.correct_horizontal_coordinates(
        coordinates: true_coordinates,
        observer: observer
      )

      expect(apparent_coordinates).to be_a(Astronoby::Coordinates::Horizontal)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 37 - Refraction
    it "computes accurate apparent coordinates" do
      true_coordinates = Astronoby::Coordinates::Horizontal.new(
        azimuth: Astronoby::Angle.from_dms(283, 16, 15.70),
        altitude: Astronoby::Angle.from_dms(19, 20, 3.64),
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      observer = instance_double(
        Astronoby::Observer,
        pressure: 1008,
        temperature: 273.15 + 13
      )

      apparent_coordinates = described_class.correct_horizontal_coordinates(
        coordinates: true_coordinates,
        observer: observer
      )

      expect(apparent_coordinates.azimuth).to eq(true_coordinates.azimuth)
      expect(apparent_coordinates.altitude.str(:dms)).to(
        eq("+19° 22′ 47.0068″")
      )
      expect(apparent_coordinates.latitude).to eq(true_coordinates.latitude)
      expect(apparent_coordinates.longitude).to eq(true_coordinates.longitude)
    end
  end
end
