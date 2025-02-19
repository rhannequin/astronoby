# frozen_string_literal: true

RSpec.describe Astronoby::Mars do
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
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([-214596103, 113040908, 57662718])
      # IMCCE:    -214596085 113040908 57662716
      # Skyfield: -214596105 113040905 57662716

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("10h 8m 53.1545s")
      # IMCCE:    10h 8m 53.1541s
      # Skyfield: 10h 8m 53.15s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("+13° 22′ 23.046″")
      # IMCCE:    +13° 22′ 23.048″
      # Skyfield: +13° 22′ 23.0″
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-11481.41012, -17158.09524, -7560.12399])
      # IMCCE:    -11481.40954 -17158.09555 -7560.12413
      # Skyfield: -11481.40978 -17158.09542 -7560.12408
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

      expect(astrometric.equatorial.right_ascension.str(:hms))
        .to eq("7h 42m 19.2644s")
      # IMCCE:    7h 42m 19.2648s
      # Skyfield: 7h 42m 19.26s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("+24° 3′ 35.8686″")
      # IMCCE:    +24° 3′ 35.868″
      # Skyfield: +24° 3′ 35.9″

      expect(astrometric.distance.au)
        .to eq(1.138989231808293)
      # IMCCE:    1.138989267589
      # Skyfield: 1.138989252092628
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-16789.69787, 9770.68835, 4114.2449])
      # IMCCE:    -16789.69917 9770.68769 4114.2446
      # Skyfield: -16789.69861 9770.68797 4114.24472
    end
  end
end
