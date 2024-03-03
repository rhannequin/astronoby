# frozen_string_literal: true

RSpec.describe Astronoby::Refraction do
  describe "::correct_horizontal_coordinates" do
    it "returns horizontal coordinates" do
      true_coordinates = Astronoby::Coordinates::Horizontal.new(
        azimuth: Astronoby::Angle.as_degrees(100),
        altitude: Astronoby::Angle.as_degrees(80),
        latitude: Astronoby::Angle.as_degrees(50),
        longitude: Astronoby::Angle.zero
      )

      apparent_coordinates = described_class.correct_horizontal_coordinates(
        coordinates: true_coordinates
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
        azimuth: Astronoby::Angle.as_dms(283, 16, 15.70),
        altitude: Astronoby::Angle.as_dms(19, 20, 3.64),
        latitude: Astronoby::Angle.as_degrees(52),
        longitude: Astronoby::Angle.zero
      )

      apparent_coordinates = described_class.correct_horizontal_coordinates(
        coordinates: true_coordinates,
        pressure: 1008,
        temperature: 13
      )

      expect(apparent_coordinates.azimuth).to eq(true_coordinates.azimuth)
      expect(apparent_coordinates.altitude.str(:dms)).to(
        eq("+19° 22′ 47.0924″")
      )
      expect(apparent_coordinates.latitude).to eq(true_coordinates.latitude)
      expect(apparent_coordinates.longitude).to eq(true_coordinates.longitude)
    end
  end
end
