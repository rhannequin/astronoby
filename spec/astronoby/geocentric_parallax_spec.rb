# frozen_string_literal: true

RSpec.describe Astronoby::GeocentricParallax do
  describe "::angle" do
    it "returns an Angle" do
      distance = Astronoby::Distance.from_meters(1_000_000_000)

      expect(described_class.angle(distance: distance))
        .to be_a(Astronoby::Angle)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax
    it "returns the equatorial horizontal parallax for the Moon" do
      distance = Astronoby::Distance.from_meters(
        56.2212278 * Astronoby::Constants::EARTH_EQUATORIAL_RADIUS_IN_METERS
      )

      angle = described_class.angle(distance: distance)

      expect(angle.str(:dms)).to eq "+1° 1′ 8.7447″"
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax
    it "returns the equatorial horizontal parallax for the Sun" do
      distance = Astronoby::Distance.from_au(0.9901)

      angle = described_class.angle(distance: distance)

      expect(angle.degrees.ceil(7)).to eq 0.0024673
    end
  end

  describe "::for_equatorial_coordinates" do
    it "returns equatorial coordinates" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        elevation: Astronoby::Distance.zero
      )
      time = Time.new
      true_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.zero,
        declination: Astronoby::Angle.zero
      )
      distance = Astronoby::Distance.from_meters(100_000_000)

      apparent_coordinates = described_class.for_equatorial_coordinates(
        observer: observer,
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
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(50),
        longitude: Astronoby::Angle.from_degrees(-100),
        elevation: Astronoby::Distance.from_meters(60)
      )
      time = Time.utc(1979, 2, 26, 16, 45)
      true_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(22, 35, 19),
        declination: Astronoby::Angle.from_dms(-7, 41, 13)
      )
      distance = Astronoby::Distance.from_meters(
        56.2212278 * Astronoby::Constants::EARTH_EQUATORIAL_RADIUS_IN_METERS
      )

      apparent_coordinates = described_class.for_equatorial_coordinates(
        observer: observer,
        time: time,
        coordinates: true_coordinates,
        distance: distance
      )

      expect(apparent_coordinates.right_ascension.str(:hms))
        .to eq "22h 36m 43.2106s"
      expect(apparent_coordinates.declination.str(:dms))
        .to eq "-8° 32′ 17.184″"
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax
    it "returns the corrected equatorial coordinates for the Sun" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(50),
        longitude: Astronoby::Angle.from_degrees(-100),
        elevation: Astronoby::Distance.from_meters(60)
      )
      time = Time.utc(1979, 2, 26, 16, 45)
      true_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(22, 36, 44),
        declination: Astronoby::Angle.from_dms(-8, 44, 24)
      )
      distance = Astronoby::Distance.from_au(0.9901)

      apparent_coordinates = described_class.for_equatorial_coordinates(
        observer: observer,
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
