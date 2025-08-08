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
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
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
      ephem = test_ephem_sun
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
      ephem = test_ephem_sun
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
      segment = double(state_at: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
      body = described_class.new(instant: instant, ephem: ephem)

      astrometric = body.astrometric

      expect(astrometric).to be_a(Astronoby::Astrometric)
      expect(astrometric.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(astrometric.distance).to be_a(Astronoby::Distance)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
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
        .to eq(1.0012612435848638)
      # IMCCE:    1.001261241473
      # Skyfield: 1.0012612429694374
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
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
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
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
        .to eq(1.0012612018793043)
      # IMCCE: 1.001261199767
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
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
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
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
        .to eq(1.0012612435848638)
      # IMCCE:    1.001261241473
      # Skyfield:  1.0012612429694372
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      planet = described_class.new(instant: instant, ephem: ephem)

      apparent = planet.apparent

      expect(apparent.velocity.to_a.map(&:mps).map(&:round))
        .to eq([4682, -26950, -11683])
      # IMCCE:  4682, -26950, -11683
    end

    context "with cache enabled" do
      it "returns the right apparent position with acceptable precision" do
        Astronoby.configuration.cache_enabled = false
        ephem = test_ephem_sun
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
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
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
        ephem = test_ephem_sun
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

  describe "#angular_diameter" do
    it "returns an Angle" do
      time = Time.new
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      sun = described_class.new(instant: instant, ephem: ephem)

      expect(sun.apparent.angular_diameter).to be_a Astronoby::Angle
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.147
    it "computes and return the Sun's apparent diameter for 2015-02-15" do
      time = Time.utc(2015, 2, 15)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      sun = described_class.new(instant: instant, ephem: ephem)

      expect(sun.apparent.angular_diameter.str(:dms))
        .to eq "+0° 32′ 22.4775″"
      # Result from the book: 0° 32′″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "computes and return the Sun's apparent diameter for 2015-08-09" do
      time = Time.utc(2015, 8, 9)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      sun = described_class.new(instant: instant, ephem: ephem)

      expect(sun.apparent.angular_diameter.str(:dms))
        .to eq "+0° 31′ 32.0555″"
      # Result from the book: 0° 32′″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "computes and return the Sun's apparent diameter for 2010-05-06" do
      time = Time.utc(2010, 5, 6)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      sun = described_class.new(instant: instant, ephem: ephem)

      expect(sun.apparent.angular_diameter.str(:dms))
        .to eq "+0° 31′ 41.9013″"
      # Result from the book: 0° 32′″
    end
  end

  describe "#equation_of_time" do
    it "returns an Integer" do
      time = Time.new
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      sun = described_class.new(instant: instant, ephem: ephem)

      equation_of_time = sun.equation_of_time

      expect(equation_of_time).to be_an Integer
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 51 - The equation of time, p.116
    it "returns the right value of 2010-07-27" do
      time = Time.utc(2010, 7, 27)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      sun = described_class.new(instant: instant, ephem: ephem)

      equation_of_time = sun.equation_of_time

      expect(equation_of_time).to eq(-392)
      # Value from Practical Astronomy: 392
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.148
    it "returns the right value of 2016-05-05" do
      time = Time.utc(2016, 5, 5)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      sun = described_class.new(instant: instant, ephem: ephem)

      equation_of_time = sun.equation_of_time

      expect(equation_of_time).to eq(199)
      # Value from Celestial Calculations: 199
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "returns the right value of 2015-08-09" do
      time = Time.utc(2015, 8, 9)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      sun = described_class.new(instant: instant, ephem: ephem)

      equation_of_time = sun.equation_of_time

      expect(equation_of_time).to eq(-336)
      # Value from Celestial Calculations: 337
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "returns the right value of 2010-05-06" do
      time = Time.utc(2010, 5, 6)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      sun = described_class.new(instant: instant, ephem: ephem)

      equation_of_time = sun.equation_of_time

      expect(equation_of_time).to eq(202)
      # Value from Celestial Calculations: 201
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "returns the right value of 2020-01-01" do
      time = Time.utc(2020, 1, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      sun = described_class.new(instant: instant, ephem: ephem)

      equation_of_time = sun.equation_of_time

      expect(equation_of_time).to eq(-185)
      # Value from Celestial Calculations: 187
    end
  end

  describe "#phase_angle" do
    it "returns nil" do
      time = Time.utc(2025, 7, 14)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      planet = described_class.new(instant: instant, ephem: ephem)

      phase_angle = planet.phase_angle

      expect(phase_angle).to be_nil
    end
  end

  describe "#illuminated_fraction" do
    it "returns nil" do
      time = Time.utc(2025, 7, 14)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem_sun
      planet = described_class.new(instant: instant, ephem: ephem)

      illuminated_fraction = planet.illuminated_fraction

      expect(illuminated_fraction).to be_nil
    end
  end
end
