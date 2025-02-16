# frozen_string_literal: true

RSpec.describe Astronoby::Jupiter do
  include TestEphemHelper

  describe "#barycentric" do
    it "returns a Barycentric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      planet = described_class.new(instant: instant, ephem: ephem)

      barycentric = planet.barycentric

      expect(barycentric).to be_a(Astronoby::Position::Barycentric)
      expect(barycentric.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(1),
            Astronoby::Distance.from_kilometers(2),
            Astronoby::Distance.from_kilometers(3)
          ]
        )
      expect(barycentric.velocity)
        .to eq(
          Astronoby::Vector[
            Astronoby::Velocity.from_kilometers_per_day(4),
            Astronoby::Velocity.from_kilometers_per_day(5),
            Astronoby::Velocity.from_kilometers_per_day(6)
          ]
        )
    end

    it "computes the correct position" do
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      barycentric = planet.barycentric

      expect(barycentric.position.to_a.map(&:km).map(&:round))
        .to eq([21224526, 703637652, 301087128])
      # IMCCE:    21224544 703637661 301087121
      # Skyfield: 21224523 703637652 301087128
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      barycentric = planet.barycentric

      expect(barycentric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-13211.65311, 787.23931, 659.07499])
      # IMCCE:    -13211.65311 787.23931 659.07488
      # Skyfield: -13211.65311 787.23928 659.07497
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
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.right_ascension.str(:hms))
        .to eq("5h 20m 58.7873s")
      # IMCCE:    5h 20m 58.7876s
      # Skyfield: 5h 20m 58.79s

      expect(astrometric.declination.str(:dms))
        .to eq("+22° 53′ 40.755″")
      # IMCCE:    +22° 53′ 40.753″
      # Skyfield: +22° 53′ 40.8″

      expect(astrometric.distance.au)
        .to eq(5.847692982822113)
      # IMCCE:    5.847693029715
      # Skyfield: 5.847693005684235
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-32111.86827, 21668.91437, 9711.35489])
      # IMCCE:    -32111.86992 21668.91306 9711.35422
      # Skyfield: -32111.8691  21668.91368 9711.35459
    end
  end
end
