# frozen_string_literal: true

RSpec.describe Astronoby::Venus do
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
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([-21482794, 95084793, 44132081])
      # IMCCE:    -21482780 95084796 44132082
      # Skyfield: -21482800 95084792 44132081

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("6h 50m 55.5011s")
      # IMCCE:    6h 50m 55.4992s
      # Skyfield: 6h 50m 55.50s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("+24° 21′ 26.4794″")
      # IMCCE:    +24° 21′ 26.481″
      # Skyfield: +24° 21′ 26.5″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("+1° 25′ 43.096″")
      # IMCCE:    +1° 25′ 43.095″
      # Skyfield: +1° 25′ 54.4″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+101° 35′ 6.7601″")
      # IMCCE:    +101° 35′ 6.733″
      # Skyfield: +101° 56′ 10.0″

      expect(geometric.distance.au)
        .to eq(0.7152904564103618)
      # IMCCE:    0.715290459923
      # Skyfield: 0.7152904566396294
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-34474.0445, -7108.06843, -1016.67514])
      # IMCCE:    -34474.044 -7108.07077 -1016.67618
      # Skyfield: -34474.04409 -7108.07032 -1016.67602
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
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.equatorial.right_ascension.str(:hms))
        .to eq("23h 46m 15.7468s")
      # IMCCE:    23h 46m 15.7473s
      # Skyfield: 23h 46m 15.75s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("+0° 37′ 33.7021″")
      # IMCCE:    +0° 37′ 33.706″
      # Skyfield: +0° 37′ 33.7″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("+1° 56′ 23.8202″")
      # IMCCE:    +1° 56′ 23.821″
      # Skyfield: +1° 56′ 24.3″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+357° 5′ 49.9018″")
      # IMCCE:    +357° 5′ 49.909″
      # Skyfield: +357° 26′ 52.6″

      expect(astrometric.distance.au)
        .to eq(0.5226080600832164)
      # IMCCE:    0.522608040526
      # Skyfield: 0.5226080446993883
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-11870.30081, 11309.8818, 6968.66537])
      # IMCCE:    -11870.30123 11309.88041 6968.6647
      # Skyfield: -11870.30116 11309.88069 6968.66483
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
      expect(mean_of_date.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(mean_of_date.ecliptic).to be_a(Astronoby::Coordinates::Ecliptic)
      expect(mean_of_date.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension.str(:hms))
        .to eq("23h 47m 32.4417s")
      # IMCCE:  23h 47m 32.4432s

      expect(mean_of_date.equatorial.declination.str(:dms))
        .to eq("+0° 45′ 55.1727″")
      # IMCCE:  +0° 45′ 55.161″

      expect(mean_of_date.ecliptic.latitude.str(:dms))
        .to eq("+1° 56′ 26.3864″")
      # IMCCE:  +1° 56′ 26.367″

      expect(mean_of_date.ecliptic.longitude.str(:dms))
        .to eq("+357° 26′ 45.1106″")
      # IMCCE:  +357° 26′ 45.126″

      expect(mean_of_date.distance.au)
        .to eq(0.5225487978025701)
      # IMCCE: 0.522548778247
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-11949.91565, 11240.40934, 6938.40238])
      # IMCCE:  -11949.91633  11240.4073   6938.40229
    end
  end
end
