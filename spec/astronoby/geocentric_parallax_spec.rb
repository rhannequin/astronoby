# frozen_string_literal: true

RSpec.describe Astronoby::GeocentricParallax do
  describe "::angle" do
    it "returns an Angle" do
      distance = 1_000_000_000

      expect(described_class.angle(distance: distance))
        .to be_a(Astronoby::Angle)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax
    it "returns the equatorial horizontal parallax for the Moon" do
      distance =
        56.2212278 * Astronoby::Constants::EARTH_EQUATORIAL_RADIUS_IN_METERS

      angle = described_class.angle(distance: distance)

      expect(angle.str(:dms)).to eq "+1° 1′ 8.7447″"
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax
    it "returns the equatorial horizontal parallax for the Sun" do
      distance = 0.9901 * Astronoby::Constants::ASTRONOMICAL_UNIT_IN_METERS

      angle = described_class.angle(distance: distance)

      expect(angle.degrees.ceil(7)).to eq 0.0024673
    end
  end

  describe "::for_equatorial_coordinates" do
    it "returns equatorial coordinates" do
      elevation = 0
      latitude = Astronoby::Angle.zero
      longitude = Astronoby::Angle.zero
      time = Time.new
      true_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.zero,
        declination: Astronoby::Angle.zero
      )
      distance = 100_000_000

      apparent_coordinates = described_class.for_equatorial_coordinates(
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        time: time,
        coordinates: true_coordinates,
        distance: distance
      )

      expect(apparent_coordinates).to be_a(Astronoby::Coordinates::Equatorial)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax
    it "returns the corrected equatorial coordinates for the Moon" do
      latitude = Astronoby::Angle.from_degrees(50)
      longitude = Astronoby::Angle.from_degrees(-100)
      elevation = 60
      time = Time.utc(1979, 2, 26, 16, 45)
      true_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(22, 35, 19),
        declination: Astronoby::Angle.from_dms(-7, 41, 13)
      )
      distance =
        56.221228 * Astronoby::Constants::EARTH_EQUATORIAL_RADIUS_IN_METERS

      apparent_coordinates = described_class.for_equatorial_coordinates(
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        time: time,
        coordinates: true_coordinates,
        distance: distance
      )

      expect(apparent_coordinates.right_ascension.str(:hms))
        .to eq "22h 36m 43.2136s"
      expect(apparent_coordinates.declination.str(:dms))
        .to eq "-8° 32′ 17.18″"
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax
    it "returns the corrected equatorial coordinates for the Sun" do
      latitude = Astronoby::Angle.from_degrees(50)
      longitude = Astronoby::Angle.from_degrees(-100)
      elevation = 60
      time = Time.utc(1979, 2, 26, 16, 45)
      true_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(22, 36, 44),
        declination: Astronoby::Angle.from_dms(-8, 44, 24)
      )
      distance = 0.9901 * Astronoby::Constants::ASTRONOMICAL_UNIT_IN_METERS

      apparent_coordinates = described_class.for_equatorial_coordinates(
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        time: time,
        coordinates: true_coordinates,
        distance: distance
      )

      expect(apparent_coordinates.right_ascension.str(:hms))
        .to eq "22h 36m 44.2044s"
      expect(apparent_coordinates.declination.str(:dms))
        .to eq "-8° 44′ 31.4304″"
    end
  end
end
