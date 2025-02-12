# frozen_string_literal: true

RSpec.describe Astronoby::Earth do
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
            Astronoby::Distance.from_kilometers(2),
            Astronoby::Distance.from_kilometers(4),
            Astronoby::Distance.from_kilometers(6)
          ]
        )
      expect(barycentric.velocity)
        .to eq(
          Astronoby::Vector[
            Astronoby::Velocity.from_kilometers_per_day(8),
            Astronoby::Velocity.from_kilometers_per_day(10),
            Astronoby::Velocity.from_kilometers_per_day(12)
          ]
        )
    end

    it "computes the correct position" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      barycentric = planet.barycentric

      expect(barycentric.position.to_a.map(&:km).map(&:round))
        .to eq([-140346472, 45128538, 19591516])
      # IMCCE:    -140346454 45128536 19591514
      # Skyfield: -140346474 45128533 19591514
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
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.right_ascension).to eq(Astronoby::Angle.zero)
      expect(astrometric.declination).to eq(Astronoby::Angle.zero)
      expect(astrometric.distance).to eq(Astronoby::Distance.zero)
    end
  end
end
