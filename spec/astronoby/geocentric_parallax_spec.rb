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
      distance = BigDecimal("56.2212278") *
        described_class::EARTH_EQUATORIAL_RADIUS

      angle = described_class.angle(distance: distance)

      expect(angle.str(:dms)).to eq "+1° 1′ 8.9999″"
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax
    it "returns the equatorial horizontal parallax for the Sun" do
      distance = BigDecimal("0.9901") *
        described_class::ASTRONOMICAL_UNIT_IN_METERS

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
      latitude = Astronoby::Angle.as_degrees(50)
      longitude = Astronoby::Angle.as_degrees(-100)
      elevation = 60
      time = Time.utc(1979, 2, 26, 16, 45)
      true_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.as_hms(22, 35, 19),
        declination: Astronoby::Angle.as_dms(-7, 41, 13)
      )
      distance = BigDecimal("56.221228") *
        described_class::EARTH_EQUATORIAL_RADIUS

      apparent_coordinates = described_class.for_equatorial_coordinates(
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        time: time,
        coordinates: true_coordinates,
        distance: distance
      )

      expect(apparent_coordinates.right_ascension.str(:hms))
        .to eq "22h 36m 43.2195s"
      expect(apparent_coordinates.declination.str(:dms))
        .to eq "-8° 32′ 17.3947″"
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 39 - Calculating correction for parallax
    it "returns the corrected equatorial coordinates for the Sun" do
      latitude = Astronoby::Angle.as_degrees(50)
      longitude = Astronoby::Angle.as_degrees(-100)
      elevation = 60
      time = Time.utc(1979, 2, 26, 16, 45)
      true_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.as_hms(22, 36, 44),
        declination: Astronoby::Angle.as_dms(-8, 44, 24)
      )
      distance = BigDecimal("0.9901") *
        described_class::ASTRONOMICAL_UNIT_IN_METERS

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
        .to eq "-8° 44′ 31.4305″"
    end
  end
end