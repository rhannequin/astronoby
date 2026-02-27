# frozen_string_literal: true

RSpec.describe Astronoby::Deflection do
  include TestEphemHelper

  describe "#corrected_position" do
    it "returns the corrected position for Mars on 2025-04-01" do
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      mars = Astronoby::Mars.new(instant: instant, ephem: ephem)
      mars_astrometric_position = mars.astrometric.position
      deflection = described_class.new(
        instant: instant,
        target_astrometric_position: mars_astrometric_position,
        ephem: ephem
      )

      corrected_position = deflection.corrected_position

      expect(corrected_position.to_a.map(&:km).map(&:round))
        .to eq([-67178486, 140336315, 69466874])
      # Skyfield: -67178487 140336316 69466874
    end

    it "returns the corrected position for Neptune on 2025-08-01" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      neptune = Astronoby::Neptune.new(instant: instant, ephem: ephem)
      neptune_astrometric_position = neptune.astrometric.position
      deflection = described_class.new(
        instant: instant,
        target_astrometric_position: neptune_astrometric_position,
        ephem: ephem
      )

      corrected_position = deflection.corrected_position

      expect(corrected_position.to_a.map(&:km).map(&:round))
        .to eq([4375229342, 154618258, -45364787])
      # Skyfield: 4375229340 154618257 -45364788
    end
  end
end
