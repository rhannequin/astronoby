# frozen_string_literal: true

RSpec.describe Astronoby::Mercury do
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
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([-58796391, -24211914, -6830870])
      # IMCCE:    -58796367 -24211916 -6830872
      # Skyfield: -58796389 -24211921 -6830874

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("13h 29m 31.5594s")
      # IMCCE:    13h 29m 31.5617s
      # Skyfield: 13h 29m 31.56s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("-6° 7′ 53.664″")
      # IMCCE:    -6° 7′ 53.680″
      # Skyfield: -6° 7′ 53.7″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("+3° 0′ 54.0574″")
      # IMCCE:    +3° 0′ 54.055″
      # Skyfield: +3° 0′ 48.5″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+202° 58′ 41.4354″")
      # IMCCE:    +202° 58′ 41.473″
      # Skyfield: +202° 58′ 39.5″

      expect(geometric.distance.au)
        .to eq(0.4274945347661314)
      # IMCCE:    0.427494398892
      # Skyfield: 0.4274945451749377
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([8714.11694, -37601.77251, -20988.45213])
      # IMCCE:    8714.12253 -37601.77022 -20988.45147
      # Skyfield: 8714.12263 -37601.77020 -20988.45148
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
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.equatorial.right_ascension.str(:hms))
        .to eq("17h 14m 48.5473s")
      # IMCCE:    17h 14m 48.548s
      # Skyfield: 17h 14m 48.55s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("-21° 54′ 45.5553″")
      # IMCCE:    -21° 54′ 45.557″
      # Skyfield: -21° 54′ 45.6″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("+1° 7′ 0.4406″")
      # IMCCE:    +1° 7′ 0.440″
      # Skyfield: +1° 6′ 48.8″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+259° 31′ 33.854″")
      # IMCCE:    +259° 31′ 33.864″
      # Skyfield: +259° 52′ 31.4″

      expect(astrometric.distance.au)
        .to eq(1.1479011885933859)
      # IMCCE:    1.147901225109
      # Skyfield: 1.1479012250016813
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([38473.18206, -32529.64905, -18788.09274])
      # IMCCE:    38473.18746 -32529.6458 -18788.09171
      # Skyfield: 38473.18754 -32529.64572 -18788.09165
    end
  end
end
