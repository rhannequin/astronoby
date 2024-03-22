# frozen_string_literal: true

RSpec.describe Astronoby::Sun do
  describe "#ecliptic_coordinates" do
    it "returns ecliptic coordinates" do
      epoch = Astronoby::Epoch::DEFAULT_EPOCH

      coordinates = described_class.new(epoch: epoch).ecliptic_coordinates

      expect(coordinates).to be_a(Astronoby::Coordinates::Ecliptic)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes the coordinates for a given epoch" do
      time = Time.new(2015, 2, 5, 12, 0, 0, "-05:00")
      epoch = Astronoby::Epoch.from_time(time)

      ecliptic_coordinates = described_class.new(epoch: epoch).ecliptic_coordinates

      expect(ecliptic_coordinates.longitude.degrees.to_f).to(
        eq(316.5726713406949)
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes the coordinates for a given epoch" do
      time = Time.new(2000, 8, 9, 12, 0, 0, "-04:00")
      epoch = Astronoby::Epoch.from_time(time)

      ecliptic_coordinates = described_class.new(epoch: epoch).ecliptic_coordinates

      expect(ecliptic_coordinates.longitude.degrees.to_f).to(
        eq(137.36484079770798)
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes the coordinates for a given epoch" do
      time = Time.new(2015, 5, 6, 14, 30, 0, "-04:00")
      epoch = Astronoby::Epoch.from_time(time)

      ecliptic_coordinates = described_class.new(epoch: epoch).ecliptic_coordinates

      expect(ecliptic_coordinates.longitude.degrees.to_f).to(
        eq(45.92185191445673)
      )
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 47 - Calculating orbits more precisely
    it "computes the coordinates for a given epoch" do
      time = Time.utc(1988, 7, 27, 0, 0, 0)
      epoch = Astronoby::Epoch.from_time(time)

      ecliptic_coordinates = described_class.new(epoch: epoch).ecliptic_coordinates
      equatorial_coordinates = ecliptic_coordinates.to_equatorial(epoch: epoch)

      expect(equatorial_coordinates.right_ascension.str(:hms)).to(
        eq("8h 26m 3.6131s")
      )
      expect(equatorial_coordinates.declination.str(:dms)).to(
        eq("+19° 12′ 43.1836″")
      )
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 22 - Nutation and the Obliquity of the Ecliptic
    it "computes the coordinates for a given epoch" do
      time = Time.utc(1992, 10, 13, 0, 0, 0)
      epoch = Astronoby::Epoch.from_time(time)

      ecliptic_coordinates = described_class.new(epoch: epoch).ecliptic_coordinates
      equatorial_coordinates = ecliptic_coordinates.to_equatorial(epoch: epoch)

      expect(equatorial_coordinates.right_ascension.str(:hms)).to(
        eq("13h 13m 31.4636s")
      )
      expect(equatorial_coordinates.declination.str(:dms)).to(
        eq("-7° 47′ 6.9653″")
      )
    end
  end

  describe "#horizontal_coordinates" do
    it "returns horizontal coordinates" do
      epoch = Astronoby::Epoch::DEFAULT_EPOCH

      coordinates = described_class
        .new(epoch: epoch)
        .horizontal_coordinates(
          latitude: Astronoby::Angle.as_degrees(-20),
          longitude: Astronoby::Angle.as_degrees(-30)
        )

      expect(coordinates).to be_a(Astronoby::Coordinates::Horizontal)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes the horizontal coordinates for the epoch" do
      time = Time.new(2015, 2, 5, 12, 0, 0, "-05:00")
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      horizontal_coordinates = sun.horizontal_coordinates(
        latitude: Astronoby::Angle.as_degrees(38),
        longitude: Astronoby::Angle.as_degrees(-78)
      )

      expect(horizontal_coordinates.altitude.str(:dms)).to(
        eq("+35° 47′ 12.6437″")
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+172° 17′ 2.7301″")
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes the coordinates for a given epoch" do
      time = Time.new(2000, 8, 9, 12, 0, 0, "-05:00")
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      horizontal_coordinates = sun.horizontal_coordinates(
        latitude: Astronoby::Angle.as_degrees(30),
        longitude: Astronoby::Angle.as_degrees(-95)
      )

      expect(horizontal_coordinates.altitude.str(:dms)).to(
        eq("+65° 41′ 50.1342″")
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+121° 32′ 44.7251″")
      )
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes the coordinates for a given epoch" do
      time = Time.new(2015, 5, 6, 14, 30, 0, "-04:00")
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      horizontal_coordinates = sun.horizontal_coordinates(
        latitude: Astronoby::Angle.as_degrees(-20),
        longitude: Astronoby::Angle.as_degrees(-30)
      )

      expect(horizontal_coordinates.altitude.str(:dms)).to(
        eq("+13° 34′ 17.4237″")
      )
      expect(horizontal_coordinates.azimuth.str(:dms)).to(
        eq("+293° 37′ 12.5231″")
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
    #  Chapter: 48 - Calculating the Sun's distance and angular size
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(1988, 7, 27)
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      expect(sun.earth_distance.round).to eq 151_920_130_151
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2015, 2, 15)
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      expect(sun.earth_distance.round).to eq 147_745_409_916
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2015, 8, 9)
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      expect(sun.earth_distance.round).to eq 151_683_526_945
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2010, 5, 6)
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      expect(sun.earth_distance.round).to eq 150_902_254_024
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
    #  Chapter: 48 - Calculating the Sun's distance and angular size
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(1988, 7, 27)
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      expect(sun.angular_size.str(:dms)).to eq "+0° 31′ 29.9308″"
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2015, 2, 15)
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      expect(sun.angular_size.str(:dms)).to eq "+0° 32′ 23.333″"
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2015, 8, 9)
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      expect(sun.angular_size.str(:dms)).to eq "+0° 31′ 32.8788″"
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "computes and return the Earth-Sun distance for a given epoch" do
      time = Time.utc(2010, 5, 6)
      epoch = Astronoby::Epoch.from_time(time)
      sun = described_class.new(epoch: epoch)

      expect(sun.angular_size.str(:dms)).to eq "+0° 31′ 42.6789″"
    end
  end

  describe "#rising_time" do
    it "returns a time" do
      date = Date.new
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      setting_time = sun.rising_time(observer: observer)

      expect(setting_time).to be_a(Time)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "returns the Sun's rising time on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(38),
        longitude: Astronoby::Angle.as_degrees(-78)
      )
      sun = described_class.new(epoch: epoch)

      rising_time = sun.rising_time(observer: observer)

      expect(rising_time).to eq Time.utc(2015, 2, 5, 12, 13, 27)
      # Time from Celestial Calculations: 2015-02-05T12:18:00
      # Time from IMCCE: 2015-02-05T12:14:12
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 49 - Sunrise and sunset
    it "returns the Sun's rising time on 1986-03-10" do
      date = Date.new(1986, 3, 10)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(42.37),
        longitude: Astronoby::Angle.as_degrees(-71.05)
      )
      sun = described_class.new(epoch: epoch)

      rising_time = sun.rising_time(observer: observer)

      expect(rising_time).to eq Time.utc(1986, 3, 10, 11, 5, 43)
      # Time from Practical Astronomy: 1986-03-10T11:06:00
      # Time from IMCCE: 1986-03-10T11:06:22
    end

    it "returns the Sun's rising time on 1991-03-14" do
      date = Date.new(1991, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(48.8566),
        longitude: Astronoby::Angle.as_degrees(2.3522)
      )
      sun = described_class.new(epoch: epoch)

      rising_time = sun.rising_time(observer: observer)

      expect(rising_time).to eq Time.utc(1991, 3, 14, 6, 8, 16)
      # Time from IMCCE: 1991-03-14T06:08:45
    end
  end

  describe "#rising_azimuth" do
    it "returns an Angle" do
      date = Date.new
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      rising_azimuth = sun.rising_azimuth(observer: observer)

      expect(rising_azimuth).to be_a(Astronoby::Angle)
    end

    it "returns the Sun's rising azimuth on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(38),
        longitude: Astronoby::Angle.as_degrees(-78)
      )
      sun = described_class.new(epoch: epoch)

      rising_azimuth = sun.rising_azimuth(observer: observer)

      expect(rising_azimuth&.str(:dms)).to eq "+109° 41′ 24.0917″"
      # Time from IMCCE: +109° 53′
    end

    it "returns the Sun's rising azimuth on 1986-03-10" do
      date = Date.new(1986, 3, 10)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(42.37),
        longitude: Astronoby::Angle.as_degrees(-71.05)
      )
      sun = described_class.new(epoch: epoch)

      rising_azimuth = sun.rising_azimuth(observer: observer)

      expect(rising_azimuth&.str(:dms)).to eq "+94° 59′ 15.7852″"
      # Time from IMCCE: +95° 02′
    end

    it "returns the Sun's rising azimuth on 1991-03-14" do
      date = Date.new(1991, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(48.8566),
        longitude: Astronoby::Angle.as_degrees(2.3522)
      )
      sun = described_class.new(epoch: epoch)

      rising_azimuth = sun.rising_azimuth(observer: observer)

      expect(rising_azimuth&.str(:dms)).to eq "+93° 26′ 26.8564″"
      # Time from IMCCE: +93° 26′
    end
  end

  describe "#setting_time" do
    it "returns a time" do
      date = Date.new
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      setting_time = sun.setting_time(observer: observer)

      expect(setting_time).to be_a(Time)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "returns the Sun's setting time on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(38),
        longitude: Astronoby::Angle.as_degrees(-78)
      )
      sun = described_class.new(epoch: epoch)

      setting_time = sun.setting_time(observer: observer)

      expect(setting_time).to eq Time.utc(2015, 2, 5, 22, 35, 14)
      # Time from Celestial Calculations: 2015-02-05T22:31:00
      # Time from IMCCE: 2015-02-05T22:49:16
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 49 - Sunrise and sunset
    it "returns the Sun's setting time on 1986-03-10" do
      date = Date.new(1986, 3, 10)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(42.37),
        longitude: Astronoby::Angle.as_degrees(-71.05)
      )
      sun = described_class.new(epoch: epoch)

      setting_time = sun.setting_time(observer: observer)

      expect(setting_time).to eq Time.utc(1986, 3, 10, 22, 40, 55)
      # Time from Practical Astronomy: 1986-03-10T22:43:00
      # Time from IMCCE: 1986-03-10T22:43:22
    end

    it "returns the Sun's setting time on 1991-03-14" do
      date = Date.new(1991, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(48.8566),
        longitude: Astronoby::Angle.as_degrees(2.3522)
      )
      sun = described_class.new(epoch: epoch)

      setting_time = sun.setting_time(observer: observer)

      expect(setting_time).to eq Time.utc(1991, 3, 14, 17, 50, 37)
      # Time from IMCCE: 1991-03-14T17:52:00
    end
  end

  describe "#setting_azimuth" do
    it "returns an Angle" do
      date = Date.new
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      sun = described_class.new(epoch: epoch)

      setting_azimuth = sun.setting_azimuth(observer: observer)

      expect(setting_azimuth).to be_a(Astronoby::Angle)
    end

    it "returns the Sun's setting azimuth on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(38),
        longitude: Astronoby::Angle.as_degrees(-78)
      )
      sun = described_class.new(epoch: epoch)

      setting_azimuth = sun.setting_azimuth(observer: observer)

      expect(setting_azimuth&.str(:dms)).to eq "+250° 18′ 35.9082″"
      # Time from IMCCE: +250° 18′
    end

    it "returns the Sun's setting azimuth on 1986-03-10" do
      date = Date.new(1986, 3, 10)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(42.37),
        longitude: Astronoby::Angle.as_degrees(-71.05)
      )
      sun = described_class.new(epoch: epoch)

      setting_azimuth = sun.setting_azimuth(observer: observer)

      expect(setting_azimuth&.str(:dms)).to eq "+265° 0′ 44.2147″"
      # Time from IMCCE: +265° 14′
    end

    it "returns the Sun's setting azimuth on 1991-03-14" do
      date = Date.new(1991, 3, 14)
      epoch = Astronoby::Epoch.from_time(date)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.as_degrees(48.8566),
        longitude: Astronoby::Angle.as_degrees(2.3522)
      )
      sun = described_class.new(epoch: epoch)

      setting_azimuth = sun.setting_azimuth(observer: observer)

      expect(setting_azimuth&.str(:dms)).to eq "+266° 33′ 33.1435″"
      # Time from IMCCE: +266° 52′
    end
  end
end
