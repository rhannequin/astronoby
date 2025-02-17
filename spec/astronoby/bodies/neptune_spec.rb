# frozen_string_literal: true

RSpec.describe Astronoby::Neptune do
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

      expect(geometric).to be_a(Astronoby::Geometric)
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
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([4469473874, 45168128, -92786635])
      # IMCCE:    4469474028 45168599 -92785689
      # Skyfield: 4469473874 45168128 -92786635
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-41.33616, 5060.74492, 2072.41945])
      # IMCCE:    -41.33619 5060.74516 2072.41966
      # Skyfield: -41.33616 5060.74492 2072.41945
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

      expect(astrometric).to be_a(Astronoby::Astrometric)
      expect(astrometric.right_ascension).to be_a(Astronoby::Angle)
      expect(astrometric.declination).to be_a(Astronoby::Angle)
      expect(astrometric.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.right_ascension.str(:hms))
        .to eq("0h 8m 5.7504s")
      # IMCCE:    0h 8m 5.7519s
      # Skyfield: 0h 8m 5.75s

      expect(astrometric.declination.str(:dms))
        .to eq("-0° 35′ 37.2556″")
      # IMCCE:    -0° 35′ 37.211″
      # Skyfield: -0° 35′ 37.3″

      expect(astrometric.distance.au)
        .to eq(29.266429831403105)
      # IMCCE:    29.26643067546
      # Skyfield: 29.266429803007693
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-22823.14692, -11920.06792, -5288.91489])
      # IMCCE:    -22823.14506 -11920.06984 -5288.91559
      # Skyfield: -22823.14626 -11920.06867 -5288.9152
    end
  end
end
