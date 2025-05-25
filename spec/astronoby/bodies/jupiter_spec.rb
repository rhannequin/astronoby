# frozen_string_literal: true

RSpec.describe Astronoby::Jupiter do
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
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([21224526, 703637652, 301087128])
      # IMCCE:    21224544 703637661 301087121
      # Skyfield: 21224523 703637652 301087128

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("5h 53m 5.3409s")
      # IMCCE:    5h 53m 5.3406s
      # Skyfield: 5h 53m 5.34s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("+23° 9′ 24.1204″")
      # IMCCE:    +23° 9′ 24.118″
      # Skyfield: +23° 9′ 24.1″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("-0° 16′ 22.9896″")
      # IMCCE:    -0° 16′ 22.992″
      # Skyfield: -0° 16′ 11.1″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+88° 24′ 41.3024″")
      # IMCCE:    +88° 24′ 41.297″
      # Skyfield: +88° 24′ 55.4″

      expect(geometric.distance.au)
        .to eq(5.118010310588575)
      # IMCCE:    5.11801034937
      # Skyfield: 5.118010311352852
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
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
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric).to be_a(Astronoby::Astrometric)
      expect(astrometric.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(astrometric.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.equatorial.right_ascension.str(:hms))
        .to eq("5h 20m 58.7873s")
      # IMCCE:    5h 20m 58.7876s
      # Skyfield: 5h 20m 58.79s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("+22° 53′ 40.755″")
      # IMCCE:    +22° 53′ 40.753″
      # Skyfield: +22° 53′ 40.8″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("-0° 14′ 27.7664″")
      # IMCCE:    -0° 14′ 27.769″
      # Skyfield: -0° 14′ 15.9″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+81° 1′ 11.959″")
      # IMCCE:    +81° 1′ 11.962″
      # Skyfield: +81° 22′ 26.1″

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
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension.str(:hms))
        .to eq("5h 22m 31.431s")
      # IMCCE:  5h 22m 31.4319s

      expect(mean_of_date.equatorial.declination.str(:dms))
        .to eq("+22° 55′ 5.8692″")
      # IMCCE:  +22° 55′ 5.858″

      expect(mean_of_date.ecliptic.latitude.str(:dms))
        .to eq("-0° 14′ 15.6927″")
      # IMCCE:  -0° 14′ 15.705″

      expect(mean_of_date.ecliptic.longitude.str(:dms))
        .to eq("+81° 22′ 34.8729″")
      # IMCCE:  +81° 22′ 34.883″

      # Note: mean of date distance doesn't really make sense
      # Prefer astrometric.distance
      expect(mean_of_date.distance.au)
        .to eq(5.847671713145707)
      # IMCCE: 5.847671760041
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-32257.90536, 21486.0083, 9631.88754])
      # IMCCE:  -32257.90781  21486.0049  9631.88872
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
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("5h 22m 29.6585s")
      # IMCCE:    5h 22m 29.6539s
      # Skyfield: 5h 22m 29.65s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("+22° 55′ 12.9743″")
      # IMCCE:    +22° 55′ 12.966″
      # Skyfield: +22° 55′ 13.0″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("-0° 14′ 7.0163″")
      # IMCCE:    -0° 14′ 7.020″
      # Skyfield: -0° 14′ 16.0″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+81° 22′ 10.8961″")
      # IMCCE:    +81° 22′ 10.8961″
      # Skyfield: +81° 22′ 10.8″

      # Note: apparent distance doesn't really make sense
      # Prefer astrometric.distance
      expect(apparent.distance.au)
        .to eq(5.847692982822112)
      # IMCCE:    5.847693029715
      # Skyfield: 5.847693005684232
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.velocity.to_a.map(&:mps).map(&:round))
        .to eq([-32258, 21486, 9633])
      # IMCCE:  -32260, 21488, 9634
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
      time = Time.utc(2025, 5, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8575),
        longitude: Astronoby::Angle.from_degrees(2.3514)
      )
      planet = described_class.new(instant: instant, ephem: ephem)

      topocentric = planet.observed_by(observer)

      aggregate_failures do
        expect(topocentric.equatorial.right_ascension.str(:hms))
          .to eq("5h 22m 29.6137s")
        # IMCCE:      5h 22m 29.5968s
        # Horizons:   5h 22m 29.591246s
        # Stellarium: 5h 22m 29.61s
        # Skyfield:   5h 22m 29.60s

        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("+22° 55′ 11.6338″")
        # IMCCE:      +22° 55′ 11.680″
        # Horizons:   +22° 55′ 11.68271″
        # Stellarium: +22° 55′ 11.6″
        # Skyfield:   +22° 55′ 11.7″

        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+323° 49′ 59.1107″")
        # IMCCE:      +323° 49′ 59.520″
        # Skyfield:   +323° 50′ 0.2″
        # Stellarium: +323° 49′ 59.2″
        # Horizons:   +323° 50′ 0.3937″

        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("-10° 11′ 48.7385″")
        # IMCCE:      -10° 11′ 48.840″
        # Skyfield:   -10° 11′ 49.2″
        # Stellarium: -10° 11′ 48.8″
        # Horizons:   -10° 11′ 49.2716″

        expect(topocentric.angular_diameter.str(:dms))
          .to eq("+0° 0′ 33.7133″")
        # IMCCE:      +0° 0′ 33.7133″
        # Horizons:   +0° 0′ 33.7131″
        # Stellarium: +0° 0′ 33.72″
        # Skyfield:   +0° 0′ 33.7″
      end
    end
  end
end
