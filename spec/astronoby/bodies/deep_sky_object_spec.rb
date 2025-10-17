# frozen_string_literal: true

RSpec.describe Astronoby::DeepSkyObject do
  describe "#at" do
    it "returns a DeepSkyObjectPosition instance" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 1, 1))
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.zero,
        declination: Astronoby::Angle.zero
      )
      dso = Astronoby::DeepSkyObject
        .new(equatorial_coordinates: equatorial_coordinates)

      position = dso.at(instant)

      expect(position).to be_a(Astronoby::DeepSkyObjectPosition)
    end
  end
end
