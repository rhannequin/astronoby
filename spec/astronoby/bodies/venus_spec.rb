# frozen_string_literal: true

RSpec.describe Astronoby::Venus do
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
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      barycentric = planet.barycentric

      expect(barycentric.position.to_a.map(&:km).map(&:round))
        .to eq([-21482794, 95084793, 44132081])
      # IMCCE:    -21482780 95084796 44132082
      # Skyfield: -21482800 95084792 44132081
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
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.right_ascension.str(:hms))
        .to eq("23h 46m 15.7468s")
      # IMCCE:    23h 46m 15.7473s
      # Skyfield: 23h 46m 15.75s

      expect(astrometric.declination.str(:dms))
        .to eq("+0° 37′ 33.7021″")
      # IMCCE:    +0° 37′ 33.706″
      # Skyfield: +0° 37′ 33.7″

      expect(astrometric.distance.au)
        .to eq(0.5226080600832164)
      # IMCCE:    0.522608040526
      # Skyfield: 0.5226080446993883
    end
  end
end
