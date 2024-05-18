# frozen_string_literal: true

RSpec.describe Astronoby::Events::ObservationEvents do
  describe "#rising_time" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 15 - Rising, Transit, and Setting, p.103
    it "returns Venus rising time on 1988-03-20" do
      date = Date.new(1988, 3, 20)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(42, 20, 0),
        longitude: Astronoby::Angle.from_dms(-71, 5, 0)
      )
      coordinates_of_the_previous_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(2, 42, 43.25),
        declination: Astronoby::Angle.from_dms(18, 2, 51.4)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(2, 46, 55.51),
        declination: Astronoby::Angle.from_dms(18, 26, 27.3)
      )
      coordinates_of_the_next_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(2, 51, 7.69),
        declination: Astronoby::Angle.from_dms(18, 49, 38.7)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_previous_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_next_day
      )

      rising_time = events.rising_time

      expect(rising_time).to eq Time.utc(1988, 3, 20, 12, 25, 26)
      # Time from the book: 1988-03-20T12:25:00
      # Time from IMCCE: 1988-03-20T12:25:11
    end

    it "returns Betelgeuse rising time on 2016-01-21" do
      date = Date.new(2016, 1, 21)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(5, 56, 2.43),
        declination: Astronoby::Angle.from_dms(7, 24, 22)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day
      )

      rising_time = events.rising_time

      expect(rising_time).to eq Time.utc(2016, 1, 21, 20, 39, 12)
      # Time from SkySafari: 2016-01-21T20:39:09
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky, p.124
    it "returns an object's rising time on 2015-06-06" do
      offset = -4
      date = Date.new(2015, 6, 6)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38.25),
        longitude: Astronoby::Angle.from_degrees(-78.3)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Horizontal.new(
        azimuth: Astronoby::Angle.from_degrees(90),
        altitude: Astronoby::Angle.from_degrees(45),
        observer: observer
      ).to_equatorial(time: Time.new(2015, 6, 6, 21, 0, 0, offset))
      # Cancel refraction correction to match the book that ignores it
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day,
        additional_altitude: described_class::STANDARD_ALTITUDE
      )

      rising_time = events.rising_time

      expect(rising_time.getlocal(offset))
        .to eq Time.new(2015, 6, 6, 16, 57, 48, offset)
      # Time from the book: 2015-06-06 16:57:49 -000004
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 33 - Rising and setting, p.69
    it "returns an object's rising time on 2015-06-06" do
      date = Date.new(2010, 8, 24)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(30),
        longitude: Astronoby::Angle.from_degrees(64)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(23, 39, 20),
        declination: Astronoby::Angle.from_dms(21, 42, 0)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day
      )

      rising_time = events.rising_time

      expect(rising_time).to eq Time.utc(2010, 8, 24, 14, 16, 18)
      # Time from the book: 2010-08-24T14:16
    end

    context "when the body does not rise" do
      it "returns nil" do
        date = Date.new(2016, 1, 21)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )
        coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(6, 0, 0),
          declination: Astronoby::Angle.from_dms(-60, 0, 0)
        )
        events = described_class.new(
          observer: observer,
          date: date,
          coordinates_of_the_previous_day: coordinates_of_the_day,
          coordinates_of_the_day: coordinates_of_the_day,
          coordinates_of_the_next_day: coordinates_of_the_day
        )

        rising_time = events.rising_time

        expect(rising_time).to be_nil
      end
    end
  end

  describe "#transit_time" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 15 - Rising, Transit, and Setting, p.103
    it "returns Venus transit time on 1988-03-20" do
      date = Date.new(1988, 3, 20)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(42, 20, 0),
        longitude: Astronoby::Angle.from_dms(-71, 5, 0)
      )
      coordinates_of_the_previous_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(2, 42, 43.25),
        declination: Astronoby::Angle.from_dms(18, 2, 51.4)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(2, 46, 55.51),
        declination: Astronoby::Angle.from_dms(18, 26, 27.3)
      )
      coordinates_of_the_next_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(2, 51, 7.69),
        declination: Astronoby::Angle.from_dms(18, 49, 38.7)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_previous_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_next_day
      )

      transit_time = events.transit_time

      expect(transit_time).to eq Time.utc(1988, 3, 20, 19, 40, 31)
      # Time from the book: 1988-03-20T19:41:00
      # Time from IMCCE: 1988-03-20T19:40:30
    end

    it "returns Betelgeuse transit time on 2016-01-21" do
      date = Date.new(2016, 1, 21)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(5, 56, 2.43),
        declination: Astronoby::Angle.from_dms(7, 24, 22)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day
      )

      transit_time = events.transit_time

      expect(transit_time).to eq Time.utc(2016, 1, 21, 3, 8, 18)
      # Time from SkySafari: 2016-01-21T03:08:18
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky, p.124
    it "returns an object's transit time on 2015-06-06" do
      offset = -4
      date = Date.new(2015, 6, 6)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38.25),
        longitude: Astronoby::Angle.from_degrees(-78.3)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Horizontal.new(
        azimuth: Astronoby::Angle.from_degrees(90),
        altitude: Astronoby::Angle.from_degrees(45),
        observer: observer
      ).to_equatorial(time: Time.new(2015, 6, 6, 21, 0, 0, offset))
      # Cancel refraction correction to match the book that ignores it
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day,
        additional_altitude: described_class::STANDARD_ALTITUDE
      )

      transit_time = events.transit_time

      expect(transit_time.getlocal(offset))
        .to eq Time.new(2015, 6, 6, 0, 30, 48, offset)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 33 - Rising and setting, p.69
    it "returns an object's transit time on 2015-06-06" do
      date = Date.new(2010, 8, 24)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(30),
        longitude: Astronoby::Angle.from_degrees(64)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(23, 39, 20),
        declination: Astronoby::Angle.from_dms(21, 42, 0)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day
      )

      transit_time = events.transit_time

      expect(transit_time).to eq Time.utc(2010, 8, 24, 21, 11, 11)
    end

    context "when the body does not rise" do
      it "returns an object's upper transit time" do
        date = Date.new(2016, 1, 21)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )
        coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(6, 0, 0),
          declination: Astronoby::Angle.from_dms(-60, 0, 0)
        )
        events = described_class.new(
          observer: observer,
          date: date,
          coordinates_of_the_previous_day: coordinates_of_the_day,
          coordinates_of_the_day: coordinates_of_the_day,
          coordinates_of_the_next_day: coordinates_of_the_day
        )

        transit_time = events.transit_time

        expect(transit_time).to eq Time.utc(2016, 1, 21, 0, 8, 2)
      end
    end

    context "when the body is circumpolar" do
      it "returns an object's upper transit time" do
        date = Date.new(2016, 1, 21)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )
        coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(2, 52, 43),
          declination: Astronoby::Angle.from_dms(89, 20, 9)
        )
        events = described_class.new(
          observer: observer,
          date: date,
          coordinates_of_the_previous_day: coordinates_of_the_day,
          coordinates_of_the_day: coordinates_of_the_day,
          coordinates_of_the_next_day: coordinates_of_the_day
        )

        transit_time = events.transit_time

        expect(transit_time).to eq Time.utc(2016, 1, 21, 0, 0, 14)
        # Time from Stellarium: 2016-01-21T00:01:35
      end
    end
  end

  describe "#setting_time" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 15 - Rising, Transit, and Setting, p.103
    it "returns Venus setting time on 1988-03-20" do
      date = Date.new(1988, 3, 20)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(42, 20, 0),
        longitude: Astronoby::Angle.from_dms(-71, 5, 0)
      )

      coordinates_of_the_previous_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(2, 42, 43.25),
        declination: Astronoby::Angle.from_dms(18, 2, 51.4)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(2, 46, 55.51),
        declination: Astronoby::Angle.from_dms(18, 26, 27.3)
      )
      coordinates_of_the_next_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(2, 51, 7.69),
        declination: Astronoby::Angle.from_dms(18, 49, 38.7)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_previous_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_next_day
      )

      setting_time = events.setting_time

      expect(setting_time).to eq Time.utc(1988, 3, 20, 2, 54, 40)
      # Time from the book: 1988-03-20T02:55:00
      # Time from IMCCE: 1988-03-20T02:54:55
    end

    it "returns Betelgeuse setting time on 2016-01-21" do
      date = Date.new(2016, 1, 21)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(5, 56, 2.43),
        declination: Astronoby::Angle.from_dms(7, 24, 22)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day
      )

      setting_time = events.setting_time

      expect(setting_time).to eq Time.utc(2016, 1, 21, 9, 33, 29)
      # Time from SkySafari: 2016-01-21T20:33:31
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky, p.124
    it "returns an object's setting time on 2015-06-06" do
      offset = -4
      date = Date.new(2015, 6, 6)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38.25),
        longitude: Astronoby::Angle.from_degrees(-78.3)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Horizontal.new(
        azimuth: Astronoby::Angle.from_degrees(90),
        altitude: Astronoby::Angle.from_degrees(45),
        observer: observer
      ).to_equatorial(time: Time.new(2015, 6, 6, 21, 0, 0, offset))
      # Cancel refraction correction to match the book that ignores it
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day,
        additional_altitude: described_class::STANDARD_ALTITUDE
      )

      setting_time = events.setting_time

      expect(setting_time.getlocal(offset))
        .to eq Time.new(2015, 6, 6, 7, 59, 51, offset)
      # Time from the book: 2015-06-06 07:59:51 -000004
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 33 - Rising and setting, p.69
    it "returns an object's setting time on 2015-06-06" do
      date = Date.new(2010, 8, 24)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(30),
        longitude: Astronoby::Angle.from_degrees(64)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(23, 39, 20),
        declination: Astronoby::Angle.from_dms(21, 42, 0)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day
      )

      setting_time = events.setting_time

      expect(setting_time).to eq Time.utc(2010, 8, 24, 4, 10, 1)
      # Time from the book: 2010-08-24T04:10
    end

    context "when the body does not rise" do
      it "returns nil" do
        date = Date.new(2016, 1, 21)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )
        coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(6, 0, 0),
          declination: Astronoby::Angle.from_dms(-60, 0, 0)
        )
        events = described_class.new(
          observer: observer,
          date: date,
          coordinates_of_the_previous_day: coordinates_of_the_day,
          coordinates_of_the_day: coordinates_of_the_day,
          coordinates_of_the_next_day: coordinates_of_the_day
        )

        setting_time = events.setting_time

        expect(setting_time).to be_nil
      end
    end
  end

  describe "#rising_azimuth" do
    it "returns the body's rising azimuth on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      # Vega's J2015.1 coordinates from SkySafari
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 37, 27.06),
        declination: Astronoby::Angle.from_dms(38, 47, 59.4)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day
      )

      rising_azimuth = events.rising_azimuth

      expect(rising_azimuth.str(:dms)).to eq "+36° 22′ 48.9402″"
      # Azimuth from SkySafari: +36° 34′ 44.5″
    end
  end

  describe "#setting_azimuth" do
    it "returns the body's setting azimuth on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      # Vega's J2015.1 coordinates from SkySafari
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 37, 27.06),
        declination: Astronoby::Angle.from_dms(38, 47, 59.4)
      )
      events = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day
      )

      setting_azimuth = events.setting_azimuth

      expect(setting_azimuth.str(:dms)).to eq "+323° 37′ 11.0597″"
      # Azimuth from SkySafari: +323° 25′ 21.6″
    end
  end

  describe "#transit_altitude" do
    it "returns the body's altitude at transit on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      # Vega's J2015.1 coordinates from SkySafari
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 37, 27.06),
        declination: Astronoby::Angle.from_dms(38, 47, 59.4)
      )

      transit_altitude = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day
      ).transit_altitude

      expect(transit_altitude.str(:dms)).to eq "+89° 4′ 6.548″"
      # Azimuth from SkySafari: +89° 12′ 1.4″
    end

    context "when the body is circumpolar" do
      it "returns an object's upper transit azimuth" do
        date = Date.new(2016, 1, 21)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )
        coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(2, 52, 43),
          declination: Astronoby::Angle.from_dms(89, 20, 9)
        )
        events = described_class.new(
          observer: observer,
          date: date,
          coordinates_of_the_previous_day: coordinates_of_the_day,
          coordinates_of_the_day: coordinates_of_the_day,
          coordinates_of_the_next_day: coordinates_of_the_day
        )

        transit_altitude = events.transit_altitude

        expect(transit_altitude.str(:dms)).to eq "+38° 39′ 50.9999″"
        # Azimuth from Stellarium: +38° 41′ 5.4″
      end
    end
  end
end
