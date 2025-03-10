# frozen_string_literal: true

RSpec.describe Astronoby::Sun do
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
      body = described_class.new(instant: instant, ephem: ephem)

      geometric = body.geometric

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
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      body = described_class.new(instant: instant, ephem: ephem)

      geometric = body.geometric

      expect(geometric.position.to_a.map(&:km).map(&:round))
        .to eq([-559212, -764499, -307923])
      # IMCCE:    -559190 -764494 -307922
      # Skyfield: -559212 -764499 -307923

      expect(geometric.equatorial.right_ascension.str(:hms))
        .to eq("15h 35m 15.7135s")
      # IMCCE:    15h 35m 15.9231s
      # Skyfield: 15h 35m 15.71s

      expect(geometric.equatorial.declination.str(:dms))
        .to eq("-18° 0′ 31.6798″")
      # IMCCE:    -18° 0′ 32.520″
      # Skyfield: -18° 0′ 31.7″

      expect(geometric.ecliptic.latitude.str(:dms))
        .to eq("+1° 14′ 30.7985″")
      # IMCCE:    +1° 14′ 30.684″
      # Skyfield: +1° 14′ 20.2″

      expect(geometric.ecliptic.longitude.str(:dms))
        .to eq("+235° 50′ 1.5283″")
      # IMCCE:    +235° 50′ 4.632″
      # Skyfield: +236° 11′ 39.9″

      expect(geometric.distance.au)
        .to eq(0.00665777250935106)
      # IMCCE:    0.006657663235
      # Skyfield: 0.006657772501944235
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      body = described_class.new(instant: instant, ephem: ephem)

      geometric = body.geometric

      expect(geometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([12.78314, -1.1325, -0.75265])
      # IMCCE:    12.78314 -1.1325 -0.75264
      # Skyfield: 12.78314 -1.1325 -0.75265
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
      body = described_class.new(instant: instant, ephem: ephem)

      astrometric = body.astrometric

      expect(astrometric).to be_a(Astronoby::Astrometric)
      expect(astrometric.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(astrometric.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      body = described_class.new(instant: instant, ephem: ephem)

      astrometric = body.astrometric

      expect(astrometric.equatorial.right_ascension.str(:hms))
        .to eq("12h 28m 22.535s")
      # IMCCE:    12h 28m 22.5367s
      # Skyfield: 12h 28m 22.54s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("-3° 3′ 50.8573″")
      # IMCCE:    -3° 3′ 50.867″
      # Skyfield: -3° 3′ 50.9″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("+0° 0′ 2.2275″")
      # IMCCE:    +0° 0′ 2.228″
      # Skyfield: -0° 0′ 0.5″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+187° 43′ 27.3385″")
      # IMCCE:    +187° 43′ 27.364″
      # Skyfield: +187° 5′ 5.6″

      expect(astrometric.distance.au)
        .to eq(1.0012612435848636)
      # IMCCE:    1.001261241473
      # Skyfield: 1.0012612429694374
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      body = described_class.new(instant: instant, ephem: ephem)

      astrometric = body.astrometric

      expect(astrometric.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([4497.39334, -26976.70855, -11693.26611])
      # IMCCE:    4497.39698 -26976.70808 -11693.2659
      # Skyfield: 4497.39441 -26976.70841 -11693.26605
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
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.equatorial.right_ascension.str(:hms))
        .to eq("12h 29m 41.9491s")
      # IMCCE:  12h 29m 41.9518s

      expect(mean_of_date.equatorial.declination.str(:dms))
        .to eq("-3° 12′ 22.7338″")
      # IMCCE:  -3° 12′ 22.726″

      expect(mean_of_date.ecliptic.latitude.str(:dms))
        .to eq("-0° 0′ 0.4762″")
      # IMCCE:  -0° 0′ 0.454″

      expect(mean_of_date.ecliptic.longitude.str(:dms))
        .to eq("+188° 5′ 2.2344″")
      # IMCCE:  +188° 5′ 2.267″

      # Note: mean of date distance doesn't really make sense
      # Prefer astrometric.distance
      expect(mean_of_date.distance.au)
        .to eq(1.001261201879304)
      # IMCCE: 1.001261199767
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      mean_of_date = planet.mean_of_date

      expect(mean_of_date.velocity.to_a.map(&:mps).map { _1.round(5) })
        .to eq([4681.88376, -26950.28239, -11681.78326])
      # IMCCE:  4681.88845  -26950.28194  -11681.78252
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
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("12h 29m 40.8648s")
      # IMCCE:    12h 29m 40.8661s
      # Skyfield: 12h 29m 40.86s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("-3° 12′ 17.1328″")
      # IMCCE:    -3° 12′ 17.179″
      # Skyfield: -3° 12′ 17.2″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("-0° 0′ 1.7337″")
      # IMCCE:    -0° 0′ 1.769″
      # Skyfield: -0° 0′ 0.5″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+188° 4′ 45.1028″")
      # IMCCE:    +188° 4′ 45.137″
      # Skyfield: +188° 4′ 45.1″

      # Note: apparent distance doesn't really make sense
      # Prefer astrometric.distance
      expect(apparent.distance.au)
        .to eq(1.0012612435848636)
      # IMCCE:    1.001261241473
      # Skyfield:  1.0012612429694372
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.velocity.to_a.map(&:mps).map(&:round))
        .to eq([4682, -26950, -11683])
      # IMCCE:  4682, -26950, -11683
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
      time = Time.utc(2025, 10, 1)
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
          .to eq("12h 29m 41.4263s")
        # IMCCE:      12h 29m 41.4346s
        # Horizons:   12h 29m 41.430649s
        # Stellarium: 12h 29m 41.43s
        # Skyfield:   12h 29m 41.43s

        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("-3° 12′ 17.4766″")
        # IMCCE:      -3° 12′ 17.508″
        # Horizons:   -3° 12′ 17.50513″
        # Stellarium: -3° 12′ 17.5″
        # Skyfield:   -3° 12′ 17.5″

        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+93° 44′ 19.9902″")
        # IMCCE:      +93° 44′ 20.040″
        # Horizons:   +93° 44′ 20.1653″
        # Stellarium: +93° 44′ 20.1″
        # Skyfield:   +93° 44′ 20.2″

        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("+16° 16′ 15.4136″")
        # IMCCE:      +16° 16′ 18.120″
        # Horizons:   +16° 16′ 18.804″
        # Stellarium: +16° 16′ 18.3″
        # Skyfield:   +16° 16′ 19.2″
      end
    end

    context "with refraction" do
      it "computes the correct position" do
        time = Time.utc(2025, 10, 1)
        instant = Astronoby::Instant.from_time(time)
        ephem = test_ephem
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(1.364917),
          longitude: Astronoby::Angle.from_degrees(103.822872)
        )
        planet = described_class.new(instant: instant, ephem: ephem)

        topocentric = planet.observed_by(observer)
        horizontal = topocentric.horizontal(refraction: true)

        aggregate_failures do
          expect(horizontal.azimuth.str(:dms))
            .to eq("+93° 44′ 19.9902″")
          # Horizons:   +93° 44′ 20.1644″
          # Stellarium: +93° 44′ 20.2″
          # Skyfield:   +93° 44′ 20.2″

          expect(horizontal.altitude.str(:dms))
            .to eq("+16° 19′ 34.9175″")
          # Horizons:   +16° 19′ 42.1874″
          # Stellarium: +16° 19′ 39.8″
          # Skyfield:   +16° 19′ 39.3″

          expect(topocentric.angular_diameter.str(:dms))
            .to eq("+0° 31′ 56.0484″")
          # IMCCE:      +0° 31′ 56.0686″
          # Horizons:   +0° 31′ 56.0689″
          # Stellarium: +0° 31′ 56.04″
          # Skyfield:   +0° 31′ 56.1″
        end
      end
    end
  end

  describe "#true_ecliptic_coordinates" do
    it "returns ecliptic coordinates" do
      time = Time.new

      coordinates = described_class.new(time: time).true_ecliptic_coordinates

      expect(coordinates).to be_a(Astronoby::Coordinates::Ecliptic)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p136
    it "computes the coordinates for 2015-02-05" do
      time = Time.new(2015, 2, 5, 12, 0, 0, "-05:00")

      ecliptic_coordinates = described_class
        .new(time: time)
        .true_ecliptic_coordinates

      expect(ecliptic_coordinates.longitude.degrees).to eq 316.5726713406949
      # Result from the book: 316.562255
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p149
    #
    it "computes the coordinates for 2000-08-09" do
      time = Time.new(2000, 8, 9, 12, 0, 0, "-04:00")

      ecliptic_coordinates = described_class
        .new(time: time)
        .true_ecliptic_coordinates

      expect(ecliptic_coordinates.longitude.degrees).to eq 137.36484079770804
      # Result from the book: 137.386004
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p149
    it "computes the coordinates for 2015-05-06" do
      time = Time.new(2015, 5, 6, 14, 30, 0, "-04:00")

      ecliptic_coordinates = described_class
        .new(time: time)
        .true_ecliptic_coordinates

      expect(ecliptic_coordinates.longitude.degrees).to eq 45.921851914456795
      # Result from the book: 45.917857
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 47 - Calculating orbits more precisely, p109
    it "computes the coordinates for 1988-07-27" do
      time = Time.utc(1988, 7, 27, 0, 0, 0)
      epoch = Astronoby::Epoch.from_time(time)

      ecliptic_coordinates = described_class
        .new(time: time)
        .true_ecliptic_coordinates
      equatorial_coordinates = ecliptic_coordinates
        .to_true_equatorial(epoch: epoch)

      expect(equatorial_coordinates.right_ascension.str(:hms)).to(
        eq("8h 26m 3.6126s")
        # Result from the book: 8h 26m 4s
      )
      expect(equatorial_coordinates.declination.str(:dms)).to(
        eq("+19° 12′ 43.1502″")
        # Result from the book: 19° 12′ 43″
      )
    end
  end

  describe "#mean_anomaly" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 25 - Solar Coordinates, p.165
    it "returns the mean anomaly for 1992-10-13" do
      # Example gives 1992-04-12 00:00:00 TT (and not UTC)
      time = Time.utc(1992, 10, 13, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      sun = described_class.new(time: time)

      expect(sun.mean_anomaly.degrees.round(6)).to eq 278.989677
      # Result from the book: 278.99397°
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 47 - Position of the Moon, p.342
    it "returns the mean anomaly for 1992-04-12" do
      # Example gives 1992-04-12 00:00:00 TT (and not UTC)
      time = Time.utc(1992, 4, 12, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      sun = described_class.new(time: time)

      expect(sun.mean_anomaly.degrees.round(6)).to eq 97.639231
      # Result from the book: 97.643514°
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.148
    it "returns the mean anomaly for 2016-05-05" do
      time = Time.utc(2016, 5, 5, 12)
      sun = described_class.new(time: time)

      expect(sun.mean_anomaly.degrees.round(6)).to eq 120.573368
      # Result from the book: 120.363970°
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 65 - Calculating the Moon’s position, p.165
    it "returns the mean anomaly for 2003-09-01" do
      time = Time.utc(2003, 9, 1)
      sun = described_class.new(time: time)

      expect(sun.mean_anomaly.degrees.round(6)).to eq 236.751374
      # Result from the book: 236.642435°
    end
  end

  describe "#horizontal_coordinates" do
    it "returns horizontal coordinates" do
      time = Time.new
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(-20),
        longitude: Astronoby::Angle.from_degrees(-30)
      )

      coordinates = described_class
        .new(time: time)
        .horizontal_coordinates(observer: observer)

      expect(coordinates).to be_a(Astronoby::Coordinates::Horizontal)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.137
    it "computes the horizontal coordinates for the epoch" do
      time = Time.new(2015, 2, 5, 12, 0, 0, "-05:00")
      sun = described_class.new(time: time)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )

      horizontal_coordinates = sun.horizontal_coordinates(observer: observer)

      expect(horizontal_coordinates.altitude.str(:dms)).to(
        eq("+35° 47′ 15.7489″")
        # Result from the book: 35° 47′ 0.1″
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+172° 17′ 22.7335″")
        # Result from the book: 172° 17′ 46″
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.149
    it "computes the coordinates for a given epoch" do
      time = Time.new(2000, 8, 9, 12, 0, 0, "-05:00")
      sun = described_class.new(time: time)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(30),
        longitude: Astronoby::Angle.from_degrees(-95)
      )

      horizontal_coordinates = sun.horizontal_coordinates(observer: observer)

      expect(horizontal_coordinates.altitude.str(:dms)).to(
        eq("+65° 42′ 21.5945″")
        # Result from the book: 65° 43′
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+121° 33′ 22.4927″")
        # Result from the book: 121° 34′
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.149
    it "computes the coordinates for a given epoch" do
      time = Time.new(2015, 5, 6, 14, 30, 0, "-04:00")
      sun = described_class.new(time: time)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(-20),
        longitude: Astronoby::Angle.from_degrees(-30)
      )

      horizontal_coordinates = sun.horizontal_coordinates(observer: observer)

      expect(horizontal_coordinates.altitude.str(:dms)).to(
        eq("+13° 34′ 7.7144″")
        # Result from the book: 13° 34′
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+293° 36′ 54.0556″")
        # Result from the book: 293° 37′
      )
    end
  end

  describe "#earth_distance" do
    it "returns a Astronoby::Distance" do
      time = Time.new

      sun = described_class.new(time: time)

      expect(sun.earth_distance).to be_a Astronoby::Distance
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 48 - Calculating the Sun's distance and angular size, p.110
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(1988, 7, 27)

      sun = described_class.new(time: time)

      expect(sun.earth_distance.km.round).to eq 151_920_130
      # Result from the book: 1.519189×10^8 km
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.147
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2015, 2, 15)

      sun = described_class.new(time: time)

      expect(sun.earth_distance.km.round).to eq 147_745_410
      # Result from the book: 1.478×10^8 km
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2015, 8, 9)

      sun = described_class.new(time: time)

      expect(sun.earth_distance.km.round).to eq 151_683_527
      # Result from the book: 1.517×10^8 km
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2010, 5, 6)

      sun = described_class.new(time: time)

      expect(sun.earth_distance.km.round).to eq 150_902_254
      # Result from the book: 1.509×10^8 km
    end
  end

  describe "#angular_size" do
    it "returns an Angle" do
      time = Time.new

      sun = described_class.new(time: time)

      expect(sun.angular_size).to be_a Astronoby::Angle
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 48 - Calculating the Sun's distance and angular size, p.110
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(1988, 7, 27)

      sun = described_class.new(time: time)

      expect(sun.angular_size.str(:dms)).to eq "+0° 31′ 29.9308″"
      # Result from the book: 0° 31′ 30″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.147
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2015, 2, 15)

      sun = described_class.new(time: time)

      expect(sun.angular_size.str(:dms)).to eq "+0° 32′ 23.333″"
      # Result from the book: 0° 32′″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2015, 8, 9)

      sun = described_class.new(time: time)

      expect(sun.angular_size.str(:dms)).to eq "+0° 31′ 32.8788″"
      # Result from the book: 0° 32′″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2010, 5, 6)

      sun = described_class.new(time: time)

      expect(sun.angular_size.str(:dms)).to eq "+0° 31′ 42.6789″"
      # Result from the book: 0° 32′″
    end
  end

  describe "#observation_events" do
    describe "#rising_time" do
      # Source:
      #  Title: Celestial Calculations
      #  Author: J. L. Lawrence
      #  Edition: MIT Press
      #  Chapter: 6 - The Sun, p.139
      it "returns the sunrise time on 2015-02-05" do
        time = Time.utc(2015, 2, 5)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time).to eq Time.utc(2015, 2, 5, 12, 12, 59)
        # Time from Celestial Calculations: 2015-02-05T12:18:00
        # Time from SkySafari: 2015-02-05T12:12:57
        # Time from IMCCE: 2015-02-05T12:14:12
      end

      # Source:
      #  Title: Practical Astronomy with your Calculator or Spreadsheet
      #  Authors: Peter Duffett-Smith and Jonathan Zwart
      #  Edition: Cambridge University Press
      #  Chapter: 49 - Sunrise and sunset, p.112
      it "returns the sunrise time on 1986-03-10" do
        time = Time.utc(1986, 3, 10)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(42.37),
          longitude: Astronoby::Angle.from_degrees(-71.05)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time).to eq Time.utc(1986, 3, 10, 11, 5, 7)
        # Time from Practical Astronomy: 1986-03-10T11:06:00
        # Time from IMCCE: 1986-03-10T11:06:22
      end

      it "returns the sunrise time on 1991-03-14" do
        time = Time.utc(1991, 3, 14)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time).to eq Time.utc(1991, 3, 14, 6, 7, 23)
        # Time from IMCCE: 1991-03-14T06:08:45
      end

      context "when the given time includes a time zone far from the Greenwich meridian" do
        it "returns the sunrise time for the right date when the offset is positive" do
          time = Time.utc(1991, 3, 14)
          observer = Astronoby::Observer.new(
            latitude: Astronoby::Angle.from_degrees(-17.6509),
            longitude: Astronoby::Angle.from_degrees(-149.4260),
            utc_offset: "+12:00"
          )
          sun = described_class.new(time: time)
          observation_events = sun.observation_events(observer: observer)

          rising_time = observation_events.rising_time

          expect(rising_time.getlocal(observer.utc_offset).to_date)
            .to eq time.to_date
        end

        it "returns the sunrise time for the right date when the offset is negative" do
          time = Time.utc(1991, 3, 14)
          observer = Astronoby::Observer.new(
            latitude: Astronoby::Angle.from_degrees(-17.6509),
            longitude: Astronoby::Angle.from_degrees(-149.4260),
            utc_offset: "-12:00"
          )
          sun = described_class.new(time: time)
          observation_events = sun.observation_events(observer: observer)

          rising_time = observation_events.rising_time

          expect(rising_time.getlocal(observer.utc_offset).to_date)
            .to eq time.to_date
        end
      end
    end

    describe "#transit_time" do
      # Source:
      #  Title: Celestial Calculations
      #  Author: J. L. Lawrence
      #  Edition: MIT Press
      #  Chapter: 6 - The Sun, p.139
      it "returns the Sun's transit time on 2015-02-05" do
        time = Time.utc(2015, 2, 5)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        transit_time = observation_events.transit_time

        expect(transit_time).to eq Time.utc(2015, 2, 5, 17, 25, 59)
        # Time from SkySafari: 2015-02-05T17:26:00
        # Time from IMCCE: 2015-02-05T17:25:58
      end

      # Source:
      #  Title: Practical Astronomy with your Calculator or Spreadsheet
      #  Authors: Peter Duffett-Smith and Jonathan Zwart
      #  Edition: Cambridge University Press
      #  Chapter: 49 - Sunrise and sunset, p.112
      it "returns the Sun's transit time on 1986-03-10" do
        time = Time.utc(1986, 3, 10)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(42.37),
          longitude: Astronoby::Angle.from_degrees(-71.05)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        transit_time = observation_events.transit_time

        expect(transit_time).to eq Time.utc(1986, 3, 10, 16, 54, 31)
        # Time from IMCCE: 1986-03-10T16:54:31
      end

      it "returns the Sun's transit time on 1991-03-14" do
        time = Time.utc(1991, 3, 14)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        transit_time = observation_events.transit_time

        expect(transit_time).to eq Time.utc(1991, 3, 14, 11, 59, 58)
        # Time from IMCCE: 1991-03-14T11:59:56
      end
    end

    describe "#setting_time" do
      # Source:
      #  Title: Celestial Calculations
      #  Author: J. L. Lawrence
      #  Edition: MIT Press
      #  Chapter: 6 - The Sun, p.139
      it "returns the sunset time on 2015-02-05" do
        time = Time.utc(2015, 2, 5)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        setting_time = observation_events.setting_time

        expect(setting_time).to eq Time.utc(2015, 2, 5, 22, 39, 27)
        # Time from Celestial Calculations: 2015-02-05T22:31:00
        # Time from SkySafari: 2015-02-05T22:39:28
        # Time from IMCCE: 2015-02-05T22:38:11
      end

      # Source:
      #  Title: Practical Astronomy with your Calculator or Spreadsheet
      #  Authors: Peter Duffett-Smith and Jonathan Zwart
      #  Edition: Cambridge University Press
      #  Chapter: 49 - Sunrise and sunset, p.112
      it "returns the sunset time on 1986-03-10" do
        time = Time.utc(1986, 3, 10)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(42.37),
          longitude: Astronoby::Angle.from_degrees(-71.05)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        setting_time = observation_events.setting_time

        expect(setting_time).to eq Time.utc(1986, 3, 10, 22, 44, 36)
        # Time from Practical Astronomy: 1986-03-10T22:43:00
        # Time from IMCCE: 1986-03-10T22:43:22
      end

      it "returns the sunset time on 1991-03-14" do
        time = Time.utc(1991, 3, 14)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        setting_time = observation_events.setting_time

        expect(setting_time).to eq Time.utc(1991, 3, 14, 17, 53, 25)
        # Time from IMCCE: 1991-03-14T17:52:00
      end
    end

    context "when the given time includes a time zone far from the Greenwich meridian" do
      it "returns the sunset time for the right date when the offset is positive" do
        time = Time.utc(2024, 9, 11)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(41.87),
          longitude: Astronoby::Angle.from_degrees(-87.62),
          utc_offset: "+12:00"
        )
        sun = Astronoby::Sun.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        setting_time = observation_events.setting_time

        expect(setting_time.getlocal(observer.utc_offset).to_date)
          .to eq time.to_date
      end

      it "returns the sunset time for the right date when the offset is negative" do
        time = Time.utc(2024, 9, 11)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(41.87),
          longitude: Astronoby::Angle.from_degrees(-87.62),
          utc_offset: "-12:00"
        )
        sun = Astronoby::Sun.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        setting_time = observation_events.setting_time

        expect(setting_time.getlocal(observer.utc_offset).to_date)
          .to eq time.to_date
      end
    end
  end

  describe "#rise_set_azimuths" do
    describe "#rising_azimuth" do
      # Source:
      #  Title: Celestial Calculations
      #  Author: J. L. Lawrence
      #  Edition: MIT Press
      #  Chapter: 6 - The Sun, p.139
      it "returns the sunrise azimuth on 2015-02-05" do
        time = Time.utc(2015, 2, 5)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        rising_azimuth = observation_events.rising_azimuth

        expect(rising_azimuth.str(:dms)).to eq "+109° 29′ 35.4329″"
        # Time from SkySafari: +109° 41′ 0.3″
        # Time from IMCCE: +109° 52′ 42″
      end

      it "returns the sunrise azimuth on 1986-03-10" do
        time = Time.utc(1986, 3, 10)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(42.37),
          longitude: Astronoby::Angle.from_degrees(-71.05)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        rising_azimuth = observation_events.rising_azimuth

        expect(rising_azimuth.str(:dms)).to eq "+94° 45′ 0.7809″"
        # Time from IMCCE: +95° 01′ 55″
      end

      it "returns the sunrise azimuth on 1991-03-14" do
        time = Time.utc(1991, 3, 14)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        rising_azimuth = observation_events.rising_azimuth

        expect(rising_azimuth.str(:dms)).to eq "+93° 17′ 29.9617″"
        # Time from IMCCE: +93° 25′ 58″
      end
    end

    describe "#setting_azimuth" do
      # Source:
      #  Title: Celestial Calculations
      #  Author: J. L. Lawrence
      #  Edition: MIT Press
      #  Chapter: 6 - The Sun, p.139
      it "returns the sunset azimuth on 2015-02-05" do
        time = Time.utc(2015, 2, 5)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        setting_azimuth = observation_events.setting_azimuth

        expect(setting_azimuth.str(:dms)).to eq "+250° 40′ 41.7866″"
        # Time from SkySafari: +250° 29′ 23.6″
        # Time from IMCCE: +250° 17′ 34″
      end

      it "returns the sunset azimuth on 1986-03-10" do
        time = Time.utc(1986, 3, 10)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(42.37),
          longitude: Astronoby::Angle.from_degrees(-71.05)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        setting_azimuth = observation_events.setting_azimuth

        expect(setting_azimuth.str(:dms)).to eq "+265° 30′ 28.1817″"
        # Time from IMCCE: +265° 13′ 32″
      end

      it "returns the sunset azimuth on 1991-03-14" do
        time = Time.utc(1991, 3, 14)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        setting_azimuth = observation_events.setting_azimuth

        expect(setting_azimuth.str(:dms)).to eq "+267° 0′ 8.7437″"
        # Time from IMCCE: +266° 51′ 37″
      end
    end
  end

  describe "#transit_altitude" do
    it "returns an Angle" do
      time = Time.new
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(time: time)
      observation_events = sun.observation_events(observer: observer)

      altitude = observation_events.transit_altitude

      expect(altitude).to be_a(Astronoby::Angle)
    end

    it "returns the Sun's altitude at transit on 2015-02-05" do
      time = Time.utc(2015, 2, 5)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      sun = described_class.new(time: time)
      observation_events = sun.observation_events(observer: observer)

      altitude = observation_events.transit_altitude

      expect(altitude&.str(:dms)).to eq "+36° 8′ 14.9983″"
      # Time from SkySafari: +36° 9′ 32.5″
      # Time from IMCCE: +36° 8′ 0.3″
    end

    it "returns the Sun's altitude at transit on 1986-03-10" do
      time = Time.utc(1986, 3, 10)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(42.37),
        longitude: Astronoby::Angle.from_degrees(-71.05)
      )
      sun = described_class.new(time: time)
      observation_events = sun.observation_events(observer: observer)

      altitude = observation_events.transit_altitude

      expect(altitude&.str(:dms)).to eq "+43° 35′ 58.1877″"
      # Time from IMCCE: +45° 35′ 41″
    end

    it "returns the Sun's altitude at transit on 1991-03-14" do
      time = Time.utc(1991, 3, 14)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )
      sun = described_class.new(time: time)
      observation_events = sun.observation_events(observer: observer)

      altitude = observation_events.transit_altitude

      expect(altitude&.str(:dms)).to eq "+38° 31′ 31.3718″"
      # Time from IMCCE: +38° 31′ 20″
    end
  end

  describe "::equation_of_time" do
    it "returns an Integer" do
      date = Date.new

      equation_of_time = described_class.equation_of_time(date_or_time: date)

      expect(equation_of_time).to be_an Integer
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 51 - The equation of time, p.116
    it "returns the right value of 2010-07-27" do
      date = Date.new(2010, 7, 27)

      equation_of_time = described_class.equation_of_time(date_or_time: date)

      expect(equation_of_time).to eq(-391)
      # Value from Practical Astronomy: 392
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.148
    it "returns the right value of 2016-05-05" do
      date = Date.new(2016, 5, 5)

      equation_of_time = described_class.equation_of_time(date_or_time: date)

      expect(equation_of_time).to eq(200)
      # Value from Celestial Calculations: 199
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "returns the right value of 2015-08-09" do
      date = Date.new(2015, 8, 9)

      equation_of_time = described_class.equation_of_time(date_or_time: date)

      expect(equation_of_time).to eq(-333)
      # Value from Celestial Calculations: 337
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "returns the right value of 2010-05-06" do
      date = Date.new(2010, 5, 6)

      equation_of_time = described_class.equation_of_time(date_or_time: date)

      expect(equation_of_time).to eq(203)
      # Value from Celestial Calculations: 201
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "returns the right value of 2020-01-01" do
      date = Date.new(2020, 1, 1)

      equation_of_time = described_class.equation_of_time(date_or_time: date)

      expect(equation_of_time).to eq(-199)
      # Value from Celestial Calculations: 187
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 28 - Equation of Time, p.184
    it "returns the right value of 1992-10-13" do
      time = Time.new(1992, 10, 13, 0, 0, 0)

      equation_of_time = described_class.equation_of_time(date_or_time: time)

      expect(equation_of_time).to eq(822)
      # Value from Astronomical Algorithms: 13m 42s=822s
    end
  end
end
