# frozen_string_literal: true

RSpec.describe Astronoby::Moon do
  describe "#apparent_ecliptic_coordinates" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 47 - Position of the Moon, p.342
    it "returns the apparent ecliptic coordinates for 1992-04-12" do
      # Example gives 1992-04-12 00:00:00 TT (and not UTC)
      time = Time.utc(1992, 4, 12, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      moon = described_class.new(time: time)

      coordinates = moon.apparent_ecliptic_coordinates

      expect(coordinates.latitude.str(:dms)).to eq "-3° 13′ 44.8543″"
      # Result from the book: -3° 13′ 45″
      # Result from IMCCE: -3° 13′ 44.184″

      expect(coordinates.longitude.str(:dms)).to eq "+133° 10′ 1.834″"
      # Result from the book: 133° 10′ 02″
      # Result from IMCCE: 133° 10′ 0.157″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.166
    it "returns the apparent ecliptic coordinates for 2015-01-01" do
      moon = described_class.new(time: Time.new(2015, 1, 1, 22, 0, 0, "-05:00"))

      coordinates = moon.apparent_ecliptic_coordinates

      expect(coordinates.latitude.str(:dms)).to eq "-3° 50′ 46.0007″"
      # Result from the book: -3° 57′ 22.5179″ (-3.956255°)
      # Result from IMCCE: -3° 50′ 55.417″

      expect(coordinates.longitude.str(:dms)).to eq "+65° 21′ 5.9223″"
      # Result from the book: +65° 3′ 35.3304″ (65.059814°)
      # Result from IMCCE: +65° 21′ 3.629″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent ecliptic coordinates for 2000-08-09" do
      moon = described_class.new(time: Time.new(2000, 8, 9, 12, 0, 0, "-05:00"))

      coordinates = moon.apparent_ecliptic_coordinates

      expect(coordinates.latitude.str(:dms)).to eq "+3° 11′ 22.0683″"
      # Result from the book: +3° 2′ 40.2″ (3.0445°)
      # Result from IMCCE: +3° 11′ 25.819″

      expect(coordinates.longitude.str(:dms)).to eq "+257° 17′ 32.7597″"
      # Result from the book: +257° 13′ 11.784″ (257.21994°)
      # Result from IMCCE: +257° 17′ 32.387″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent ecliptic coordinates for 2010-05-15" do
      moon = described_class.new(time: Time.new(2010, 5, 15, 14, 30, 0, "-04:00"))

      coordinates = moon.apparent_ecliptic_coordinates

      expect(coordinates.latitude.str(:dms)).to eq "+2° 16′ 12.4064″"
      # Result from the book: +2° 25′ 1.7975″ (2.417166°)
      # Result from IMCCE: +2° 16′ 15.434″

      expect(coordinates.longitude.str(:dms)).to eq "+76° 35′ 31.0243″"
      # Result from the book: +76° 24′ 58.8924″ (76.416359°)
      # Result from IMCCE: +76° 35′ 32.198″
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 65 - Calculating the Moon’s position, p.165
    it "returns the apparent ecliptic coordinates for 2003-09-01" do
      moon = described_class.new(time: Time.utc(2003, 9, 1))

      coordinates = moon.apparent_ecliptic_coordinates

      expect(coordinates.latitude.str(:dms)).to eq "+1° 37′ 12.7837″"
      # Result from the book: +1° 42′ 57.8664″ (1.716074°)
      # Result from IMCCE: +1° 37′ 9.680″

      expect(coordinates.longitude.str(:dms)).to eq "+214° 46′ 16.0171″"
      # Result from the book: +214° 52′ 3.0107″ (214.867503°)
      # Result from IMCCE: +214° 46′ 16.888″
    end
  end

  describe "#distance" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 47 - Position of the Moon, p.342
    it "returns the distance for 1992-04-12" do
      # Example gives 1992-04-12 00:00:00 TT (and not UTC)
      time = Time.utc(1992, 4, 12, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      moon = described_class.new(time: time)

      distance = moon.distance

      expect(distance).to eq 368409707
      # Result from the book: 368409700 (36849.7 km)
      # Result from IMCCE: 368439405 (0.002462865305 AU)
    end
  end

  describe "#apparent_geocentric_equatorial_coordinates" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 47 - Position of the Moon, p.342
    it "returns the apparent geocentric equatorial coordinates for 1992-04-12" do
      # Example gives 1992-04-12 00:00:00 TT (and not UTC)
      time = Time.utc(1992, 4, 12, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      moon = described_class.new(time: time)

      coordinates = moon.apparent_geocentric_equatorial_coordinates

      expect(coordinates.right_ascension.str(:hms)).to eq "8h 58m 45.21s"
      # Result from the book: 8h 58m 45.1s
      # Result from IMCCE: 8h 58m 45.0996s

      expect(coordinates.declination.str(:dms)).to eq "+13° 46′ 6.1119″"
      # Result from the book: +13° 46′ 6″
      # Result from IMCCE: +13° 46′ 6.424″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.166
    it "returns the apparent geocentric equatorial coordinates for 2015-01-01" do
      moon = described_class.new(time: Time.new(2015, 1, 1, 22, 0, 0, "-05:00"))

      coordinates = moon.apparent_geocentric_equatorial_coordinates

      expect(coordinates.right_ascension.str(:hms)).to eq "4h 16m 35.1442s"
      # Result from the book: 4h 15m 27.7703s (4.257714h)
      # Result from IMCCE: 4h 16m 35.0164s

      expect(coordinates.declination.str(:dms)).to eq "+17° 24′ 14.7897″"
      # Result from the book: +17° 14′ 55.9679″ (17.24888°)
      # Result from IMCCE: +17° 24′ 13.492″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent geocentric equatorial coordinates for 2000-08-09" do
      moon = described_class.new(time: Time.new(2000, 8, 9, 12, 0, 0, "-05:00"))

      coordinates = moon.apparent_geocentric_equatorial_coordinates

      expect(coordinates.right_ascension.str(:hms)).to eq "17h 6m 3.1276s"
      # Result from the book: 17h 5m 41.2872s (17.094802h)
      # Result from IMCCE: 17h 6m 3.1064s

      expect(coordinates.declination.str(:dms)).to eq "-19° 39′ 20.8685″"
      # Result from the book: -19° 47′ 39.9372″ (-19.794427°)
      # Result from IMCCE: -19° 39′ 20.54″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent geocentric equatorial coordinates for 2010-05-15" do
      moon = described_class.new(time: Time.new(2010, 5, 15, 14, 30, 0, "-04:00"))

      coordinates = moon.apparent_geocentric_equatorial_coordinates

      expect(coordinates.right_ascension.str(:hms)).to eq "5h 0m 44.3733s"
      # Result from the book: 4h 59m 54.1103s (4.998364h)
      # Result from IMCCE: 5h 0m 44.454s

      expect(coordinates.declination.str(:dms)).to eq "+25° 1′ 18.2266″"
      # Result from the book: +25° 9′ 2.6999″ (25.150750°)
      # Result from IMCCE: +25° 1′ 19.227″
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 65 - Calculating the Moon’s position, p.165
    it "returns the apparent geocentric equatorial coordinates for 2003-09-01" do
      moon = described_class.new(time: Time.utc(2003, 9, 1))

      coordinates = moon.apparent_geocentric_equatorial_coordinates

      expect(coordinates.right_ascension.str(:hms)).to eq "14h 12m 12.2352s"
      # Result from the book: 14h 12m 42s
      # Result from IMCCE: 14h 12m 12.2872s

      expect(coordinates.declination.str(:dms)).to eq "-11° 35′ 7.9466″"
      # Result from the book: -11° 31′ 38″
      # Result from IMCCE: -11° 35′ 7.994″
    end
  end

  # TODO: moon.distance is given, check what value should be given to get the
  # most accurate results:
  # - distance between the observer and the Moon center
  # - distance between the Earth and the Moon centers

  it "returns the apparent ecliptic coordinates for 2015-01-01" do
    time = Time.utc(2015, 1, 2)
    observer = Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(42),
      longitude: Astronoby::Angle.zero
    )
    moon = described_class.new(time: time)
    apparent_geocentric_equatorial_coordinates =
      moon.apparent_geocentric_equatorial_coordinates

    apparent_topocentric_equatorial_coordinates =
      Astronoby::GeocentricParallax.for_equatorial_coordinates(
        latitude: observer.latitude,
        longitude: observer.longitude,
        elevation: observer.elevation,
        time: time,
        coordinates: apparent_geocentric_equatorial_coordinates,
        distance: moon.distance
      )

    horizontal_coordinates =
      apparent_topocentric_equatorial_coordinates.to_horizontal(
        observer: observer,
        time: time
      )

    expect(horizontal_coordinates.azimuth.str(:dms)).to eq "+245° 7′ 32.2346″"
    # Result from IMCCE: +245° 7′ 30.36″

    expect(horizontal_coordinates.altitude.str(:dms)).to eq "+48° 1′ 21.8373″"
    # Result from IMCCE: +48° 1′ 21″
  end
end