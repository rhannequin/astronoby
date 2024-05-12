# frozen_string_literal: true

RSpec.describe Astronoby::Sun do
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
        eq("8h 26m 3.6131s")
        # Result from the book: 8h 26m 4s
      )
      expect(equatorial_coordinates.declination.str(:dms)).to(
        eq("+19° 12′ 43.1836″")
        # Result from the book: 19° 12′ 43″
      )
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
        eq("+35° 47′ 15.717″")
        # Result from the book: 35° 47′ 0.1″
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+172° 17′ 22.7257″")
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
        eq("+65° 42′ 21.6058″")
        # Result from the book: 65° 43′
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+121° 33′ 22.4256″")
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
        eq("+13° 34′ 7.6913″")
        # Result from the book: 13° 34′
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+293° 36′ 54.0812″")
        # Result from the book: 293° 37′
      )
    end
  end

  describe "#earth_distance" do
    it "returns a number in meters" do
      time = Time.new

      sun = described_class.new(time: time)

      expect(sun.earth_distance).to be_a Numeric
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 48 - Calculating the Sun's distance and angular size, p.110
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(1988, 7, 27)

      sun = described_class.new(time: time)

      expect(sun.earth_distance.round).to eq 151_920_130_151
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

      expect(sun.earth_distance.round).to eq 147_745_409_916
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

      expect(sun.earth_distance.round).to eq 151_683_526_945
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

      expect(sun.earth_distance.round).to eq 150_902_254_024
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
        it "returns the sunrise time for the right date" do
          time = Time.new(1991, 3, 14, 0, 0, 0, "-10:00")
          observer = Astronoby::Observer.new(
            latitude: Astronoby::Angle.from_degrees(-17.6509),
            longitude: Astronoby::Angle.from_degrees(-149.4260)
          )
          sun = described_class.new(time: time)
          observation_events = sun.observation_events(observer: observer)

          rising_time = observation_events.rising_time

          expect(rising_time).to eq Time.utc(1991, 3, 14, 16, 0, 16)
          # Time from IMCCE: 1991-03-14T16:01:12
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
      it "returns the sunset time for the right date" do
        time = Time.new(1991, 3, 14, 6, 0, 0, "+12:00")
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(-36.8509),
          longitude: Astronoby::Angle.from_degrees(174.7645)
        )
        sun = described_class.new(time: time)
        observation_events = sun.observation_events(observer: observer)

        setting_time = observation_events.setting_time

        expect(setting_time).to eq Time.utc(1991, 3, 14, 6, 42, 40)
        # Time from IMCCE: 1991-03-14T06:41:30
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

        expect(rising_azimuth.str(:dms)).to eq "+109° 46′ 43.145″"
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

        expect(rising_azimuth.str(:dms)).to eq "+95° 1′ 7.3542″"
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

        expect(rising_azimuth.str(:dms)).to eq "+93° 33′ 34.0996″"
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

        expect(setting_azimuth.str(:dms)).to eq "+250° 23′ 33.614″"
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

        expect(setting_azimuth.str(:dms)).to eq "+265° 14′ 19.3963″"
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

        expect(setting_azimuth.str(:dms)).to eq "+266° 44′ 2.3191″"
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

      expect(altitude&.str(:dms)).to eq "+36° 8′ 15.7638″"
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

      expect(altitude&.str(:dms)).to eq "+43° 35′ 59.2014″"
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

      expect(altitude&.str(:dms)).to eq "+38° 31′ 32.4262″"
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
