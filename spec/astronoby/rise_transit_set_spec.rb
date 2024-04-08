# frozen_string_literal: true

RSpec.describe Astronoby::RiseTransitSet do
  describe "#times" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 15 - Rising, Transit, and Setting, p.103
    it "returns Venus' rising, transit and setting times on 1988-03-20" do
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

      rising_time, transit_time, setting_time = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_previous_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_next_day
      ).times

      expect(rising_time).to eq Time.utc(1988, 3, 20, 12, 25, 26)
      # Time from the book: 1988-03-20T12:25:00
      # Time from IMCCE: 1988-03-20T12:25:11

      expect(transit_time).to eq Time.utc(1988, 3, 20, 19, 40, 30)
      # Time from the book: 1988-03-20T19:41:00
      # Time from IMCCE: 1988-03-20T19:40:30

      expect(setting_time).to eq Time.utc(1988, 3, 20, 2, 54, 40)
      # Time from the book: 1988-03-20T02:55:00
      # Time from IMCCE: 1988-03-20T02:54:55
    end

    # TODO: check if conversion to epoch works
    it "returns Betelgeuse's rising, transit and setting times on 2016-01-21" do
      date = Date.new(2016, 1, 21)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      coordinates_of_the_day = Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(5, 56, 2.43),
        declination: Astronoby::Angle.from_dms(7, 24, 22)
      )

      rising_time, transit_time, setting_time = described_class.new(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_day
      ).times

      expect(rising_time).to eq Time.utc(2016, 1, 21, 20, 39, 12)
      # Time from SkySafari: 2016-01-21T20:39:09

      expect(transit_time).to eq Time.utc(2016, 1, 21, 3, 8, 18)
      # Time from SkySafari: 2016-01-21T03:08:18

      expect(setting_time).to eq Time.utc(2016, 1, 21, 9, 33, 29)
      # Time from SkySafari: 2016-01-21T20:33:31
    end
  end
end
