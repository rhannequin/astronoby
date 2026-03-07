# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Geodetic do
  describe ".from_ecef" do
    # Location: Alhambra, Spain — 37.176°N, 3.588°W, 792m elevation
    # ECEF computed by Astropy from_geodetic(lat=37.176, lon=-3.588, h=792)
    it "converts ECEF to geodetic at a mid-latitude location with elevation" do
      ecef = Astronoby::Distance.vector_from_meters(
        [5078870.5015264573, -318467.5350734324, 3833452.8924516011]
      )

      geodetic = described_class.from_ecef(ecef)

      expect(geodetic.latitude.degrees).to eq(37.175999999999995)
      # PROJ:    37.176000000000045
      # Astropy: 37.175999999999988

      expect(geodetic.longitude.degrees)
        .to eq(-3.5880000000000107)
      # PROJ:    -3.588000000000025
      # Astropy: -3.588000000000022

      expect(geodetic.elevation.m)
        .to eq(792.0000000009313)
      # PROJ:    792.000000005
      # Astropy: 792.000000001
    end

    # Location: Longyearbyen, Svalbard — 78.2232°N, 15.6267°E, sea level
    # ECEF computed by Astropy from_geodetic(lat=78.2232, lon=15.6267, h=0)
    it "converts ECEF to geodetic at a high-latitude location" do
      ecef = Astronoby::Distance.vector_from_meters(
        [1257699.2317273014, 351787.7978680384, 6222070.0456240186]
      )

      geodetic = described_class.from_ecef(ecef)

      expect(geodetic.latitude.degrees).to eq(78.2232)
      # PROJ:    78.223200000000006
      # Astropy: 78.223200000000006

      expect(geodetic.longitude.degrees)
        .to eq(15.626700000000003)
      # PROJ:    15.626699999999996
      # Astropy: 15.626700000000000

      expect(geodetic.elevation.m)
        .to be_within(1e-6).of(0)
      # PROJ:    -0.000000001
      # Astropy: -0.000000001
    end

    # Location: Cape Town, South Africa — 33.9249°S, 18.4241°E, sea level
    # ECEF computed by Astropy from_geodetic(lat=-33.9249, lon=18.4241, h=0)
    it "converts ECEF to geodetic in the southern hemisphere" do
      ecef = Astronoby::Distance.vector_from_meters(
        [5026357.7692455314, 1674395.1796061147, -3539537.4473233116]
      )

      geodetic = described_class.from_ecef(ecef)

      expect(geodetic.latitude.degrees).to eq(-33.924900000000015)
      # PROJ:    -33.924899999999994
      # Astropy: -33.924900000000001

      expect(geodetic.longitude.degrees).to eq(18.4241)
      # PROJ:    18.424099999999999
      # Astropy: 18.424099999999999

      expect(geodetic.elevation.m)
        .to be_within(1e-6).of(0)
      # PROJ:    0.000000000
      # Astropy: 0.000000001
    end

    # Location: Dead Sea shore — 31.5°N, 35.5°E, -430m (below sea level)
    # ECEF computed by Astropy from_geodetic(lat=31.5, lon=35.5, h=-430)
    it "converts ECEF to geodetic at negative elevation" do
      ecef = Astronoby::Distance.vector_from_meters(
        [4431121.2175243255, 3160688.0474714399, 3313062.3431777004]
      )

      geodetic = described_class.from_ecef(ecef)

      expect(geodetic.latitude.degrees)
        .to eq(31.49999999999999)
      # PROJ:    31.500000000000007
      # Astropy: 31.499999999999986

      expect(geodetic.longitude.degrees)
        .to eq(35.5)
      # PROJ:    35.500000000000000
      # Astropy: 35.500000000000000

      expect(geodetic.elevation.m)
        .to be_within(10e-10).of(-429.9999999990687)
      # PROJ:    -429.999999998
      # Astropy: -429.999999999
    end

    # Source:
    #  Title: Revisiting Spacetrack Report #3 (AIAA 2006-6753 Rev 2)
    #  Appendix C — TEME Example (2004-04-06T07:51:28.386 UTC)
    #
    # Satellite in a ~3838 km altitude orbit. TEME position propagated by
    # SGP4, then converted to ECEF via Teme#to_ecef (Vallado formulation).
    it "converts a satellite ECEF position to geodetic" do
      time = Time.utc(2004, 4, 6, 7, 51, 28.386)
      instant = Astronoby::Instant.from_time(time)
      teme = Astronoby::Teme.new(
        position: Astronoby::Distance.vector_from_meters(
          [5_094_180.16210, 6_127_644.65950, 6_380_344.53270]
        ),
        velocity: Astronoby::Velocity.vector_from_mps(
          [-4746.131487, 785.818041, 5531.931288]
        ),
        instant: instant
      )

      geodetic = described_class.from_ecef(teme.to_ecef.position)

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
end
