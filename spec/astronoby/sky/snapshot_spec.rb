# frozen_string_literal: true

RSpec.describe Astronoby::Sky::Snapshot do
  include TestEphemHelper

  describe "#body" do
    it "returns the same body for the same class" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      snapshot = described_class.new(ephem: test_ephem, instant: instant)

      mars = snapshot.body(Astronoby::Mars)

      expect(snapshot.body(Astronoby::Mars)).to be(mars)
    end

    it "shares Earth's geometric frame between bodies" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      snapshot = described_class.new(ephem: test_ephem, instant: instant)

      mars = snapshot.body(Astronoby::Mars)
      sun = snapshot.body(Astronoby::Sun)

      expect(mars.earth_geometric).to be(sun.earth_geometric)
    end

    it "gives the Sun the geometric frame used for deflection" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      snapshot = described_class.new(ephem: test_ephem, instant: instant)

      sun = snapshot.body(Astronoby::Sun)

      expect(sun.geometric).to be(snapshot.sun_geometric)
    end

    it "computes the same positions as a body built on its own" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      ephem = test_ephem
      snapshot = described_class.new(ephem: ephem, instant: instant)
      snapshot.body(Astronoby::Sun).apparent

      shared = snapshot.body(Astronoby::Mars)
      alone = Astronoby::Mars.new(ephem: ephem, instant: instant)

      expect(shared.apparent.position).to eq(alone.apparent.position)
      expect(shared.mean_of_date.position).to eq(alone.mean_of_date.position)
      expect(shared.elongation).to eq(alone.elongation)
    end

    it "returns a body built on its own with the snapshot" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      ephem = test_ephem
      snapshot = described_class.new(ephem: ephem, instant: instant)

      sun = Astronoby::Sun.new(ephem: ephem, instant: instant, snapshot: snapshot)

      expect(snapshot.body(Astronoby::Sun)).to be(sun)
    end
  end
end
