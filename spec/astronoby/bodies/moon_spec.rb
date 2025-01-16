# frozen_string_literal: true

RSpec.describe Astronoby::Moon do
  describe "::monthly_phase_events" do
    it "returns an array" do
      moon_phases = described_class.monthly_phase_events(year: 2024, month: 1)

      expect(moon_phases).to be_an(Array)
    end

    it "returns correct phase events for 2025-08" do
      moon_phases = described_class.monthly_phase_events(year: 2025, month: 8)
      days_of_moon_phases = moon_phases.map { _1.time.day }

      # Phases in August 2025 from IMCCE (days): 1, 9, 16, 23, 31
      expect(days_of_moon_phases).to eq([1, 9, 16, 23, 31])
    end
  end

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

      expect(distance.meters).to eq 368409707
      # Result from the book: 368409700 (36849.7 km)
      # Result from IMCCE: 368439405 (0.002462865305 AU)
    end
  end

  describe "#apparent_equatorial_coordinates" do
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

      coordinates = moon.apparent_equatorial_coordinates

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

      coordinates = moon.apparent_equatorial_coordinates

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

      coordinates = moon.apparent_equatorial_coordinates

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

      coordinates = moon.apparent_equatorial_coordinates

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

      coordinates = moon.apparent_equatorial_coordinates

      expect(coordinates.right_ascension.str(:hms)).to eq "14h 12m 12.2352s"
      # Result from the book: 14h 12m 42s
      # Result from IMCCE: 14h 12m 12.2872s

      expect(coordinates.declination.str(:dms)).to eq "-11° 35′ 7.9466″"
      # Result from the book: -11° 31′ 38″
      # Result from IMCCE: -11° 35′ 7.994″
    end
  end

  describe "#horizontal_coordinates" do
    it "returns the apparent ecliptic coordinates for 2015-01-01" do
      time = Time.utc(2015, 1, 2)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(42),
        longitude: Astronoby::Angle.zero
      )
      moon = described_class.new(time: time)

      horizontal_coordinates =
        moon.horizontal_coordinates(observer: observer)

      expect(horizontal_coordinates.azimuth.str(:dms)).to eq "+245° 7′ 32.2346″"
      # Result from IMCCE: +245° 7′ 30.36″

      expect(horizontal_coordinates.altitude.str(:dms)).to eq "+48° 1′ 21.8373″"
      # Result from IMCCE: +48° 1′ 21″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the horizon coordinates for 2000-08-09" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(30),
        longitude: Astronoby::Angle.from_degrees(-95)
      )
      moon = described_class.new(time: Time.new(2000, 8, 9, 12, 0, 0, "-05:00"))

      coordinates = moon.horizontal_coordinates(observer: observer)

      expect(coordinates.altitude.str(:dms)).to eq "-51° 19′ 13.9407″"
      # Result from the book: -50° 44′
      # Result from IMCCE: -51° 19′ 22.44″

      expect(coordinates.azimuth.str(:dms)).to eq "+84° 40′ 12.0274″"
      # Result from the book: +84° 56′
      # Result from IMCCE: +84° 40′ 5.52″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent ecliptic coordinates for 2010-05-15" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(-20),
        longitude: Astronoby::Angle.from_degrees(-30)
      )
      moon = described_class.new(time: Time.new(2010, 5, 15, 14, 30, 0, "-04:00"))

      coordinates = moon.horizontal_coordinates(observer: observer)

      expect(coordinates.altitude.str(:dms)).to eq "+25° 52′ 49.8989″"
      # Result from the book: 26° 32′
      # Result from IMCCE: 25° 52′ 40.8″

      expect(coordinates.azimuth.str(:dms)).to eq "+313° 26′ 5.3866″"
      # Result from the book: +313° 24′
      # Result from IMCCE: +313° 25′ 58.08″
    end
  end

  describe "#phase_angle" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 48 - Illuminated Fraction of the Moon's Disk, p.346
    it "returns the phase angle for 1992-04-12" do
      # Example gives 1992-04-12 00:00:00 TT (and not UTC)
      time = Time.utc(1992, 4, 12, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      moon = described_class.new(time: time)

      phase_angle = moon.phase_angle

      expect(phase_angle.degrees.round(4)).to eq 69.0742
      # Result from the book: 69.0756°
      # Result from IMCCE: 69.07611798°
    end
  end

  describe "#illuminated_fraction" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 48 - Illuminated Fraction of the Moon's Disk, p.346
    it "returns the illuminated fraction for 1992-04-12" do
      # Example gives 1992-04-12 00:00:00 TT (and not UTC)
      time = Time.utc(1992, 4, 12, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      moon = described_class.new(time: time)

      illuminated_fraction = moon.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.6786
      # Result from the book: 0.6786
      # Result from IMCCE: 0.679
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.180
    it "returns the illuminated fraction for 2015-01-01" do
      moon = described_class.new(time: Time.utc(2015, 1, 1))

      illuminated_fraction = moon.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.8243
      # Result from the book: 0.82
      # Result from IMCCE: 0.824
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent ecliptic coordinates for 2005-08-09" do
      moon = described_class.new(time: Time.utc(2005, 8, 9))

      illuminated_fraction = moon.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.1315
      # Result from the book: 0.13
      # Result from IMCCE: 0.132
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent ecliptic coordinates for 2005-05-06" do
      moon = described_class.new(time: Time.utc(2005, 5, 6, 14, 30))

      illuminated_fraction = moon.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.0347
      # Result from the book: 0.06
      # Result from IMCCE: 0.035
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 67 - The phases of the Moon, p.171
    it "returns the apparent ecliptic coordinates for 2003-09-01" do
      # Example gives 2003-09-01 00:00:00 TT (and not UTC)
      time = Time.utc(2003, 9, 1, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      moon = described_class.new(time: time)

      illuminated_fraction = moon.illuminated_fraction

      expect(illuminated_fraction.round(4)).to eq 0.2257
      # Result from the book: 0.225
      # Result from IMCCE: 0.226
    end
  end

  describe "#current_phase_fraction" do
    it "returns the mean elongation's fraction" do
      moon = described_class.new(time: Time.new)
      allow(moon).to receive(:mean_elongation)
        .and_return(Astronoby::Angle.from_degrees(90))

      phase_fraction = moon.current_phase_fraction

      expect(phase_fraction).to eq 0.25
    end

    it "returns the mean elongation's fraction for 2024-01-01" do
      moon = described_class.new(time: Time.utc(2024, 1, 1))

      phase_fraction = moon.current_phase_fraction

      expect(phase_fraction.round(2)).to eq 0.66
    end
  end

  describe "#observation_events" do
    describe "#rising_time" do
      it "returns the moonrise time on 1991-03-14" do
        time = Time.utc(1991, 3, 14)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time).to eq Time.utc(1991, 3, 14, 5, 6, 50)
        # Time from IMCCE: 1991-03-14T05:08:08
      end

      it "returns the moonrise time on 2024-01-01" do
        time = Time.utc(2024, 1, 1)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(0),
          longitude: Astronoby::Angle.from_degrees(149)
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time).to eq Time.utc(2024, 1, 1, 12, 20, 32)
        # Time from IMCCE: 2024-01-01T18:31:21
      end

      it "returns the moonrise time on 2024-01-03" do
        date = Date.new(2024, 1, 3)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(89),
          longitude: Astronoby::Angle.from_degrees(16)
        )
        moon = described_class.new(time: date)
        observation_events = moon.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time).to be_nil
        # Time from IMCCE: nil
      end

      it "returns the moonrise time on 2024-05-31" do
        time = Time.utc(2024, 5, 31)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.zero,
          longitude: Astronoby::Angle.zero
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time).to eq Time.utc(2024, 5, 31, 0, 29, 48)
        # Time from IMCCE: 2024-05-31T00:30:47
      end

      it "returns moonrise time on 2024-08-23" do
        time = Time.utc(2024, 8, 23)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(68),
          longitude: Astronoby::Angle.from_degrees(153)
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time).to eq Time.utc(2024, 8, 23, 9, 20, 51)
        # Time from the IMCCE: 2024-08-23T09:23:09
      end

      it "returns moonrise time on 2024-11-10" do
        time = Time.utc(2024, 11, 10)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(41.02054),
          longitude: Astronoby::Angle.from_degrees(-72.15608)
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time).to eq Time.utc(2024, 11, 10, 18, 49, 44)
      end

      it "returns moonrise time on 2024-11-12" do
        time = Time.utc(2024, 11, 12)
        utc_offset = "-06:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(41.87),
          longitude: Astronoby::Angle.from_degrees(-87.62),
          utc_offset: utc_offset
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time.getlocal(utc_offset))
          .to eq Time.new(2024, 11, 12, 14, 39, 54, utc_offset)
        # Time from the IMCCE: 2024-11-12T14:41:07-06:00
        # Time from the Stellarium: 14:40
      end

      it "returns moonrise time on 2024-11-13" do
        time = Time.utc(2024, 11, 13)
        utc_offset = "-06:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(41.87),
          longitude: Astronoby::Angle.from_degrees(-87.62),
          utc_offset: utc_offset
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        rising_time = observation_events.rising_time

        expect(rising_time.getlocal(utc_offset))
          .to eq Time.new(2024, 11, 13, 15, 4, 19, utc_offset)
        # Time from the IMCCE: 2024-11-13T15:05:34-06:00
        # Time from the Stellarium: 15:04
      end
    end

    describe "#rising_azimuth" do
      it "returns the moonrise azimuth on 2024-05-31" do
        time = Time.utc(2024, 5, 31)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.zero,
          longitude: Astronoby::Angle.zero
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        rising_azimuth = observation_events.rising_azimuth

        expect(rising_azimuth.str(:dms)).to eq "+98° 47′ 39.3589″"
        # Time from IMCCE: +98° 37′ 50″
      end
    end

    describe "#transit_time" do
      it "returns the Moon's transit time on 2024-05-31" do
        time = Time.utc(2024, 5, 31)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.zero,
          longitude: Astronoby::Angle.zero
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        transit_time = observation_events.transit_time

        expect(transit_time).to eq Time.utc(2024, 5, 31, 6, 41, 19)
        # Time from IMCCE: 2024-05-31T06:41:19
      end

      it "returns the Moon's transit time on 1991-03-14" do
        time = Time.utc(1991, 3, 14)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        transit_time = observation_events.transit_time

        expect(transit_time).to eq Time.utc(1991, 3, 14, 10, 29, 24)
        # Time from IMCCE: 1991-03-14T10:29:23
      end
    end

    describe "#transit_altitude" do
      it "returns the moonrise azimuth on 2024-05-31" do
        time = Time.utc(2024, 5, 31)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.zero,
          longitude: Astronoby::Angle.zero
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        transit_altitude = observation_events.transit_altitude

        expect(transit_altitude.str(:dms)).to eq "+83° 1′ 50.327″"
        # Time from IMCCE: +82° 55′ 41″
      end
    end

    describe "#setting_time" do
      it "returns the moonset time on 2024-05-31" do
        time = Time.utc(2024, 5, 31)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.zero,
          longitude: Astronoby::Angle.zero
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        setting_time = observation_events.setting_time

        expect(setting_time).to eq Time.utc(2024, 5, 31, 12, 52, 46)
        # Time from IMCCE: 2024-05-31T12:51:47
      end

      it "returns the moonset time on 1991-03-14" do
        time = Time.utc(1991, 3, 14)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        setting_time = observation_events.setting_time

        expect(setting_time).to eq Time.utc(1991, 3, 14, 16, 4, 0)
        # Time from IMCCE: 1991-03-14T16:02:38
      end
    end

    describe "#setting_azimuth" do
      it "returns the moonset azimuth on 2024-05-31" do
        time = Time.utc(2024, 5, 31)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.zero,
          longitude: Astronoby::Angle.zero
        )
        moon = described_class.new(time: time)
        observation_events = moon.observation_events(observer: observer)

        setting_azimuth = observation_events.setting_azimuth

        expect(setting_azimuth.str(:dms)).to eq "+264° 34′ 51.1561″"
        # Time from IMCCE: +264° 45′ 18″
      end
    end
  end
end
