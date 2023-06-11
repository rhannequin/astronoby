# frozen_string_literal: true

RSpec.describe Astronoby::Aberration do
  describe "::for_ecliptic_coordinates" do
    it "returns apparent ecliptic coordinates" do
      true_coordinates = Astronoby::Coordinates::Ecliptic.new(
        latitude: Astronoby::Angle.as_dms(20, 30, 40),
        longitude: Astronoby::Angle.as_dms(30, 40, 50)
      )
      sun_longitude = Astronoby::Angle.as_dms(40, 50, 60)

      apparent_coordinates = described_class.for_ecliptic_coordinates(
        coordinates: true_coordinates,
        sun_longitude: sun_longitude
      )

      expect(apparent_coordinates).to be_a(Astronoby::Coordinates::Ecliptic)
      expect(apparent_coordinates.latitude).not_to(
        eq(true_coordinates.latitude)
      )
      expect(apparent_coordinates.longitude).not_to(
        eq(true_coordinates.longitude)
      )
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 36 - Aberration
    it "computes accurate apparent coordinates" do
      true_coordinates = Astronoby::Coordinates::Ecliptic.new(
        latitude: Astronoby::Angle.as_dms(-1, 32, 56.4),
        longitude: Astronoby::Angle.as_dms(352, 37, 10.1)
      )
      sun_longitude = Astronoby::Angle.as_dms(165, 33, 44.1)

      apparent_coordinates = described_class.for_ecliptic_coordinates(
        coordinates: true_coordinates,
        sun_longitude: sun_longitude
      )

      expect(apparent_coordinates.latitude.to_dms.format).to(
        eq("-1° 32′ 56.3319″")
      )
      expect(apparent_coordinates.longitude.to_dms.format).to(
        eq("+352° 37′ 30.4521″")
      )
    end
  end
end
