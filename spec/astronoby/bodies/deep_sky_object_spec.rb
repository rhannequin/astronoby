# frozen_string_literal: true

RSpec.describe Astronoby::DeepSkyObject do
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
end
