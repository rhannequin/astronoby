# frozen_string_literal: true

RSpec.describe Astronoby::Sky do
  include TestEphemHelper

  describe ".load" do
    it "reads bodies from every kernel" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      sky = described_class.load(
        File.expand_path("../support/data/de440s_sun_2000_2030_excerpt.bsp", __dir__),
        File.expand_path("../support/data/de440s_2025_excerpt.bsp", __dir__)
      )

      mars = sky.mars.at(instant)

      expect(mars.apparent.position.map(&:m).to_a).to eq(
        Astronoby::Mars.new(ephem: test_ephem, instant: instant)
          .apparent.position.map(&:m).to_a
      )
    end

    it "loads the lunar orientation kernel" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      sky = described_class.load(
        File.expand_path("../support/data/de440s_2025_excerpt.bsp", __dir__),
        orientation: File.expand_path(
          "../support/data/moon_pa_de440_excerpt.bpc",
          __dir__
        )
      )

      expect(sky.moon.at(instant).orientation).to be_a(Astronoby::Orientation)
    end
  end

  describe "#initialize" do
    it "raises without kernels" do
      expect { described_class.new }
        .to raise_error(ArgumentError, "At least one kernel is required")
    end
  end

  describe "bodies" do
    it "returns a target for each Solar System body" do
      sky = described_class.new(test_ephem)

      bodies = described_class::BODIES.keys.map { |name| sky.public_send(name) }

      expect(bodies.map(&:body)).to eq(described_class::BODIES.values)
    end

    it "returns the same target every time" do
      sky = described_class.new(test_ephem)

      expect(sky.saturn).to be(sky.saturn)
    end
  end

  describe "#planets" do
    it "returns the planets from Mercury to Neptune" do
      sky = described_class.new(test_ephem)

      expect(sky.planets.map(&:body)).to eq(
        [
          Astronoby::Mercury,
          Astronoby::Venus,
          Astronoby::Mars,
          Astronoby::Jupiter,
          Astronoby::Saturn,
          Astronoby::Uranus,
          Astronoby::Neptune
        ]
      )
    end
  end

  describe "#[]" do
    it "returns a target for a deep-sky object" do
      sky = described_class.new(test_ephem)
      vega = Astronoby::DeepSkyObject.new(
        equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
          declination: Astronoby::Angle.from_dms(38, 47, 1.2802)
        )
      )

      expect(sky[vega].body).to be(vega)
    end

    it "raises for anything but a deep-sky object" do
      sky = described_class.new(test_ephem)

      expect { sky[Astronoby::Mars] }.to raise_error(
        ArgumentError,
        "Expected an Astronoby::DeepSkyObject, got Astronoby::Mars"
      )
    end
  end

  describe "#snapshot_at" do
    it "shares one snapshot between bodies at the same instant" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      sky = described_class.new(test_ephem)

      mars = sky.mars.at(instant)
      sun = sky.sun.at(instant)

      expect(sky.mars.at(instant)).to be(mars)
      expect(mars.earth_geometric).to be(sun.earth_geometric)
    end

    it "does not share snapshots between skies" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      ephem = test_ephem

      mars = described_class.new(ephem).mars.at(instant)

      expect(described_class.new(ephem).mars.at(instant)).not_to be(mars)
    end

    it "does not share snapshots between fibers" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      sky = described_class.new(test_ephem)

      mars = sky.mars.at(instant)

      expect(Fiber.new { sky.mars.at(instant) }.resume).not_to be(mars)
    end

    it "keeps only the snapshot of the last instant" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      later = Astronoby::Instant.from_time(Time.utc(2025, 10, 2))
      sky = described_class.new(test_ephem)
      first = sky.snapshot_at(instant)

      sky.snapshot_at(later)

      expect(sky.snapshot_at(instant)).not_to be(first)
    end
  end

  describe "#close" do
    it "closes the kernels" do
      kernel = test_ephem
      allow(kernel).to receive(:close)
      sky = described_class.new(kernel)

      sky.close

      expect(kernel).to have_received(:close)
    end

    it "forgets this fiber's snapshot of the sky" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      sky = described_class.new(test_ephem)
      sky.snapshot_at(instant)

      sky.close

      expect(Thread.current[:astronoby_sky_snapshot]).to be_nil
    end
  end

  describe "#inspect" do
    it "shows the ephemeris" do
      sky = described_class.new(test_ephem)

      expect(sky.inspect)
        .to eq("#<Astronoby::Sky #<Astronoby::Ephem JPL DE, 1 kernel>>")
    end
  end
end
