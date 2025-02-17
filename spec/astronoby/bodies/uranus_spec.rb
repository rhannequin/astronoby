# frozen_string_literal: true

RSpec.describe Astronoby::Uranus do
  include TestEphemHelper

  describe "#geometric" do
    it "returns a Geometric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric).to be_a(Astronoby::Position::Geometric)
      expect(geometric.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(1),
            Astronoby::Distance.from_kilometers(2),
            Astronoby::Distance.from_kilometers(3)
           ]
        )
      expect(geometric.velocity)
        .to eq(
          Astronoby::Vector[
            Astronoby::Velocity.from_kilometers_per_day(4),
            Astronoby::Velocity.from_kilometers_per_day(5),
            Astronoby::Velocity.from_kilometers_per_day(6)
          ]
        )
    end

    it "computes the correct position" do
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([1570711514, 2262283646, 968602638])
      # IMCCE:    1570712997 2262283390 968602438
      # Skyfield: 1570711513 2262283647 968602638
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-5790.52952, 3035.55078, 1411.37861])
      # IMCCE:    -5790.52719 3035.55314 1411.37842
      # Skyfield: -5790.52952 3035.55077 1411.37861
    end
  end

  describe "#astrometric" do
    it "returns an Astrometric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric).to be_a(Astronoby::Position::Astrometric)
      expect(astrometric.right_ascension).to be_a(Astronoby::Angle)
      expect(astrometric.declination).to be_a(Astronoby::Angle)
      expect(astrometric.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.right_ascension.str(:hms))
        .to eq("3h 48m 47.1234s")
      # IMCCE:    3h 48m 47.1169s
      # Skyfield: 3h 48m 47.12s

      expect(astrometric.declination.str(:dms))
        .to eq("+19° 48′ 18.8202″")
      # IMCCE:    +19° 48′ 18.795″
      # Skyfield: +19° 48′ 18.8″

      expect(astrometric.distance.au)
        .to eq(20.293374076651755)
      # IMCCE:    20.293377161363
      # Skyfield: 20.293374053529913
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-34738.38374, -1183.67799, -418.31733])
      # IMCCE:    -34738.38097 -1183.6781 -418.31855
      # Skyfield: -34738.38357 -1183.67895 -418.31774
    end
  end
end
