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
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([-58796389, -24211919, -6830873])
      # IMCCE:    -58796367 -24211916 -6830872
      # Skyfield: -58796389 -24211921 -6830874

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("13h 29m 31.5605s")
      # IMCCE:    13h 29m 31.5617s
      # Skyfield: 13h 29m 31.56s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("-6° 7′ 53.673″")
      # IMCCE:    -6° 7′ 53.680″
      # Skyfield: -6° 7′ 53.7″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("+3° 0′ 54.0553″")
      # IMCCE:    +3° 0′ 54.055″
      # Skyfield: +3° 0′ 48.5″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+202° 58′ 41.4545″")
      # IMCCE:    +202° 58′ 41.473″
      # Skyfield: +202° 58′ 39.5″

      expect(geometric.distance.au)
        .to eq(0.42749454255757774)
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
        .to eq([8714.1212, -37601.77078, -20988.45164])
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
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
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
        .to eq("17h 14m 48.5478s")
      # IMCCE:    17h 14m 48.548s
      # Skyfield: 17h 14m 48.55s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("-21° 54′ 45.5567″")
      # IMCCE:    -21° 54′ 45.557″
      # Skyfield: -21° 54′ 45.6″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("+1° 7′ 0.4398″")
      # IMCCE:    +1° 7′ 0.440″
      # Skyfield: +1° 6′ 48.8″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+259° 31′ 33.8614″")
      # IMCCE:    +259° 31′ 33.864″
      # Skyfield: +259° 52′ 31.4″

      expect(astrometric.distance.au)
        .to eq(1.1479012158474204)
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
        .to eq([38473.18617, -32529.64656, -18788.09192])
      # IMCCE:    38473.18746 -32529.6458 -18788.09171
      # Skyfield: 38473.18754 -32529.64572 -18788.09165
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
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension.str(:hms))
        .to eq("17h 16m 19.4056s")
      # IMCCE:  17h 16m 19.4064s

      expect(mean_of_date.equatorial.declination.str(:dms))
        .to eq("-21° 56′ 26.4353″")
      # IMCCE:  -21° 56′ 26.426″

      expect(mean_of_date.ecliptic.latitude.str(:dms))
        .to eq("+1° 6′ 45.2412″")
      # IMCCE:  +1° 6′ 45.252″

      expect(mean_of_date.ecliptic.longitude.str(:dms))
        .to eq("+259° 52′ 42.435″")
      # IMCCE:  +259° 52′ 42.445″

      # Note: mean of date distance doesn't really make sense
      # Prefer astrometric.distance
      expect(mean_of_date.distance.au)
        .to eq(1.1480561514092467)
      # IMCCE: 1.148056160668
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([38717.64574, -32306.63034, -18692.31203])
      # IMCCE:  38717.64791  -32306.62736  -18692.31383
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
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("17h 16m 17.1912s")
      # IMCCE:    17h 16m 17.1948s
      # Skyfield: 17h 16m 17.19s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("-21° 56′ 29.1343″")
      # IMCCE:    -21° 56′ 29.130″
      # Skyfield: -21° 56′ 29.1″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("+1° 6′ 40.2274″")
      # IMCCE:    +1° 6′ 40.235″
      # Skyfield: +1° 6′ 48.6″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+259° 52′ 11.9103″")
      # IMCCE:    +259° 52′ 11.960″
      # Skyfield: +259° 52′ 11.9″

      # Note: apparent distance doesn't really make sense
      # Prefer astrometric.distance
      expect(apparent.distance.au)
        .to eq(1.1479012158474204)
      # IMCCE:    1.147901225109
      # Skyfield: 1.1479012250016805
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.velocity.to_a.map(&:mps).map(&:round))
        .to eq([38700, -32313, -18696])
      # IMCCE:  38699, -32312, -18695
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
      time = Time.utc(2025, 1, 1)
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
          .to eq("17h 16m 17.3399s")
        # IMCCE:      17h 16m 17.3296s
        # Horizons:   17h 16m 17.326217s
        # Stellarium: 17h 16m 17.34s
        # Skyfield:   17h 16m 17.33s

        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("-21° 56′ 32.7384″")
        # IMCCE:      -21° 56′ 32.702″
        # Horizons:   -21° 56′ 32.70220″
        # Stellarium: -21° 56′ 32.7″
        # Skyfield:   -21° 56′ 32.7″

        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+44° 8′ 52.5771″")
        # IMCCE:      +44° 8′ 52.800″
        # Horizons:   +44° 8′ 53.2819″
        # Stellarium: +44° 8′ 51.3″
        # Skyfield:   +44° 8′ 52.5″

        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("-56° 56′ 39.0737″")
        # IMCCE:      -56° 56′ 39.120″
        # Horizons:   -56° 56′ 38.8135″
        # Stellarium: -56° 56′ 39.5″
        # Skyfield:   -56° 56′ 39.1″
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

      expect(phase_angle.str(:dms)).to eq "+121° 7′ 10.6621″"
      # IMCCE:    +121° 7′ 32.16″
      # Horizons: +121° 6′ 47.16″
      # Skyfield: +121° 7′ 46.2″
    end
  end

  describe "#illuminated_fraction" do
    it "returns the illuminated fraction for 2025-07-14" do
      time = Time.utc(2025, 7, 14)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      illuminated_fraction = planet.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.2416
      # Skyfield: 0.2415
    end
  end

  describe "#apparent_magnitude" do
    it "returns the apparent magnitude for 2025-07-14" do
      time = Time.utc(2025, 7, 14)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent_magnitude = planet.apparent_magnitude

      expect(apparent_magnitude.round(2)).to eq(1.11)
      # IMCCE:      1.13
      # Horizons:   1.131
      # Stellarium: 1.13
      # Skyfield:   1.14
    end
  end

  describe "#angular_diameter" do
    it "returns the angular diameter for 2025-01-01" do
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      angular_diameter = planet.angular_diameter

      expect(angular_diameter.str(:dms))
        .to eq("+0° 0′ 5.8608″")
      # IMCCE:    +0° 0′ 5.8628″
      # Horizons: +0° 0′ 5.8628″
      # Skyfield: +0° 0′ 5.8608″
    end
  end

  describe "#approaching_primary?" do
    it "returns true if the moon is approaching the Sun" do
      time = Time.utc(2025, 8, 26)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem

      planet = described_class.new(instant: instant, ephem: ephem)

      expect(planet.approaching_primary?).to be true
    end

    it "returns false if the moon is receding from the Sun" do
      time = Time.utc(2025, 8, 28)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem

      planet = described_class.new(instant: instant, ephem: ephem)

      expect(planet.approaching_primary?).to be false
    end
  end

  describe "#receding_from_primary?" do
    it "returns the inverse of #approaching_primary?" do
      time = Time.utc(2025, 8, 26)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem

      planet = described_class.new(instant: instant, ephem: ephem)

      expect(planet.receding_from_primary?).to be false
    end
  end
end
