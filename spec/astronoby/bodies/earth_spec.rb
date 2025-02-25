# frozen_string_literal: true

RSpec.describe Astronoby::Earth do
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
            Astronoby::Distance.from_kilometers(2),
            Astronoby::Distance.from_kilometers(4),
            Astronoby::Distance.from_kilometers(6)
          ]
        )
      expect(geometric.velocity)
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

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([-140346472, 45128538, 19591516])
      # IMCCE:    -140346454 45128536 19591514
      # Skyfield: -140346474 45128533 19591514

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("10h 48m 41.9417s")
      # IMCCE:    10h 48m 41.9414s
      # Skyfield: 10h 48m 41.94s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("+7° 34′ 11.406″")
      # IMCCE:    +7° 34′ 11.407″
      # Skyfield: +7° 34′ 11.4″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("+0° 0′ 32.9716″")
      # IMCCE:    +0° 0′ 32.971″
      # Skyfield: +0° 0′ 33.2″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+160° 40′ 55.7988″")
      # IMCCE:    +160° 40′ 55.794″
      # Skyfield: +160° 40′ 56.4″

      expect(geometric.distance.au)
        .to eq(0.9941296922100833)
      # IMCCE:    0.994129567869
      # Skyfield: 0.9941296929553649
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-10513.91311, -25850.11479, -11207.13966])
      # IMCCE:    -10513.91157 -25850.1153 -11207.13986
      # Skyfield: -10513.91205 -25850.11514 -11207.13981
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
      expect(astrometric.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(astrometric.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.equatorial.right_ascension)
        .to eq(Astronoby::Angle.zero)
      expect(astrometric.equatorial.declination).to eq(Astronoby::Angle.zero)
      expect(astrometric.ecliptic.latitude).to eq(Astronoby::Angle.zero)
      expect(astrometric.ecliptic.longitude).to eq(Astronoby::Angle.zero)
      expect(astrometric.distance).to eq(Astronoby::Distance.zero)
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([0, 0, 0])
    end
  end

  describe "#mean_of_date" do
    it "returns a MeanOfDate position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date).to be_a(Astronoby::MeanOfDate)
      expect(mean_of_date.equatorial)
        .to be_a(Astronoby::Coordinates::Equatorial)
      expect(mean_of_date.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension)
        .to eq(Astronoby::Angle.zero)
      expect(mean_of_date.equatorial.declination).to eq(Astronoby::Angle.zero)
      expect(mean_of_date.ecliptic.latitude).to eq(Astronoby::Angle.zero)
      expect(mean_of_date.ecliptic.longitude).to eq(Astronoby::Angle.zero)
      expect(mean_of_date.distance).to eq(Astronoby::Distance.zero)
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 3, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([0, 0, 0])
    end
  end
end
