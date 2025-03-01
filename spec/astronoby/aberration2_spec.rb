# frozen_string_literal: true

RSpec.describe Astronoby::Aberration2 do
  include TestEphemHelper

  describe "#corrected_position" do
    it "returns the corrected position for Mars on 2025-04-01" do
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      earth = Astronoby::Earth.new(instant: instant, ephem: ephem)
      mars = Astronoby::Mars.new(instant: instant, ephem: ephem)
      earth_geometric_velocity = earth.geometric.velocity
      mars_astrometric_position = mars.astrometric.position
      aberration = described_class.new(
        astrometric_position: mars_astrometric_position,
        observer_velocity: earth_geometric_velocity
      )

      corrected_position = aberration.corrected_position

      expect(corrected_position.to_a.map(&:km).map(&:round))
        .to eq([-67181971, 140334599, 69466965])
      # Skyfield: -67181974 140334600 69466966
    end

    it "returns the corrected position for Neptune on 2025-08-01" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      earth = Astronoby::Earth.new(instant: instant, ephem: ephem)
      neptune = Astronoby::Neptune.new(instant: instant, ephem: ephem)
      earth_geometric_velocity = earth.geometric.velocity
      neptune_astrometric_position = neptune.astrometric.position
      aberration = described_class.new(
        astrometric_position: neptune_astrometric_position,
        observer_velocity: earth_geometric_velocity
      )

      corrected_position = aberration.corrected_position

      expect(corrected_position.to_a.map(&:km).map(&:round))
        .to eq([4375222148, 154854265, -45253746])
      # Skyfield: 4375222144 154854263 -45253747
    end
  end
end
