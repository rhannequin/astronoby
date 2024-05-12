# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Equatorial do
  describe "#compute_hour_angle" do
    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 24 - Converting between right ascension and hour angle
    it "converts right ascension to hour angle" do
      longitude = Astronoby::Angle.from_degrees(-64)
      time = Time.new(1980, 4, 22, 14, 36, 51.67, "-04:00")
      right_ascension = Astronoby::Angle.from_hms(18, 32, 21)
      declination = Astronoby::Angle.zero

      coordinates = described_class.new(
        right_ascension: right_ascension,
        declination: declination,
        epoch: Astronoby::Epoch.from_time(time)
      )
      hour_angle = coordinates.compute_hour_angle(
        time: time,
        longitude: longitude
      )

      expect(hour_angle.str(:hms)).to eq "9h 52m 23.6554s"
    end
  end

  describe "#to_horizontal" do
    it "returns a new instance of Astronoby::Coordinates::Horizontal" do
      time = Time.new
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(50),
        longitude: Astronoby::Angle.zero
      )

      expect(
        described_class.new(
          right_ascension: Astronoby::Angle.from_dms(23, 59, 59),
          declination: Astronoby::Angle.from_dms(89, 59, 59)
        ).to_horizontal(time: time, observer: observer)
      ).to be_an_instance_of(Astronoby::Coordinates::Horizontal)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    context "with real life arguments (book example)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 30, 0, "-05:00")
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.from_hms(17, 43, 54),
          declination: Astronoby::Angle.from_dms(-22, 10, 0)
        ).to_horizontal(time: time, observer: observer)

        expect(horizontal_coordinates.altitude.str(:dms)).to(
          eq("-73° 27′ 19.1557″")
        )
        expect(horizontal_coordinates.azimuth.str(:dms)).to(
          eq("+341° 33′ 21.587″")
        )
      end
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    context "with real life arguments (book example)" do
      it "computes properly" do
        time = Time.new(2016, 1, 21, 21, 45, 0, "-05:00")
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(38),
          longitude: Astronoby::Angle.from_degrees(-78)
        )

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.from_hms(5, 54, 58),
          declination: Astronoby::Angle.from_dms(7, 29, 54)
        ).to_horizontal(time: time, observer: observer)

        expect(horizontal_coordinates.altitude.str(:dms)).to(
          eq("+59° 13′ 0.3617″")
        )
        expect(horizontal_coordinates.azimuth.str(:dms)).to(
          eq("+171° 5′ 0.4263″")
        )
      end
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 5 - Stars in the Nighttime Sky
    context "with real life arguments (book example)" do
      it "computes properly" do
        time = Time.new(2015, 12, 1, 9, 0, 0, "-08:00")
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(45),
          longitude: Astronoby::Angle.from_degrees(-100)
        )

        horizontal_coordinates = described_class.new(
          right_ascension: Astronoby::Angle.from_hms(6, 0, 0),
          declination: Astronoby::Angle.from_degrees(-60)
        ).to_horizontal(time: time, observer: observer)

        expect(horizontal_coordinates.altitude.str(:dms)).to(
          eq("-59° 41′ 58.4833″")
        )
        expect(horizontal_coordinates.azimuth.str(:dms)).to(
          eq("+224° 15′ 26.7345″")
        )
      end
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 25 - Equatorial to horizon coordinate conversion
    context "with real life arguments (book example)" do
      it "computes properly" do
        time = Time.new(2015, 12, 1, 9, 0, 0, "-08:00")
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(52),
          longitude: Astronoby::Angle.zero
        )

        horizontal_coordinates = described_class.new(
          declination: Astronoby::Angle.from_dms(23, 13, 10),
          right_ascension: nil,
          hour_angle: Astronoby::Angle.from_hms(5, 51, 44)
        ).to_horizontal(time: time, observer: observer)

        expect(horizontal_coordinates.altitude.str(:dms)).to(
          eq("+19° 20′ 3.6428″")
        )
        expect(horizontal_coordinates.azimuth.str(:dms)).to(
          eq("+283° 16′ 15.6981″")
        )
      end
    end
  end

  describe "#to_ecliptic" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 4 - Orbits and Coordinate Systems
    context "with real life arguments (book example)" do
      it "computes properly" do
        right_ascension = Astronoby::Angle.from_hms(11, 10, 13)
        declination = Astronoby::Angle.from_dms(30, 5, 40)
        epoch = Astronoby::Epoch::J2000

        ecliptic_coordinates = described_class.new(
          right_ascension: right_ascension,
          declination: declination
        ).to_ecliptic(epoch: epoch)

        expect(ecliptic_coordinates.latitude.str(:dms)).to(
          eq("+22° 41′ 53.8752″")
        )
        expect(ecliptic_coordinates.longitude.str(:dms)).to(
          eq("+156° 19′ 8.9427″")
        )
      end
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 13 - Transformation of coordinates
    context "with real life arguments (book example)" do
      it "computes properly" do
        right_ascension = Astronoby::Angle.from_hms(7, 45, 18.946)
        declination = Astronoby::Angle.from_dms(28, 1, 34.26)
        epoch = Astronoby::Epoch::J2000

        ecliptic_coordinates = described_class.new(
          right_ascension: right_ascension,
          declination: declination
        ).to_ecliptic(epoch: epoch)

        expect(ecliptic_coordinates.latitude.str(:dms)).to(
          eq("+6° 41′ 3.0103″")
        )
        expect(ecliptic_coordinates.longitude.str(:dms)).to(
          eq("+113° 12′ 56.2651″")
        )
      end
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 28 - Equatorial to ecliptic coordinate conversion
    context "with real life arguments (book example)" do
      it "computes properly" do
        right_ascension = Astronoby::Angle.from_hms(9, 34, 53.32)
        declination = Astronoby::Angle.from_dms(19, 32, 6.01)
        epoch = Astronoby::Epoch.from_time(Time.utc(2009, 7, 6, 0, 0, 0))

        ecliptic_coordinates = described_class.new(
          right_ascension: right_ascension,
          declination: declination
        ).to_ecliptic(epoch: epoch)

        expect(ecliptic_coordinates.latitude.str(:dms)).to(
          eq("+4° 52′ 30.993″")
        )
        expect(ecliptic_coordinates.longitude.str(:dms)).to(
          eq("+139° 41′ 9.9812″")
        )
      end
    end
  end

  describe "#to_epoch" do
    it "returns a new instance of Astronoby::Coordinates::Equatorial" do
      coordinates = described_class.new(
        right_ascension: Astronoby::Angle.from_hms(12, 0, 0),
        declination: Astronoby::Angle.from_degrees(180),
        epoch: Astronoby::Epoch::J2000
      )

      new_coordinates = coordinates.to_epoch(Astronoby::Epoch::J1950)

      expect(new_coordinates).to(
        be_an_instance_of(Astronoby::Coordinates::Equatorial)
      )
      expect(new_coordinates.epoch).to eq(Astronoby::Epoch::J1950)
    end
  end
end
