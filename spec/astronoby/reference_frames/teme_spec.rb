# frozen_string_literal: true

RSpec.describe Astronoby::Teme do
  describe "#equatorial" do
    # Synthetic satellite in circular orbit at ~400 km altitude (ISS-like),
    # positioned on the x-axis with velocity along y.
    it "returns equatorial coordinates in the TEME system" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 6, 15, 12))
      teme = described_class.new(
        position: Astronoby::Distance.vector_from_meters(
          [6_778_137.0, 0.0, 0.0]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [0.0, 7_660.0, 0.0]
        ),
        instant: instant
      )

      expect(teme.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
    end
  end

  describe "#distance" do
    # Same synthetic satellite at ~400 km altitude.
    it "returns the geocentric distance" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 6, 15, 12))
      teme = described_class.new(
        position: Astronoby::Distance.vector_from_meters(
          [6_778_137.0, 0.0, 0.0]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [0.0, 7_660.0, 0.0]
        ),
        instant: instant
      )

      expect(teme.distance.m.round).to eq(6778137)
    end
  end

  # Source:
  #  Title: Revisiting Spacetrack Report #3 (AIAA 2006-6753 Rev 2)
  #  Appendix C — TEME Example (2004-04-06T07:51:28.386 UTC)
  #
  # Satellite in a ~3838 km altitude orbit.
  describe "#to_ecef" do
    it "converts TEME position to ECEF" do
      time = Time.utc(2004, 4, 6, 7, 51, 28.386)
      instant = Astronoby::Instant.from_time(time)
      teme = described_class.new(
        position: Astronoby::Distance.vector_from_meters(
          [5_094_180.16210, 6_127_644.65950, 6_380_344.53270]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [-4746.131487, 785.818041, 5531.931288]
        ),
        instant: instant
      )

      ecef = teme.to_ecef

      ecef.position.map(&:km).to_a.zip(
        [-1033.47521776183, 7901.305561190771, 6380.3445327]
      ).each do |actual, expected|
        expect(actual).to be_within(10e-13).of(expected)
      end
      # Vallado: [-1033.47938300, 7901.29527540, 6380.35659580]
    end

    it "converts TEME velocity to ECEF with Earth rotation correction" do
      time = Time.utc(2004, 4, 6, 7, 51, 28.386)
      instant = Astronoby::Instant.from_time(time)
      teme = described_class.new(
        position: Astronoby::Distance.vector_from_meters(
          [5_094_180.16210, 6_127_644.65950, 6_380_344.53270]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [-4746.131487, 785.818041, 5531.931288]
        ),
        instant: instant
      )

      ecef = teme.to_ecef

      ecef.velocity.map(&:kmps).to_a.zip(
        [-3.2256326093535668, -2.8724425771317836, 5.531931288]
      ).each do |actual, expected|
        expect(actual).to be_within(10e-16).of(expected)
      end
      # Vallado: [-3.225636520, -2.872451450, 5.531924446] km/s
    end

    # Same synthetic satellite at ~400 km altitude.
    it "preserves the position magnitude" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 6, 15, 12))
      teme = described_class.new(
        position: Astronoby::Distance.vector_from_meters(
          [6_778_137.0, 0.0, 0.0]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [0.0, 7_660.0, 0.0]
        ),
        instant: instant
      )

      ecef = teme.to_ecef
      ecef_r = Math.sqrt(
        ecef.position[0].m**2 +
          ecef.position[1].m**2 +
          ecef.position[2].m**2
      )

      expect(ecef_r.round).to eq(6_778_137)
    end

    it "converts ECEF position to geodetic coordinates" do
      time = Time.utc(2004, 4, 6, 7, 51, 28.386)
      instant = Astronoby::Instant.from_time(time)
      teme = described_class.new(
        position: Astronoby::Distance.vector_from_meters(
          [5_094_180.16210, 6_127_644.65950, 6_380_344.53270]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [-4746.131487, 785.818041, 5531.931288]
        ),
        instant: instant
      )

      geodetic = teme.to_ecef.geodetic

      expect(geodetic).to be_a(Astronoby::Coordinates::Geodetic)

      expect(geodetic.latitude.degrees)
        .to eq(38.80091771829925)
      # PROJ:    38.800917986034136
      # Astropy: 38.800917718516516

      expect(geodetic.longitude.degrees)
        .to be_within(10e-14).of(97.45187150776815)
      # PROJ:    97.451871507768132
      # Astropy: 97.451871507768132

      expect(geodetic.elevation.km)
        .to be_within(10e-12).of(3838.4370752648088)
      # PROJ:    3838.4371135842
      # Astropy: 3838.4370752648
    end
  end

  # Satellite at ~421 km altitude (ISS-like orbit),
  # cross-validated with Skyfield at 2025-06-15T12:00:00 UTC.
  describe "#to_gcrs" do
    it "converts TEME position to GCRS" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 6, 15, 12))
      teme = described_class.new(
        position: Astronoby::Distance.vector_from_meters(
          [4_154_639.35501, 768_141.61507, -5_327_440.28500]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [-1152.152056, 7561.143181, 192.760987]
        ),
        instant: instant
      )

      gcrs = teme.to_gcrs

      expect(gcrs).to be_a(Astronoby::Astrometric)
      expect(gcrs.center_identifier)
        .to eq(Astronoby::SolarSystemBody::EARTH)
      gcrs.position.map(&:km).to_a.zip(
        [4145.733618591874, 744.299429723425, -5337.752413125928]
      ).each do |actual, expected|
        expect(actual).to be_within(10e-13).of(expected)
      end
      # Skyfield: [4145.73382552, 744.29829062, -5337.75241124]
    end

    it "converts TEME velocity to GCRS" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 6, 15, 12))
      teme = described_class.new(
        position: Astronoby::Distance.vector_from_meters(
          [4_154_639.35501, 768_141.61507, -5_327_440.28500]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [-1152.152056, 7561.143181, 192.760987]
        ),
        instant: instant
      )

      gcrs = teme.to_gcrs

      gcrs.velocity.map(&:kmps).to_a.zip(
        [-1.1086147691425916, 7.567585344684951, 0.1952503684644861]
      ).each do |actual, expected|
        expect(actual).to be_within(10e-16).of(expected)
      end
      # Skyfield: [-1.108612705, 7.567585647, 0.195250356]
    end

    it "preserves the position magnitude" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 6, 15, 12))
      teme = described_class.new(
        position: Astronoby::Distance.vector_from_meters(
          [4_154_639.35501, 768_141.61507, -5_327_440.28500]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [-1152.152056, 7561.143181, 192.760987]
        ),
        instant: instant
      )

      gcrs = teme.to_gcrs

      expect(gcrs.distance.km).to be_within(1e-6).of(teme.distance.km)
    end
  end

  # Same ISS-like satellite at ~421 km, observed from Paris (48.8566°N, 2.3522°E).
  describe "#observed_by" do
    it "returns a Topocentric frame with valid horizontal coordinates" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 6, 15, 12))
      teme = described_class.new(
        position: Astronoby::Distance.vector_from_meters(
          [4_154_639.35501, 768_141.61507, -5_327_440.28500]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [-1152.152056, 7561.143181, 192.760987]
        ),
        instant: instant
      )
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )

      topocentric = teme.observed_by(observer)
      horizontal = topocentric.horizontal

      expect(horizontal).to be_a(Astronoby::Coordinates::Horizontal)

      expect(horizontal.altitude.degrees)
        .to eq(-58.64799656481932)
      # Skyfield: -58.64795799

      expect(horizontal.azimuth.degrees)
        .to eq(223.89473411168188)
      # Skyfield: 223.89478968
    end
  end
end
