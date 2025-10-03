# frozen_string_literal: true

RSpec.describe Astronoby::StellarPropagation do
  describe ".equatorial_coordinates_for" do
    it "returns propagated coordinates for Aldebaran on 1991-01-01" do
      time = Time.utc(1991, 1, 1)
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(4, 35, 55.23907),
        declination: Astronoby::Angle.from_dms(16, 30, 33.4885),
        epoch: Astronoby::JulianDate::J2000
      )
      proper_motion_ra = Astronoby::AngularVelocity
        .from_milliarcseconds_per_year(63.45)
      proper_motion_dec = Astronoby::AngularVelocity
        .from_milliarcseconds_per_year(-188.94)
      parallax = Astronoby::Angle.from_degree_arcseconds(48.94 / 1000.0)
      radial_velocity = Astronoby::Velocity.from_kilometers_per_second(54.398)
      instant = Astronoby::Instant.from_time(time)

      propagated_coordinates = described_class.equatorial_coordinates_for(
        equatorial_coordinates: equatorial_coordinates,
        proper_motion_ra: proper_motion_ra,
        proper_motion_dec: proper_motion_dec,
        parallax: parallax,
        radial_velocity: radial_velocity,
        instant: instant
      )

      expect(propagated_coordinates.right_ascension.str(:hms))
        .to eq("4h 35m 55.1993s")
      # Skyfield:   4h 35m 55.20s
      # Astropy:    4h 35m 55.1994s
      # Stellarium: 4h 35m 56.45s
      # SkySafari:  4h 35m 25.26

      expect(propagated_coordinates.declination.str(:dms))
        .to eq("+16° 30′ 35.206″")
      # Skyfield:   +16° 30′ 35.2″
      # Astropy:    +16° 30′ 35.1890s″
      # Stellarium: +16° 30′ 36.8″
      # SkySafari:  +16° 29′ 34.4″
    end

    it "returns propagated coordinates for Arcturus on 2040-06-01" do
      time = Time.utc(2040, 6, 1)
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(14, 15, 39.67207),
        declination: Astronoby::Angle.from_dms(19, 10, 56.6730),
        epoch: Astronoby::JulianDate::J2000
      )
      proper_motion_ra = Astronoby::AngularVelocity
        .from_milliarcseconds_per_year(-1093.39)
      proper_motion_dec = Astronoby::AngularVelocity
        .from_milliarcseconds_per_year(-2000.06)
      parallax = Astronoby::Angle.from_degree_arcseconds(88.83 / 1000.0)
      radial_velocity = Astronoby::Velocity.from_kilometers_per_second(-5.229)
      instant = Astronoby::Instant.from_time(time)

      propagated_coordinates = described_class.equatorial_coordinates_for(
        equatorial_coordinates: equatorial_coordinates,
        proper_motion_ra: proper_motion_ra,
        proper_motion_dec: proper_motion_dec,
        parallax: parallax,
        radial_velocity: radial_velocity,
        instant: instant
      )

      expect(propagated_coordinates.right_ascension.str(:hms))
        .to eq("14h 15m 36.5554s")
      # Skyfield:   14h 15m 36.55s
      # Astropy:    14h 15m 36.5533s
      # Stellarium: 14h 15m 38.02s
      # SkySafari:  14h 17m 32.65s

      expect(propagated_coordinates.declination.str(:dms))
        .to eq("+19° 9′ 35.8276″")
      # Skyfield:   +19° 9′ 35.9″
      # Astropy:    +19° 9′ 35.8378″
      # Stellarium: +19° 9′ 29.2″
      # SkySafari:  +18° 59′ 49.5″
    end
  end

  describe ".velocity_vector_for" do
    it "returns velocity vector for Aldebaran on 1991-01-01" do
      time = Time.utc(1991, 1, 1)
      equatorial_coordinates = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(4, 35, 55.23907),
        declination: Astronoby::Angle.from_dms(16, 30, 33.4885),
        epoch: Astronoby::JulianDate::J2000
      )
      proper_motion_ra = Astronoby::AngularVelocity
        .from_milliarcseconds_per_year(63.45)
      proper_motion_dec = Astronoby::AngularVelocity
        .from_milliarcseconds_per_year(-188.94)
      parallax = Astronoby::Angle.from_degree_arcseconds(48.94 / 1000.0)
      radial_velocity = Astronoby::Velocity.from_kilometers_per_second(54.398)
      instant = Astronoby::Instant.from_time(time)

      described_class.velocity_vector_for(
        equatorial_coordinates: equatorial_coordinates,
        proper_motion_ra: proper_motion_ra,
        proper_motion_dec: proper_motion_dec,
        parallax: parallax,
        radial_velocity: radial_velocity,
        instant: instant
      )
    end
  end
end
