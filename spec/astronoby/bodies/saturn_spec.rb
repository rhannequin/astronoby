# frozen_string_literal: true

RSpec.describe Astronoby::Saturn do
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
      time = Time.utc(2025, 6, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([1425287156, -107081764, -105619618])
      # IMCCE:    1425287177 -107081757 -105619619
      # Skyfield: 1425287156 -107081762 -105619617

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("23h 42m 48.8261s")
      # IMCCE:    23h 42m 48.8263s
      # Skyfield: 23h 42m 48.83s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("-4° 13′ 34.4575″")
      # IMCCE:    -4° 13′ 34.458″
      # Skyfield: -4° 13′ 34.5″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("-2° 10′ 18.0315″")
      # IMCCE:    -2° 10′ 18.032″
      # Skyfield: -2° 10′ 18.1″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+354° 22′ 47.1815″")
      # IMCCE:    +354° 22′ 47.182″
      # Skyfield: +354° 44′ 7.3″

      expect(geometric.distance.au)
        .to eq(9.580357829890923)
      # IMCCE:    9.580357970998
      # Skyfield: 9.580357829243903
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 6, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([410.67305, 8873.99334, 3647.70519])
      # IMCCE:    410.67305 8873.99334 3647.70521
      # Skyfield: 410.673037 8873.99334 3647.70519
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
      time = Time.utc(2025, 6, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.equatorial.right_ascension.str(:hms))
        .to eq("0h 3m 50.3691s")
      # IMCCE:    0h 3m 50.3693s
      # Skyfield: 0h 3m 50.37s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("-1° 52′ 50.7217″")
      # IMCCE:    -1° 52′ 50.722″
      # Skyfield: -1° 52′ 50.7″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("-2° 6′ 26.3397″")
      # IMCCE:    -2° 6′ 26.340″
      # Skyfield: -2° 6′ 25.3″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+0° 7′ 56.1071″")
      # IMCCE:    +0° 7′ 56.108″
      # Skyfield: +0° 29′ 16.2″

      expect(astrometric.distance.au)
        .to eq(9.878564650795877)
      # IMCCE:    9.878564573683
      # Skyfield: 9.878564617268683
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 6, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-27194.09926, 18131.58422, 7660.22589])
      # IMCCE:    -27194.10006 18131.58209 7660.22501
      # Skyfield: -27194.09962 18131.5833  7660.22549
    end
  end
end
