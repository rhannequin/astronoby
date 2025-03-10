# frozen_string_literal: true

RSpec.describe Astronoby::Neptune do
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
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([4469473874, 45168128, -92786635])
      # IMCCE:    4469474028 45168599 -92785689
      # Skyfield: 4469473874 45168128 -92786635

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("0h 2m 18.9615s")
      # IMCCE:    0h 2m 18.96305s
      # Skyfield: 0h 2m 18.96s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("-1° 11′ 21.2403″")
      # IMCCE:    -1° 11′ 21.197″
      # Skyfield: -1° 11′ 21.2″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("-1° 19′ 17.0443″")
      # IMCCE:    -1° 19′ 17.013″
      # Skyfield: -1° 19′ 16.0″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+0° 3′ 29.1763″")
      # IMCCE:    +0° 3′ 29.214″
      # Skyfield: +0° 24′ 59.8″

      expect(geometric.distance.au)
        .to eq(29.884550201759172)
      # IMCCE:    29.884551127591
      # Skyfield: 29.88455020171849
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-41.33616, 5060.74492, 2072.41945])
      # IMCCE:    -41.33619 5060.74516 2072.41966
      # Skyfield: -41.33616 5060.74492 2072.41945
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
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.equatorial.right_ascension.str(:hms))
        .to eq("0h 8m 5.7504s")
      # IMCCE:    0h 8m 5.7519s
      # Skyfield: 0h 8m 5.75s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("-0° 35′ 37.2556″")
      # IMCCE:    -0° 35′ 37.211″
      # Skyfield: -0° 35′ 37.3″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("-1° 20′ 58.8551″")
      # IMCCE:    -1° 20′ 58.823″
      # Skyfield: -1° 20′ 57.5″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+1° 37′ 15.5232″")
      # IMCCE:    +1° 37′ 15.560″
      # Skyfield: +1° 58′ 46.1″

      expect(astrometric.distance.au)
        .to eq(29.266429831403105)
      # IMCCE:    29.26643067546
      # Skyfield: 29.266429803007693
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      astrometric = planet.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-22823.14692, -11920.06792, -5288.91489])
      # IMCCE:    -22823.14506 -11920.06984 -5288.91559
      # Skyfield: -22823.14626 -11920.06867 -5288.9152
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
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension.str(:hms))
        .to eq("0h 9m 24.6328s")
      # IMCCE:  0h 9m 24.6353s

      expect(mean_of_date.equatorial.declination.str(:dms))
        .to eq("-0° 27′ 3.5373″")
      # IMCCE:  -0° 27′ 3.510″

      expect(mean_of_date.ecliptic.latitude.str(:dms))
        .to eq("-1° 20′ 57.5048″")
      # IMCCE:  -1° 20′ 57.494″

      expect(mean_of_date.ecliptic.longitude.str(:dms))
        .to eq("+1° 58′ 46.0608″")
      # IMCCE:  +1° 58′ 46.105″

      # Note: mean of date distance doesn't really make sense
      # Prefer astrometric.distance
      expect(mean_of_date.distance.au)
        .to eq(29.266441159466158)
      # IMCCE: 29.266442003616
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([-22741.46665, -12050.39542, -5345.5377])
      # IMCCE:  -22741.46431  -12050.39917  -5345.53618
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
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent).to be_a(Astronoby::Apparent)
      expect(apparent.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(apparent.ecliptic).to be_a(Astronoby::Coordinates::Ecliptic)
      expect(apparent.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("0h 9m 25.3759s")
      # IMCCE:    0h 9m 25.3830s
      # Skyfield: 0h 9m 25.38s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("-0° 26′ 57.939″")
      # IMCCE:    -0° 26′ 57.822″
      # Skyfield: -0° 26′ 57.9″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("-1° 20′ 56.7983″")
      # IMCCE:    -1° 20′ 56.733″
      # Skyfield: -1° 20′ 57.1″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+1° 58′ 58.5173″")
      # IMCCE:    +1° 58′ 58.661″
      # Skyfield: +1° 58′ 57.9″

      # Note: apparent distance doesn't really make sense
      # Prefer astrometric.distance
      expect(apparent.distance.au)
        .to eq(29.2664298314031)
      # IMCCE:    29.26643067546
      # Skyfield: 29.26642980300769
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.velocity.to_a.map(&:mps).map(&:round))
        .to eq([-22741, -12051, -5346])
      # IMCCE:  -22739, -12050, -5346
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
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
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
      time = Time.utc(2025, 8, 1)
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
          .to eq("0h 9m 25.386s")
        # IMCCE:      0h 9m 25.4021s
        # Horizons:   0h 9m 25.397981s
        # Stellarium: 0h 9m 25.47s
        # Skyfield:   0h 9m 25.40s

        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("-0° 26′ 58.1657″")
        # IMCCE:      -0° 26′ 58.047″
        # Horizons:   -0° 26′ 58.08781″
        # Stellarium: -0° 26′ 57.5″
        # Skyfield:   -0° 26′ 58.1″

        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+122° 25′ 44.6015″")
        # IMCCE:      +122° 25′ 47.640″
        # Horizons:   +122° 25′ 48.4763″
        # Stellarium: +122° 25′ 46.1″
        # Skyfield:   +122° 25′ 48.3″

        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("+24° 33′ 46.3338″")
        # IMCCE:      +24° 33′ 48.240″
        # Horizons:   +24° 33′ 48.7809″
        # Stellarium: +24° 33′ 48.0″
        # Skyfield:   +24° 33′ 48.3″

        expect(topocentric.angular_diameter.str(:dms))
          .to eq("+0° 0′ 2.3333″")
        # IMCCE:      +0° 0′ 2.3333″
        # Horizons:   +0° 0′ 2.3333″
        # Stellarium: +0° 0′ 2.33″
        # Skyfield:   +0° 0′ 2.3″
      end
    end
  end
end
