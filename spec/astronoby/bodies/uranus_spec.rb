# frozen_string_literal: true

RSpec.describe Astronoby::Uranus do
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
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([1570711514, 2262283646, 968602638])
      # IMCCE:    1570712997 2262283390 968602438
      # Skyfield: 1570711513 2262283647 968602638

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("3h 40m 54.6278s")
      # IMCCE:    3h 40m 54.6210s
      # Skyfield: 3h 40m 54.63s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("+19° 22′ 35.4493″")
      # IMCCE:    +19° 22′ 35.421″
      # Skyfield: +19° 22′ 35.4″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("-0° 13′ 11.9158″")
      # IMCCE:    -0° 13′ 11.922″
      # Skyfield: -0° 13′ 1.3″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+57° 27′ 4.2182″")
      # IMCCE:    +57° 27′ 4.118″
      # Skyfield: +57° 48′ 29.4″

      expect(geometric.distance.au)
        .to eq(19.515391974096183)
      # IMCCE:    19.51539553769
      # Skyfield: 19.51539197373322
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-5790.52952, 3035.55078, 1411.37861])
      # IMCCE:    -5790.52719 3035.55314 1411.37842
      # Skyfield: -5790.52952 3035.55077 1411.37861
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
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.equatorial.right_ascension.str(:hms))
        .to eq("3h 48m 47.1234s")
      # IMCCE:    3h 48m 47.1169s
      # Skyfield: 3h 48m 47.12s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("+19° 48′ 18.8202″")
      # IMCCE:    +19° 48′ 18.795″
      # Skyfield: +19° 48′ 18.8″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("-0° 12′ 43.8064″")
      # IMCCE:    -0° 12′ 43.812″
      # Skyfield: -0° 12′ 33.0″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+59° 21′ 17.3489″")
      # IMCCE:    +59° 21′ 17.253″
      # Skyfield: +59° 42′ 42.6″

      expect(astrometric.distance.au)
        .to eq(20.293374076651755)
      # IMCCE:    20.293377161363
      # Skyfield: 20.293374053529913
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-34738.38374, -1183.67799, -418.31733])
      # IMCCE:    -34738.38097 -1183.6781 -418.31855
      # Skyfield: -34738.38357 -1183.67895 -418.31774
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
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension.str(:hms))
        .to eq("3h 50m 16.1967s")
      # IMCCE:  3h 50m 16.1910s

      expect(mean_of_date.equatorial.declination.str(:dms))
        .to eq("+19° 52′ 55.2888″")
      # IMCCE:  +19° 52′ 55.249″

      expect(mean_of_date.ecliptic.latitude.str(:dms))
        .to eq("-0° 12′ 32.9288″")
      # IMCCE:  -0° 12′ 32.951″

      expect(mean_of_date.ecliptic.longitude.str(:dms))
        .to eq("+59° 42′ 44.1948″")
      # IMCCE:  +59° 42′ 44.106″

      # Note: mean of date distance doesn't really make sense
      # Prefer astrometric.distance
      expect(mean_of_date.distance.au)
        .to eq(20.293369161655622)
      # IMCCE: 20.293372246358
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-34730.01169, -1381.83806, -504.41467])
      # IMCCE:  -34730.00886  -1381.84071  -504.41308
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
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("3h 50m 14.8922s")
      # IMCCE:    3h 50m 14.8908s
      # Skyfield: 3h 50m 14.90s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("+19° 52′ 58.8309″")
      # IMCCE:    +19° 52′ 58.833″
      # Skyfield: +19° 52′ 58.9″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("-0° 12′ 25.543″")
      # IMCCE:    -0° 12′ 25.537″
      # Skyfield: -0° 12′ 33.0″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+59° 42′ 26.9728″")
      # IMCCE:    +59° 42′ 26.954″
      # Skyfield: +59° 42′ 27.0″

      # Note: apparent distance doesn't really make sense
      # Prefer astrometric.distance
      expect(apparent.distance.au)
        .to eq(20.293374076651755)
      # IMCCE:    20.293377161363
      # Skyfield: 20.29337405352995
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 7, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.velocity.to_a.map(&:mps).map(&:round))
        .to eq([-34730, -1382, -505])
      # IMCCE:  -34728, -1382, -505
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
      time = Time.utc(2025, 7, 1)
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
          .to eq("3h 50m 14.9094s")
        # IMCCE:      3h 50m 14.9269s
        # Horizons:   3h 50m 14.933300s
        # Stellarium: 3h 50m 14.84s
        # Skyfield:   3h 50m 14.93s

        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("+19° 52′ 58.9435″")
        # IMCCE:      +19° 52′ 58.883″
        # Horizons:   +19° 52′ 58.92164″
        # Stellarium: +19° 52′ 58.7″
        # Skyfield:   +19° 52′ 58.9″

        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+58° 50′ 32.4808″")
        # IMCCE:      +58° 50′ 31.200″
        # Horizons:   +58° 50′ 30.7697″
        # Stellarium: +58° 50′ 30.6″
        # Skyfield:   +58° 50′ 30.6″

        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("+51° 34′ 42.7214″")
        # IMCCE:      +51° 34′ 44.760″
        # Horizons:   +51° 34′ 45.1039″
        # Stellarium: +51° 34′ 46.0″
        # Skyfield:   +51° 34′ 45.4″

        expect(topocentric.angular_diameter.str(:dms))
          .to eq("+0° 0′ 3.4731″")
        # IMCCE:      +0° 0′ 3.4731″
        # Horizons:   +0° 0′ 3.4731″
        # Stellarium: +0° 0′ 3.47″
        # Skyfield:   +0° 0′ 3.5″
      end
    end
  end

  describe "#phase_angle" do
    it "returns the phase angle for 2025-07-14" do
      time = Time.utc(2025, 7, 14)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      phase_angle = planet.phase_angle

      expect(phase_angle.str(:dms)).to eq "+2° 20′ 13.0065″"
      # IMCCE:    +2° 20′ 0.5999″
      # Horizons: +2° 20′ 17.8799″
      # Skyfield: +2° 20′ 13.6″
    end
  end

  describe "#illuminated_fraction" do
    it "returns the illuminated fraction for 2025-07-14" do
      time = Time.utc(2025, 7, 14)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      illuminated_fraction = planet.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.9996
      # Skyfield: 0.9996
    end
  end

  describe "#apparent_magnitude" do
    it "returns the apparent magnitude for 2025-07-14" do
      time = Time.utc(2025, 7, 14)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent_magnitude = planet.apparent_magnitude

      expect(apparent_magnitude.round(2)).to eq(5.86)
      # IMCCE:      5.88
      # Horizons:   5.803
      # Stellarium: 5.82
      # Skyfield:   5.80
    end
  end
end
