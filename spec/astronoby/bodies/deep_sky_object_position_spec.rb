# frozen_string_literal: true

RSpec.describe Astronoby::DeepSkyObjectPosition do
  include TestEphemHelper

  describe "#astrometric" do
    it "returns an Astrometric position" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
        declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
        epoch: Astronoby::JulianDate::J2000
      )

      dso = described_class.new(
        instant: instant,
        equatorial_coordinates: equatorial_coordinates,
        proper_motion_ra: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(200.94),
        proper_motion_dec: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(286.23),
        parallax: Astronoby::Angle.from_degree_arcseconds(130.23 / 1000.0),
        radial_velocity: Astronoby::Velocity.from_kilometers_per_second(-13.5)
      )
      astrometric = dso.astrometric

      expect(astrometric).to be_a(Astronoby::Astrometric)
      expect(astrometric.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(astrometric.ecliptic).to be_a(Astronoby::Coordinates::Ecliptic)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
        declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
        epoch: Astronoby::JulianDate::J2000
      )

      dso = described_class.new(
        instant: instant,
        equatorial_coordinates: equatorial_coordinates,
        proper_motion_ra: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(200.94),
        proper_motion_dec: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(286.23),
        parallax: Astronoby::Angle.from_degree_arcseconds(130.23 / 1000.0),
        radial_velocity: Astronoby::Velocity.from_kilometers_per_second(-13.5)
      )
      astrometric = dso.astrometric

      expect(astrometric.equatorial.right_ascension.str(:hms))
        .to eq("18h 36m 56.7788s")
      # Skyfield:   18h 36m 56.77s
      # Astropy:    18h 36m 56.7789s
      # Stellarium: 18h 36m 56.54s

      expect(astrometric.equatorial.declination.str(:dms))
        .to eq("+38° 47′ 8.65″")
      # Skyfield:   +38° 47′ 8.6″
      # Astropy:    +38° 47′ 8.6506″
      # Stellarium: +38° 47′ 28.1″

      expect(astrometric.ecliptic.latitude.str(:dms))
        .to eq("+61° 44′ 4.8773″")
      # Skyfield:   +61° 44′ 4.9″
      # Astropy:    +61° 44′ 22.7949″
      # Stellarium: +61° 44′ 24.6″

      expect(astrometric.ecliptic.longitude.str(:dms))
        .to eq("+285° 19′ 11.8989″")
      # Skyfield:   +285° 19′ 11.6″
      # Astropy:    +285° 19′ 2.7549″
      # Stellarium: +285° 19′ 11.6″
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
        declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
        epoch: Astronoby::JulianDate::J2000
      )

      dso = described_class.new(
        instant: instant,
        equatorial_coordinates: equatorial_coordinates,
        ephem: ephem,
        proper_motion_ra: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(200.94),
        proper_motion_dec: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(286.23),
        parallax: Astronoby::Angle.from_degree_arcseconds(130.23 / 1000.0),
        radial_velocity: Astronoby::Velocity.from_kilometers_per_second(-13.5)
      )
      astrometric = dso.astrometric

      expect(astrometric.velocity.x.kmps.round(6)).to eq(-8.967842)
      # Skyfield: -8.967842 km/s
      # Astropy:  -8.968044 km/s

      expect(astrometric.velocity.y.kmps.round(6)).to eq(8.973822)
      # Skyfield: 8.973822 km/s
      # Astropy:  8.973012 km/s

      expect(astrometric.velocity.z.kmps.round(6)).to eq(12.026883)
      # Skyfield: 12.026883 km/s
      # Astropy:  12.026898 km/s
    end

    context "when no proper motion, parallax or radial velocity is given" do
      it "computes the correct position assuming a default distance" do
        time = Time.utc(2025, 10, 1)
        instant = Astronoby::Instant.from_time(time)
        equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
          declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
          epoch: Astronoby::JulianDate::J2000
        )

        dso = described_class.new(
          instant: instant,
          equatorial_coordinates: equatorial_coordinates
        )
        astrometric = dso.astrometric

        expect(astrometric.equatorial.right_ascension.str(:hms))
          .to eq("18h 36m 56.3363s")
        expect(astrometric.equatorial.declination.str(:dms))
          .to eq("+38° 47′ 1.2801″")
        expect(astrometric.ecliptic.latitude.str(:dms))
          .to eq("+61° 43′ 58.2722″")
        expect(astrometric.ecliptic.longitude.str(:dms))
          .to eq("+285° 18′ 58.9754″")
      end
    end
  end

  describe "#apparent" do
    it "returns an Apparent position" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
        declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
        epoch: Astronoby::JulianDate::J2000
      )

      dso = described_class.new(
        instant: instant,
        equatorial_coordinates: equatorial_coordinates,
        ephem: ephem,
        proper_motion_ra: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(200.94),
        proper_motion_dec: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(286.23),
        parallax: Astronoby::Angle.from_degree_arcseconds(130.23 / 1000.0),
        radial_velocity: Astronoby::Velocity.from_kilometers_per_second(-13.5)
      )
      apparent = dso.apparent

      expect(apparent).to be_a(Astronoby::Apparent)
      expect(apparent.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(apparent.ecliptic).to be_a(Astronoby::Coordinates::Ecliptic)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
        declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
        epoch: Astronoby::JulianDate::J2000
      )

      dso = described_class.new(
        instant: instant,
        equatorial_coordinates: equatorial_coordinates,
        ephem: ephem,
        proper_motion_ra: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(200.94),
        proper_motion_dec: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(286.23),
        parallax: Astronoby::Angle.from_degree_arcseconds(130.23 / 1000.0),
        radial_velocity: Astronoby::Velocity.from_kilometers_per_second(-13.5)
      )
      apparent = dso.apparent

      expect(apparent.equatorial.right_ascension.str(:hms))
        .to eq("18h 37m 48.7215s")
      # Skyfield:   18h 37m 48.70s
      # Astropy:    18h 37m 48.6459s
      # Stellarium: 18h 37m 48.47s
      # SkySafari:  18h 37m 48.28s

      expect(apparent.equatorial.declination.str(:dms))
        .to eq("+38° 48′ 41.4879″")
      # Skyfield:   +38° 48′ 41.5″
      # Astropy:    +38° 48′ 50.5021″
      # Stellarium: +38° 48′ 42.9″
      # SkySafari:  +38° 48′ 16.1″

      expect(apparent.ecliptic.latitude.str(:dms))
        .to eq("+61° 44′ 2.4126″")
      # Skyfield:   +61° 44′ 11.5″
      # Astropy:    +61° 44′ 11.4624″
      # Stellarium: +61° 44′ 13.2″
      # SkySafari:  +61° 43′ 47.0″

      expect(apparent.ecliptic.longitude.str(:dms))
        .to eq("+285° 40′ 42.917″")
      # Skyfield:   +285° 40′ 47.0″
      # Astropy:    +285° 40′ 47.0272″
      # Stellarium: +285° 40′ 41.9″
      # SkySafari:  +285° 40′ 29.6″
    end

    it "computes the correct velocity" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
        declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
        epoch: Astronoby::JulianDate::J2000
      )

      dso = described_class.new(
        instant: instant,
        equatorial_coordinates: equatorial_coordinates,
        ephem: ephem,
        proper_motion_ra: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(200.94),
        proper_motion_dec: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(286.23),
        parallax: Astronoby::Angle.from_degree_arcseconds(130.23 / 1000.0),
        radial_velocity: Astronoby::Velocity.from_kilometers_per_second(-13.5)
      )
      apparent = dso.apparent

      expect(apparent.velocity.x.kmps.round(6)).to eq(-9.049629)
      # Skyfield: -8.967842 km/s
      # Astropy:  -8.968044 km/s

      expect(apparent.velocity.y.kmps.round(6)).to eq(8.921273)
      # Skyfield: 8.973822 km/s
      # Astropy:  8.973012 km/s

      expect(apparent.velocity.z.kmps.round(6)).to eq(12.004694)
      # Skyfield: 12.026883 km/s
      # Astropy:  12.026898 km/s
    end

    context "when only ephem is given" do
      it "computes the correct position" do
        time = Time.utc(2025, 10, 1)
        instant = Astronoby::Instant.from_time(time)
        ephem = test_ephem
        equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
          declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
          epoch: Astronoby::JulianDate::J2000
        )

        dso = described_class.new(
          instant: instant,
          equatorial_coordinates: equatorial_coordinates,
          ephem: ephem
        )
        apparent = dso.apparent

        expect(apparent.equatorial.right_ascension.str(:hms))
          .to eq("18h 37m 48.2808s")
        expect(apparent.equatorial.declination.str(:dms))
          .to eq("+38° 48′ 34.1013″")
        expect(apparent.ecliptic.latitude.str(:dms))
          .to eq("+61° 43′ 55.8069″")
        expect(apparent.ecliptic.longitude.str(:dms))
          .to eq("+285° 40′ 29.9938″")
      end
    end

    context "when no proper motion, parallax or radial velocity is given" do
      it "computes the correct position assuming a default distance" do
        time = Time.utc(2025, 10, 1)
        instant = Astronoby::Instant.from_time(time)
        equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
          declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
          epoch: Astronoby::JulianDate::J2000
        )

        dso = described_class.new(
          instant: instant,
          equatorial_coordinates: equatorial_coordinates
        )
        apparent = dso.apparent

        expect(apparent.equatorial.right_ascension.str(:hms))
          .to eq("18h 37m 48.2804s")
        expect(apparent.equatorial.declination.str(:dms))
          .to eq("+38° 48′ 16.0412″")
        expect(apparent.ecliptic.latitude.str(:dms))
          .to eq("+61° 43′ 37.9199″")
        expect(apparent.ecliptic.longitude.str(:dms))
          .to eq("+285° 40′ 24.7275″")
      end
    end
  end

  describe "#observed_by" do
    it "returns a Topocentric position" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
        declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
        epoch: Astronoby::JulianDate::J2000
      )
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.856614),
        longitude: Astronoby::Angle.from_degrees(2.3522219)
      )

      dso = described_class.new(
        instant: instant,
        equatorial_coordinates: equatorial_coordinates,
        ephem: ephem,
        proper_motion_ra: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(200.94),
        proper_motion_dec: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(286.23),
        parallax: Astronoby::Angle.from_degree_arcseconds(130.23 / 1000.0),
        radial_velocity: Astronoby::Velocity.from_kilometers_per_second(-13.5)
      )
      topocentric = dso.observed_by(observer)

      expect(topocentric).to be_a(Astronoby::Topocentric)
      expect(topocentric.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
      expect(topocentric.ecliptic).to be_a(Astronoby::Coordinates::Ecliptic)
      expect(topocentric.horizontal).to be_a(Astronoby::Coordinates::Horizontal)
    end

    it "computes the correct position" do
      time = Time.utc(2025, 10, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
        declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
        epoch: Astronoby::JulianDate::J2000
      )
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.856614),
        longitude: Astronoby::Angle.from_degrees(2.3522219)
      )

      dso = described_class.new(
        instant: instant,
        equatorial_coordinates: equatorial_coordinates,
        ephem: ephem,
        proper_motion_ra: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(200.94),
        proper_motion_dec: Astronoby::AngularVelocity
          .from_milliarcseconds_per_year(286.23),
        parallax: Astronoby::Angle.from_degree_arcseconds(130.23 / 1000.0),
        radial_velocity: Astronoby::Velocity.from_kilometers_per_second(-13.5)
      )
      topocentric = dso.observed_by(observer)

      expect(topocentric.equatorial.right_ascension.str(:hms))
        .to eq("18h 37m 48.7215s")
      # Skyfield: 18h 37m 48.70s
      # Astropy:  18h 37m 29.3159s

      expect(topocentric.equatorial.declination.str(:dms))
        .to eq("+38° 48′ 41.4879″")
      # Skyfield: +38° 48′ 41.6″
      # Astropy:  +38° 48′ 41.6272″

      expect(topocentric.horizontal.altitude.str(:dms))
        .to eq("+26° 30′ 4.4079″")
      # Skyfield:   +26° 30′ 4.2″
      # Astropy:    +26° 30′ 4.1613″
      # Stellarium: +26° 30′ 4.1″

      expect(topocentric.horizontal.azimuth.str(:dms))
        .to eq("+299° 35′ 16.1531″")
      # Skyfield:   +299° 35′ 16.6″
      # Astropy:    +299° 35′ 16.1035″
      # Stellarium: +299° 35′ 18.7″
    end

    context "when only ephem is given" do
      it "computes the correct position" do
        time = Time.utc(2025, 10, 1)
        instant = Astronoby::Instant.from_time(time)
        ephem = test_ephem
        equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
          declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
          epoch: Astronoby::JulianDate::J2000
        )
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.856614),
          longitude: Astronoby::Angle.from_degrees(2.3522219)
        )

        dso = described_class.new(
          instant: instant,
          equatorial_coordinates: equatorial_coordinates,
          ephem: ephem
        )
        topocentric = dso.observed_by(observer)

        expect(topocentric.equatorial.right_ascension.str(:hms))
          .to eq("18h 37m 48.2808s")
        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("+38° 48′ 34.1013″")
        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("+26° 29′ 55.6114″")
        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+299° 35′ 13.9998″")
      end
    end

    context "when no proper motion, parallax or radial velocity is given" do
      it "computes the correct position" do
        time = Time.utc(2025, 10, 1)
        instant = Astronoby::Instant.from_time(time)
        equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
          declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
          epoch: Astronoby::JulianDate::J2000
        )
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.856614),
          longitude: Astronoby::Angle.from_degrees(2.3522219)
        )

        dso = described_class.new(
          instant: instant,
          equatorial_coordinates: equatorial_coordinates
        )
        topocentric = dso.observed_by(observer)

        expect(topocentric.equatorial.right_ascension.str(:hms))
          .to eq("18h 37m 48.2804s")
        expect(topocentric.equatorial.declination.str(:dms))
          .to eq("+38° 48′ 16.0412″")
        expect(topocentric.horizontal.altitude.str(:dms))
          .to eq("+26° 29′ 43.3477″")
        expect(topocentric.horizontal.azimuth.str(:dms))
          .to eq("+299° 34′ 59.186″")
      end
    end
  end
end
