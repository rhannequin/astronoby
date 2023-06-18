# frozen_string_literal: true

RSpec.describe Astronoby::Sun do
  describe "#coordinates" do
    it "returns ecliptic coordinates" do
      epoch = Astronoby::Epoch::DEFAULT_EPOCH

      coordinates = described_class.new(epoch: epoch).coordinates

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

      ecliptic_coordinates = described_class.new(epoch: epoch).coordinates
      equatorial_coordinates = ecliptic_coordinates.to_equatorial(epoch: epoch)
      horizontal_coordinates = equatorial_coordinates.to_horizontal(
        time: time,
        latitude: Astronoby::Angle.as_degrees(38),
        longitude: Astronoby::Angle.as_degrees(-78)
      )

      expect(ecliptic_coordinates.longitude.to_degrees.value.to_f).to(
        eq(316.5726713406947)
      )
      expect(horizontal_coordinates.altitude.to_dms.format).to(
        eq("+35° 47′ 12.6437″")
      )
      expect(horizontal_coordinates.azimuth.to_dms.format).to(
        eq("+172° 17′ 2.7299″")
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

      ecliptic_coordinates = described_class.new(epoch: epoch).coordinates
      equatorial_coordinates = ecliptic_coordinates.to_equatorial(epoch: epoch)
      horizontal_coordinates = equatorial_coordinates.to_horizontal(
        time: time,
        latitude: Astronoby::Angle.as_degrees(30),
        longitude: Astronoby::Angle.as_degrees(-95)
      )

      expect(ecliptic_coordinates.longitude.to_degrees.value.to_f).to(
        eq(137.36484079770828)
      )
      expect(equatorial_coordinates.right_ascension.to_hours.value).to(
        eq(9.32079647116818)
      )
      expect(equatorial_coordinates.declination.to_degrees.value).to(
        eq(15.63002864434695)
      )
      # TODO: very far from the expected value
      expect(horizontal_coordinates.altitude.to_dms.format).to(
        eq("+53° 44′ 26.5428″")
      )
      expect(horizontal_coordinates.azimuth.to_dms.format).to(
        eq("+105° 8′ 12.9488″")
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

      ecliptic_coordinates = described_class.new(epoch: epoch).coordinates
      equatorial_coordinates = ecliptic_coordinates.to_equatorial(epoch: epoch)
      horizontal_coordinates = equatorial_coordinates.to_horizontal(
        time: time,
        latitude: Astronoby::Angle.as_degrees(-20),
        longitude: Astronoby::Angle.as_degrees(-30)
      )

      expect(ecliptic_coordinates.longitude.to_degrees.value).to(
        eq(45.92185191446102)
      )
      expect(equatorial_coordinates.right_ascension.to_hours.value).to(
        eq(2.89706471944391)
      )
      expect(equatorial_coordinates.declination.to_degrees.value).to(
        eq(16.60289828746774)
      )
      expect(horizontal_coordinates.altitude.to_dms.format).to(
        eq("+13° 34′ 17.4238″")
      )
      expect(horizontal_coordinates.azimuth.to_dms.format).to(
        eq("+293° 37′ 12.5232″")
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

      ecliptic_coordinates = described_class.new(epoch: epoch).coordinates
      equatorial_coordinates = ecliptic_coordinates.to_equatorial(epoch: epoch)

      expect(equatorial_coordinates.right_ascension.to_hours.to_hms.format).to(
        eq("8h 26m 3.6131s")
      )
      expect(equatorial_coordinates.declination.to_degrees.to_dms.format).to(
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

      ecliptic_coordinates = described_class.new(epoch: epoch).coordinates
      equatorial_coordinates = ecliptic_coordinates.to_equatorial(epoch: epoch)

      expect(equatorial_coordinates.right_ascension.to_hours.to_hms.format).to(
        eq("13h 13m 31.4636s")
      )
      expect(equatorial_coordinates.declination.to_degrees.to_dms.format).to(
        eq("-7° 47′ 6.9653″")
      )
    end
  end
end
