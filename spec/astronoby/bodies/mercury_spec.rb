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
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      geometric = planet.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([-58796391, -24211914, -6830870])
      # IMCCE:    -58796367 -24211916 -6830872
      # Skyfield: -58796389 -24211921 -6830874

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("13h 29m 31.5594s")
      # IMCCE:    13h 29m 31.5617s
      # Skyfield: 13h 29m 31.56s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("-6° 7′ 53.664″")
      # IMCCE:    -6° 7′ 53.680″
      # Skyfield: -6° 7′ 53.7″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("+3° 0′ 54.0574″")
      # IMCCE:    +3° 0′ 54.055″
      # Skyfield: +3° 0′ 48.5″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+202° 58′ 41.4354″")
      # IMCCE:    +202° 58′ 41.473″
      # Skyfield: +202° 58′ 39.5″

      expect(geometric.distance.au)
        .to eq(0.4274945347661314)
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
        .to eq([8714.11694, -37601.77251, -20988.45213])
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
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
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
        .to eq("17h 14m 48.5473s")
      # IMCCE:    17h 14m 48.548s
      # Skyfield: 17h 14m 48.55s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("-21° 54′ 45.5553″")
      # IMCCE:    -21° 54′ 45.557″
      # Skyfield: -21° 54′ 45.6″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("+1° 7′ 0.4406″")
      # IMCCE:    +1° 7′ 0.440″
      # Skyfield: +1° 6′ 48.8″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+259° 31′ 33.854″")
      # IMCCE:    +259° 31′ 33.864″
      # Skyfield: +259° 52′ 31.4″

      expect(astrometric.distance.au)
        .to eq(1.1479011885933859)
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
        .to eq([38473.18206, -32529.64905, -18788.09274])
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
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension.str(:hms))
        .to eq("17h 16m 19.4051s")
      # IMCCE:  17h 16m 19.4064s

      expect(mean_of_date.equatorial.declination.str(:dms))
        .to eq("-21° 56′ 26.4339″")
      # IMCCE:  -21° 56′ 26.426″

      expect(mean_of_date.ecliptic.latitude.str(:dms))
        .to eq("+1° 6′ 45.242″")
      # IMCCE:  +1° 6′ 45.252″

      expect(mean_of_date.ecliptic.longitude.str(:dms))
        .to eq("+259° 52′ 42.4276″")
      # IMCCE:  +259° 52′ 42.445″

      # Note: mean of date distance doesn't really make sense
      # Prefer astrometric.distance
      expect(mean_of_date.distance.au)
        .to eq(1.1480561241626033)
      # IMCCE: 1.148056160668
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([38717.64165, -32306.63286, -18692.31286])
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
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("17h 16m 17.1908s")
      # IMCCE:    17h 16m 17.1948s
      # Skyfield: 17h 16m 17.19s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("-21° 56′ 29.1237″")
      # IMCCE:    -21° 56′ 29.130″
      # Skyfield: -21° 56′ 29.1″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("+1° 6′ 40.2374″")
      # IMCCE:    +1° 6′ 40.235″
      # Skyfield: +1° 6′ 48.6″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+259° 52′ 11.904″")
      # IMCCE:    +259° 52′ 11.960″
      # Skyfield: +259° 52′ 11.9″

      # Note: apparent distance doesn't really make sense
      # Prefer astrometric.distance
      expect(apparent.distance.au)
        .to eq(1.1479011885933859)
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
      time = Time.utc(2025, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8575),
        longitude: Astronoby::Angle.from_degrees(2.3514)
      )
      planet = described_class.new(instant: instant, ephem: ephem)

      topocentric = planet.observed_by(observer)

      expect(topocentric.equatorial.right_ascension.str(:hms))
        .to eq("17h 16m 16.8376s")
      # IMCCE:      17h 16m 17.3296s
      # Horizons:   17h 16m 17.326217s
      # Stellarium: 17h 16m 17.34s
      # Skyfield:   17h 16m 17.33s

      expect(topocentric.equatorial.declination.str(:dms))
        .to eq("-21° 56′ 34.0159″")
      # IMCCE:      -21° 56′ 32.702″
      # Horizons:   -21° 56′ 32.70220″
      # Stellarium: -21° 56′ 32.7″
      # Skyfield:   -21° 56′ 32.7″

      expect(topocentric.horizontal.azimuth.str(:dms))
        .to eq("+44° 9′ 3.6381″")
      # IMCCE:      +44° 8′ 52.800″
      # Horizons:   +44° 8′ 53.2819″
      # Stellarium: +44° 8′ 51.3″
      # Skyfield:   +44° 8′ 52.5″

      expect(topocentric.horizontal.altitude.str(:dms))
        .to eq("-56° 56′ 37.1146″")
      # IMCCE:      -56° 56′ 39.120″
      # Horizons:   -56° 56′ 38.8135″
      # Stellarium: -56° 56′ 39.5″
      # Skyfield:   -56° 56′ 39.1″
    end
  end
end
