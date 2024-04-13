# frozen_string_literal: true

RSpec.describe Astronoby::Sun do
  describe "#true_ecliptic_coordinates" do
    it "returns ecliptic coordinates" do
      epoch = Astronoby::Epoch::DEFAULT_EPOCH

      coordinates = described_class.new(epoch: epoch).true_ecliptic_coordinates

      expect(coordinates).to be_a(Astronoby::Coordinates::Ecliptic)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p136
    it "computes the coordinates for 2015-02-05" do
      time = Time.new(2015, 2, 5, 12, 0, 0, "-05:00")
      epoch = Astronoby::Epoch.from_time(time)

      ecliptic_coordinates = described_class
        .new(epoch: epoch)
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
      epoch = Astronoby::Epoch.from_time(time)

      ecliptic_coordinates = described_class
        .new(epoch: epoch)
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
      epoch = Astronoby::Epoch.from_time(time)

      ecliptic_coordinates = described_class
        .new(epoch: epoch)
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
        .new(epoch: epoch)
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
      epoch = Astronoby::Epoch::DEFAULT_EPOCH

      coordinates = described_class
        .new(epoch: epoch)
        .horizontal_coordinates(
          latitude: Astronoby::Angle.from_degrees(-20),
          longitude: Astronoby::Angle.from_degrees(-30)
        )

      expect(coordinates).to be_a(Astronoby::Coordinates::Horizontal)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.137
    it "computes the horizontal coordinates for the epoch" do
      time = Time.new(2015, 2, 5, 12, 0, 0, "-05:00")
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      horizontal_coordinates = sun.horizontal_coordinates(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )

      expect(horizontal_coordinates.altitude.str(:dms)).to(
        eq("+35° 47′ 15.717″")
        # Result from the book: 35° 47′ 0.1″
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+172° 17′ 22.7259″")
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
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      horizontal_coordinates = sun.horizontal_coordinates(
        latitude: Astronoby::Angle.from_degrees(30),
        longitude: Astronoby::Angle.from_degrees(-95)
      )

      expect(horizontal_coordinates.altitude.str(:dms)).to(
        eq("+65° 42′ 21.6059″")
        # Result from the book: 65° 43′
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+121° 33′ 22.4259″")
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
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      horizontal_coordinates = sun.horizontal_coordinates(
        latitude: Astronoby::Angle.from_degrees(-20),
        longitude: Astronoby::Angle.from_degrees(-30)
      )

      expect(horizontal_coordinates.altitude.str(:dms)).to(
        eq("+13° 34′ 7.6911″")
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
      epoch = Astronoby::Epoch::DEFAULT_EPOCH
      sun = described_class.new(epoch: epoch)

      expect(sun.earth_distance).to be_a Numeric
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 48 - Calculating the Sun's distance and angular size, p.110
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(1988, 7, 27)
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

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
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

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
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

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
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      expect(sun.earth_distance.round).to eq 150_902_254_024
      # Result from the book: 1.509×10^8 km
    end
  end

  describe "#angular_size" do
    it "returns an Angle" do
      epoch = Astronoby::Epoch::DEFAULT_EPOCH
      sun = described_class.new(epoch: epoch)

      expect(sun.angular_size).to be_a Astronoby::Angle
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 48 - Calculating the Sun's distance and angular size, p.110
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(1988, 7, 27)
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

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
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

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
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

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
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      expect(sun.angular_size.str(:dms)).to eq "+0° 31′ 42.6789″"
      # Result from the book: 0° 32′″
    end
  end

  describe "#rise_transit_set_times" do
    it "returns an array of times" do
      date = Date.new(2024, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      times = sun.rise_transit_set_times(observer: observer)

      expect(times).to be_an Array
      times.each { expect(_1).to be_a Time }
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.139
    it "returns the rising, transit and setting times on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      sun = described_class.new(epoch: epoch)

      rising_time, transit_time, setting_time =
        sun.rise_transit_set_times(observer: observer)

      expect(rising_time).to eq Time.utc(2015, 2, 5, 12, 12, 59)
      # Time from Celestial Calculations: 2015-02-05T12:18:00
      # Time from SkySafari: 2015-02-05T12:12:57
      # Time from IMCCE: 2015-02-05T12:14:12

      expect(transit_time).to eq Time.utc(2015, 2, 5, 17, 25, 59)
      # Time from SkySafari: 2015-02-05T17:26:00
      # Time from IMCCE: 2015-02-05T17:25:58

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
    it "returns the rising, transit and setting times on 1986-03-10" do
      date = Date.new(1986, 3, 10)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(42.37),
        longitude: Astronoby::Angle.from_degrees(-71.05)
      )
      sun = described_class.new(epoch: epoch)

      rising_time, transit_time, setting_time =
        sun.rise_transit_set_times(observer: observer)

      expect(rising_time).to eq Time.utc(1986, 3, 10, 11, 5, 7)
      # Time from Practical Astronomy: 1986-03-10T11:06:00
      # Time from IMCCE: 1986-03-10T11:06:22

      expect(transit_time).to eq Time.utc(1986, 3, 10, 16, 54, 31)
      # Time from IMCCE: 1986-03-10T16:54:31

      expect(setting_time).to eq Time.utc(1986, 3, 10, 22, 44, 36)
      # Time from Practical Astronomy: 1986-03-10T22:43:00
      # Time from IMCCE: 1986-03-10T22:43:22
    end

    it "returns the rising, transit and setting times on 1991-03-14" do
      date = Date.new(1991, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )
      sun = described_class.new(epoch: epoch)

      rising_time, transit_time, setting_time =
        sun.rise_transit_set_times(observer: observer)

      expect(rising_time).to eq Time.utc(1991, 3, 14, 6, 7, 23)
      # Time from IMCCE: 1991-03-14T06:08:45

      expect(transit_time).to eq Time.utc(1991, 3, 14, 11, 59, 58)
      # Time from IMCCE: 1991-03-14T11:59:56

      expect(setting_time).to eq Time.utc(1991, 3, 14, 17, 53, 26)
      # Time from IMCCE: 1991-03-14T17:52:00
    end

    it "memoizes the result for the observer" do
      date = Date.new(2024, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      allow(Astronoby::Events::ObservationEvents).to receive(:new).and_call_original

      sun.rise_transit_set_times(observer: observer)
      sun.rise_transit_set_times(observer: observer)

      expect(Astronoby::Events::ObservationEvents).to have_received(:new).once
    end
  end

  describe "#rising_time" do
    it "delegates to #rise_transit_set_times" do
      date = Date.new(2024, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      expect(sun.rising_time(observer: observer))
        .to eq sun.rise_transit_set_times(observer: observer)[0]
    end
  end

  describe "#transit_time" do
    it "delegates to #rise_transit_set_times" do
      date = Date.new(2024, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      expect(sun.transit_time(observer: observer))
        .to eq sun.rise_transit_set_times(observer: observer)[1]
    end
  end

  describe "#setting_time" do
    it "delegates to #rise_transit_set_times" do
      date = Date.new(2024, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      expect(sun.setting_time(observer: observer))
        .to eq sun.rise_transit_set_times(observer: observer)[2]
    end
  end

  describe "#rise_set_azimuths" do
    it "returns an array of angles" do
      date = Date.new(2024, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      azimuths = sun.rise_set_azimuths(observer: observer)

      expect(azimuths).to be_an Array
      azimuths.each { expect(_1).to be_a Astronoby::Angle }
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.139
    it "returns the rising and setting azimuths on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      sun = described_class.new(epoch: epoch)

      rising_azimuth, setting_azimuth =
        sun.rise_set_azimuths(observer: observer)

      expect(rising_azimuth.str(:dms)).to eq "+109° 46′ 43.1427″"
      # Time from SkySafari: +109° 41′ 0.3″
      # Time from IMCCE: +109° 52′ 42″

      expect(setting_azimuth.str(:dms)).to eq "+250° 23′ 33.6177″"
      # Time from SkySafari: +250° 29′ 23.6″
      # Time from IMCCE: +250° 17′ 34″
    end

    it "returns the rising and setting azimuths on 1986-03-10" do
      date = Date.new(1986, 3, 10)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(42.37),
        longitude: Astronoby::Angle.from_degrees(-71.05)
      )
      sun = described_class.new(epoch: epoch)

      rising_azimuth, setting_azimuth =
        sun.rise_set_azimuths(observer: observer)

      expect(rising_azimuth.str(:dms)).to eq "+95° 1′ 6.1239″"
      # Time from IMCCE: +95° 01′ 55″

      expect(setting_azimuth.str(:dms)).to eq "+265° 14′ 20.6301″"
      # Time from IMCCE: +265° 13′ 32″
    end

    it "returns the rising and setting azimuths on 1991-03-14" do
      date = Date.new(1991, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )
      sun = described_class.new(epoch: epoch)

      rising_azimuth, setting_azimuth =
        sun.rise_set_azimuths(observer: observer)

      expect(rising_azimuth.str(:dms)).to eq "+93° 33′ 32.6479″"
      # Time from IMCCE: +93° 25′ 58″

      expect(setting_azimuth.str(:dms)).to eq "+266° 44′ 3.7751″"
      # Time from IMCCE: +266° 51′ 37″
    end
  end

  describe "#rising_azimuth" do
    it "delegates to #rise_set_azimuths" do
      date = Date.new(2024, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      expect(sun.rising_azimuth(observer: observer))
        .to eq sun.rise_set_azimuths(observer: observer)[0]
    end
  end

  describe "#setting_azimuth" do
    it "delegates to #rise_set_azimuths" do
      date = Date.new(2024, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      expect(sun.setting_azimuth(observer: observer))
        .to eq sun.rise_set_azimuths(observer: observer)[1]
    end
  end

  describe "#transit_altitude" do
    it "returns an Angle" do
      date = Date.new
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      altitude = sun.transit_altitude(observer: observer)

      expect(altitude).to be_a(Astronoby::Angle)
    end

    it "returns the Sun's altitude at transit on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      sun = described_class.new(epoch: epoch)

      altitude = sun.transit_altitude(observer: observer)

      expect(altitude&.str(:dms)).to eq "+36° 8′ 15.7669″"
      # Time from SkySafari: +36° 9′ 32.5″
      # Time from IMCCE: +36° 8′ 0.3″
    end

    it "returns the Sun's altitude at transit on 1986-03-10" do
      date = Date.new(1986, 3, 10)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(42.37),
        longitude: Astronoby::Angle.from_degrees(-71.05)
      )
      sun = described_class.new(epoch: epoch)

      altitude = sun.transit_altitude(observer: observer)

      expect(altitude&.str(:dms)).to eq "+43° 36′ 0.1105″"
      # Time from IMCCE: +45° 35′ 41″
    end

    it "returns the Sun's altitude at transit on 1991-03-14" do
      date = Date.new(1991, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )
      sun = described_class.new(epoch: epoch)

      altitude = sun.transit_altitude(observer: observer)

      expect(altitude&.str(:dms)).to eq "+38° 31′ 33.382″"
      # Time from IMCCE: +38° 31′ 20″
    end
  end

  describe "#morning_civil_twilight_time" do
    it "returns a time" do
      epoch = Astronoby::Epoch.from_time(Time.new)
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      expect(sun.morning_civil_twilight_time(observer: observer))
        .to be_a Time
    end

    it "returns when the morning civil twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )

      expect(sun.morning_civil_twilight_time(observer: observer))
        .to eq Time.utc(1979, 9, 7, 4, 44, 23)
      # Time from IMCCE: 04:46
    end

    it "returns when the morning civil twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )

      expect(sun.morning_civil_twilight_time(observer: observer))
        .to eq Time.utc(2024, 3, 14, 19, 25, 38)
      # Time from IMCCE: 19:29:29
    end
  end

  describe "#evening_civil_twilight_time" do
    it "returns a time" do
      epoch = Astronoby::Epoch.from_time(Time.new)
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      expect(sun.evening_civil_twilight_time(observer: observer))
        .to be_a Time
    end

    it "returns when the evening civil twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )

      expect(sun.evening_civil_twilight_time(observer: observer))
        .to eq Time.utc(1979, 9, 7, 19, 8, 22)
      # Time from IMCCE: 19:10
    end

    it "returns when the evening civil twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )

      expect(sun.evening_civil_twilight_time(observer: observer))
        .to eq Time.utc(2024, 3, 14, 8, 38, 28)
      # Time from IMCCE: 08:39:23
    end
  end

  describe "#morning_nautical_twilight_time" do
    it "returns a time" do
      epoch = Astronoby::Epoch.from_time(Time.new)
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      expect(sun.morning_nautical_twilight_time(observer: observer))
        .to be_a Time
    end

    it "returns when the morning nautical twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )

      expect(sun.morning_nautical_twilight_time(observer: observer))
        .to eq Time.utc(1979, 9, 7, 4, 2, 11)
      # Time from IMCCE: 04:03
    end

    it "returns when the morning nautical twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )

      expect(sun.morning_nautical_twilight_time(observer: observer))
        .to eq Time.utc(2024, 3, 14, 18, 56, 26)
      # Time from IMCCE: 19:00:13
    end
  end

  describe "#evening_nautical_twilight_time" do
    it "returns a time" do
      epoch = Astronoby::Epoch.from_time(Time.new)
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      expect(sun.evening_nautical_twilight_time(observer: observer))
        .to be_a Time
    end

    it "returns when the evening nautical twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )

      expect(sun.evening_nautical_twilight_time(observer: observer))
        .to eq Time.utc(1979, 9, 7, 19, 50, 34)
      # Time from IMCCE: 19:52
    end

    it "returns when the evening nautical twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )

      expect(sun.evening_nautical_twilight_time(observer: observer))
        .to eq Time.utc(2024, 3, 14, 9, 7, 39)
      # Time from IMCCE: 09:08:37
    end
  end

  describe "#morning_astronomical_twilight_time" do
    it "returns a time" do
      epoch = Astronoby::Epoch.from_time(Time.new)
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      expect(sun.morning_astronomical_twilight_time(observer: observer))
        .to be_a Time
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 50 - Twilight, p.114
    it "returns when the morning astronomical twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )

      expect(sun.morning_astronomical_twilight_time(observer: observer))
        .to eq Time.utc(1979, 9, 7, 3, 16, 13)
      # Time from Practical Astronomy: 03:12
      # Time from IMCCE: 03:17
    end

    it "returns when the morning astronomical twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )

      expect(sun.morning_astronomical_twilight_time(observer: observer))
        .to eq Time.utc(2024, 3, 14, 18, 26, 47)
      # Time from IMCCE: 18:30:31
    end

    context "when the twilight never ends" do
      it "returns nil" do
        epoch = Astronoby::Epoch.from_time(Time.utc(2024, 6, 20))
        sun = described_class.new(epoch: epoch)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(65),
          longitude: Astronoby::Angle.zero
        )

        expect(sun.morning_astronomical_twilight_time(observer: observer))
          .to be_nil
      end
    end
  end

  describe "#evening_astronomical_twilight_time" do
    it "returns a time" do
      epoch = Astronoby::Epoch.from_time(Time.new)
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      expect(sun.evening_astronomical_twilight_time(observer: observer))
        .to be_a Time
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 50 - Twilight, p.114
    it "returns when the evening astronomical twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )

      expect(sun.evening_astronomical_twilight_time(observer: observer))
        .to eq Time.utc(1979, 9, 7, 20, 36, 33)
      # Time from Practical Astronomy: 20:43
      # Time from IMCCE: 20:37
    end

    it "returns when the evening astronomical twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = described_class.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )

      expect(sun.evening_astronomical_twilight_time(observer: observer))
        .to eq Time.utc(2024, 3, 14, 9, 37, 18)
      # Time from IMCCE: 09:38:17
    end

    context "when the twilight never ends" do
      it "returns nil" do
        epoch = Astronoby::Epoch.from_time(Time.utc(2024, 6, 20))
        sun = described_class.new(epoch: epoch)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(65),
          longitude: Astronoby::Angle.zero
        )

        expect(sun.evening_astronomical_twilight_time(observer: observer))
          .to be_nil
      end
    end
  end

  describe "::equation_of_time" do
    it "returns an Integer" do
      date = Date.new

      equation_of_time = described_class.equation_of_time(date: date)

      expect(equation_of_time).to be_an Integer
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 51 - The equation of time, p.116
    it "returns the right value of 2010-07-27" do
      date = Date.new(2010, 7, 27)

      equation_of_time = described_class.equation_of_time(date: date)

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

      equation_of_time = described_class.equation_of_time(date: date)

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

      equation_of_time = described_class.equation_of_time(date: date)

      expect(equation_of_time).to eq(-332)
      # Value from Celestial Calculations: 337
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "returns the right value of 2010-05-06" do
      date = Date.new(2010, 5, 6)

      equation_of_time = described_class.equation_of_time(date: date)

      expect(equation_of_time).to eq(201)
      # Value from Celestial Calculations: 201
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun, p.150
    it "returns the right value of 2020-01-01" do
      date = Date.new(2020, 1, 1)

      equation_of_time = described_class.equation_of_time(date: date)

      expect(equation_of_time).to eq(-198)
      # Value from Celestial Calculations: 187
    end
  end
end
