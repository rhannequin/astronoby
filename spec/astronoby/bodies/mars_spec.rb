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

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("+1° 49′ 29.7913″")
      # IMCCE:    +1° 49′ 29.791″
      # Skyfield: +1° 49′ 34.9″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+149° 27′ 6.5779″")
      # IMCCE:    +149° 27′ 6.571″
      # Skyfield: +149° 27′ 17.0″

      expect(geometric.distance.au)
        .to eq(1.6665243265178227)
      # IMCCE:    1.666524219608
      # Skyfield: 1.66652432695766
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
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
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

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("+2° 39′ 41.3343″")
      # IMCCE:    +2° 39′ 41.334″
      # Skyfield: +2° 39′ 51.8″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+113° 14′ 47.4513″")
      # IMCCE:    +113° 14′ 47.455″
      # Skyfield: +113° 35′ 57.8″

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
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension.str(:hms))
        .to eq("7h 43m 51.3343s")
      # IMCCE:  7h 43m 51.3351s

      expect(mean_of_date.equatorial.declination.str(:dms))
        .to eq("+23° 59′ 54.0557″")
      # IMCCE:  +23° 59′ 54.056″

      expect(mean_of_date.ecliptic.latitude.str(:dms))
        .to eq("+2° 39′ 52.0958″")
      # IMCCE:  +2° 39′ 52.098″

      expect(mean_of_date.ecliptic.longitude.str(:dms))
        .to eq("+113° 36′ 9.7731″")
      # IMCCE:  +113° 36′ 9.784″

      # Note: mean of date distance doesn't really make sense
      # Prefer astrometric.distance
      expect(mean_of_date.distance.au)
        .to eq(1.1389410337239916)
      # IMCCE: 1.1389410695
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-16853.58683, 9675.1645, 4072.69891])
      # IMCCE:  -16853.58852  9675.16272  4072.69963
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
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("7h 43m 50.9456s")
      # IMCCE:    7h 43m 50.9376s
      # Skyfield: 7h 43m 50.94s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("+24° 0′ 4.5798″")
      # IMCCE:    +24° 0′ 4.578″
      # Skyfield: +24° 0′ 4.6″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("+2° 40′ 1.5304″")
      # IMCCE:    +2° 40′ 1.509″
      # Skyfield: +2° 39′ 52.7″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+113° 36′ 2.6863″")
      # IMCCE:    +113° 36′ 2.578″
      # Skyfield: +113° 36′ 2.4″

      # Note: apparent distance doesn't really make sense
      # Prefer astrometric.distance
      expect(apparent.distance.au)
        .to eq(1.138989231808293)
      # IMCCE:    1.138989267589
      # Skyfield: 1.1389892520926244
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.velocity.to_a.map(&:mps).map(&:round))
        .to eq([-16855, 9675, 4073])
      # IMCCE:  -16856, 9676, 4074
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
      time = Time.utc(2025, 4, 1)
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
          .to eq("7h 43m 50.5857s")
        # IMCCE:      7h 43m 50.5809s
        # Horizons:   7h 43m 50.577366s
        # Stellarium: 7h 43m 50.57s
        # Skyfield:   7h 43m 50.58s

        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("+23° 59′ 59.7701″")
        # IMCCE:      +23° 59′ 59.875″
        # Horizons:   +23° 59′ 59.87576″
        # Stellarium: +23° 59′ 59.8″
        # Skyfield:   +23° 59′ 59.9″

        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+276° 30′ 36.6293″")
        # IMCCE:      +276° 30′ 37.080″
        # Horizons:   +276° 30′ 37.6815″
        # Stellarium: +276° 30′ 36.9″
        # Skyfield:   +276° 30′ 37.5″

        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("+26° 51′ 16.1766″")
        # IMCCE:      +26° 51′ 15.840″
        # Horizons:   +26° 51′ 15.3662″
        # Stellarium: +26° 51′ 15.9″
        # Skyfield:   +26° 51′ 15.6″

        expect(topocentric.angular_diameter.str(:dms))
          .to eq("+0° 0′ 8.2226″")
        # IMCCE:      +0° 0′ 8.2226″
        # Horizons:   +0° 0′ 8.2223″
        # Stellarium: +0° 0′ 8.22″
        # Skyfield:   +0° 0′ 8.2″
      end
    end
  end
end
