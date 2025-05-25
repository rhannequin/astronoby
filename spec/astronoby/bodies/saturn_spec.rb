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
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
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
      time = Time.utc(2025, 6, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension.str(:hms))
        .to eq("0h 5m 8.9036s")
      # IMCCE:  0h 5m 8.9047s

      expect(mean_of_date.equatorial.declination.str(:dms))
        .to eq("-1° 44′ 18.9799″")
      # IMCCE:  -1° 44′ 18.997″

      expect(mean_of_date.ecliptic.latitude.str(:dms))
        .to eq("-2° 6′ 25.3471″")
      # IMCCE:  -2° 6′ 25.369″

      expect(mean_of_date.ecliptic.longitude.str(:dms))
        .to eq("+0° 29′ 21.2432″")
      # IMCCE:  +0° 29′ 21.251″

      # Note: mean of date distance doesn't really make sense
      # Prefer astrometric.distance
      expect(mean_of_date.distance.au)
        .to eq(9.878579135171094)
      # IMCCE: 9.878579058059
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 6, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-27315.85238, 17976.7133, 7592.94877])
      # IMCCE:  -27315.85388  17976.70941 7592.94947
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
      time = Time.utc(2025, 6, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("0h 5m 8.1571s")
      # IMCCE:    0h 5m 8.1636s
      # Skyfield: 0h 5m 8.16s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("-1° 44′ 22.9284″")
      # IMCCE:    -1° 44′ 22.850″
      # Skyfield: -1° 44′ 22.9″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("-2° 6′ 24.5162″")
      # IMCCE:    -2° 6′ 24.483″
      # Skyfield: -2° 6′ 24.6″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+0° 29′ 9.3958″")
      # IMCCE:    +0° 29′ 9.516″
      # Skyfield: +0° 29′ 9.2″

      # Note: apparent distance doesn't really make sense
      # Prefer astrometric.distance
      expect(apparent.distance.au)
        .to eq(9.878564650795873)
      # IMCCE:    9.878564573683
      # Skyfield: 9.878564617268687
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 6, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.velocity.to_a.map(&:mps).map(&:round))
        .to eq([-27316, 17976, 7594])
      # IMCCE:  -27313, 17975, 7593
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
      time = Time.utc(2025, 6, 1)
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
          .to eq("0h 5m 8.194s")
        # IMCCE:      0h 5m 8.1960s
        # Horizons:   0h 5m 8.192788s
        # Stellarium: 0h 5m 8.21s
        # Skyfield:   0h 5m 8.20s

        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("-1° 44′ 23.591″")
        # IMCCE:      -1° 44′ 23.505″
        # Horizons:   -1° 44′ 23.50701″
        # Stellarium: -1° 44′ 23.5″
        # Skyfield:   -1° 44′ 23.5″

        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+76° 26′ 42.3883″")
        # IMCCE:      +76° 26′ 43.440″
        # Horizons:   +76° 26′ 44.2263″
        # Stellarium: +76° 26′ 43.2″
        # Skyfield:   +76° 26′ 44.0″

        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("-13° 50′ 9.3351″")
        # IMCCE:      -13° 50′ 8.520″
        # Horizons:   -13° 50′ 7.7396″
        # Stellarium: -13° 50′ 8.6″
        # Skyfield:   -13° 50′ 7.9″

        expect(topocentric.angular_diameter.str(:dms))
          .to eq("+0° 0′ 16.8237″")
        # IMCCE:      +0° 0′ 16.8237″
        # Horizons:   +0° 0′ 16.8237″
        # Stellarium: +0° 0′ 16.82″
        # Skyfield:   +0° 0′ 16.8″
      end
    end
  end
end
