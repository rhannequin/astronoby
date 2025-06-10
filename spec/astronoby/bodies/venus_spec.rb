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
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
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
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
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
        .to eq(0.5226080600832163)
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
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
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

      # Note: mean of date distance doesn't really make sense
      # Prefer astrometric.distance
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

  describe "#apparent" do
    it "returns an Apparent position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent).to be_a(Astronoby::Apparent)
      expect(apparent.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(apparent.ecliptic).to be_a(Astronoby::Coordinates::Ecliptic)
      expect(apparent.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("23h 47m 32.0505s")
      # IMCCE:    23h 47m 32.0451s
      # Skyfield: 23h 47m 32.04s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("+0° 45′ 50.3906″")
      # IMCCE:    +0° 45′ 50.391″
      # Skyfield: +0° 45′ 50.4″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("+1° 56′ 24.3295″")
      # IMCCE:    +1° 56′ 24.363″
      # Skyfield: +1° 56′ 24.8″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+357° 26′ 37.8222″")
      # IMCCE:    +357° 26′ 37.747″
      # Skyfield: +357° 26′ 38.1″

      # Note: apparent distance doesn't really make sense
      # Prefer astrometric.distance
      expect(apparent.distance.au)
        .to eq(0.522608060083216)
      # IMCCE:    0.522608040526
      # Skyfield: 0.522608044699388
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.velocity.to_a.map(&:mps).map(&:round))
        .to eq([-11951, 11243, 6940])
      # IMCCE:  -11951, 11243, 6941
    end

    context "with cache enabled" do
      it "returns the right apparent position with acceptable precision" do
        Astronoby.configuration.cache_enabled = false
        ephem = test_ephem
        first_time = Time.utc(2025, 5, 26, 10, 46, 55)
        first_instant = Astronoby::Instant.from_time(first_time)
        second_time = Time.utc(2025, 5, 26, 10, 46, 56)
        second_instant = Astronoby::Instant.from_time(second_time)
        precision = Astronoby::Angle.from_degree_arcseconds(0.0001)

        _first_apparent = described_class
          .new(instant: first_instant, ephem: ephem)
          .apparent
        second_apparent = described_class
          .new(instant: second_instant, ephem: ephem)
          .apparent
        Astronoby.configuration.cache_enabled = true
        _first_apparent_with_cache = described_class
          .new(instant: first_instant, ephem: ephem)
          .apparent
        second_apparent_with_cache = described_class
          .new(instant: second_instant, ephem: ephem)
          .apparent

        aggregate_failures do
          expect(second_apparent.equatorial.right_ascension.degrees).to(
            be_within(precision.degrees).of(
              second_apparent_with_cache.equatorial.right_ascension.degrees
            )
          )
        end

        Astronoby.reset_configuration!
      end
    end
  end

  describe "#observed_by" do
    it "returns a Topocentric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      planet = described_class.new(instant: instant, ephem: ephem)

      topocentric = planet.observed_by(observer)

      expect(topocentric).to be_a(Astronoby::Topocentric)
      expect(topocentric.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(topocentric.ecliptic).to be_a(Astronoby::Coordinates::Ecliptic)
      expect(topocentric.horizontal).to be_a(Astronoby::Coordinates::Horizontal)
      expect(topocentric.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 2, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(1.364917),
        longitude: Astronoby::Angle.from_degrees(103.822872)
      )
      planet = described_class.new(instant: instant, ephem: ephem)

      topocentric = planet.observed_by(observer)

      aggregate_failures do
        expect(topocentric.equatorial.right_ascension.str(:hms))
          .to eq("23h 47m 33.0091s")
        # IMCCE:      23h 47m 32.9892s
        # Horizons:   23h 47m 32.985655s
        # Stellarium: 23h 47m 33.0s
        # Skyfield:   23h 47m 32.99s

        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("+0° 45′ 49.8853″")
        # IMCCE:      +0° 45′ 49.871″
        # Horizons:   +0° 45′ 49.87128″
        # Stellarium: +0° 45′ 49.9″
        # Skyfield:   +0° 45′ 49.9″

        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+88° 15′ 49.8616″")
        # IMCCE:      +88° 16′ 13.440″
        # Horizons:   +88° 15′ 49.9797″
        # Stellarium: +88° 15′ 49.9″
        # Skyfield:   +88° 15′ 50.0″

        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("-31° 34′ 31.9333″")
        # IMCCE:      -31° 25′ 13.440″
        # Horizons:   -31° 34′ 29.5386″
        # Stellarium: -31° 34′ 30.5″
        # Skyfield:   -31° 34′ 29.6″

        expect(topocentric.angular_diameter.str(:dms))
          .to eq("+0° 0′ 31.9315″")
        # IMCCE:      +0° 0′ 31.9315″
        # Horizons:   +0° 0′ 31.9315″
        # Stellarium: +0° 0′ 31.93″
        # Skyfield:   +0° 0′ 31.9″
      end
    end
  end
end
