# frozen_string_literal: true

RSpec.describe Astronoby::RiseTransitSet do
  describe "#rising_time_v2" do
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

      rising_time, transit_time, setting_time = described_class.new.compute(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_previous_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_next_day
      )

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

    it "returns the Sun's rising, transit and setting times on 2015-02-05" do
      date = Date.new(2015, 2, 5)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(38),
        longitude: Astronoby::Angle.from_degrees(-78)
      )
      time_of_the_previous_day = Time.utc(2015, 2, 4)
      epoch_of_the_previous_day = Astronoby::Epoch.from_time(time_of_the_previous_day)
      sun_of_the_previous_day = Astronoby::Sun.new(epoch: epoch_of_the_previous_day)
      coordinates_of_the_previous_day = sun_of_the_previous_day
        .apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: epoch_of_the_previous_day)

      time_of_the_day = date
      epoch_of_the_day = Astronoby::Epoch.from_time(time_of_the_day)
      sun_of_the_day = Astronoby::Sun.new(epoch: epoch_of_the_day)
      coordinates_of_the_day = sun_of_the_day
        .apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: epoch_of_the_day)

      time_of_the_next_day = Time.utc(2015, 2, 6)
      epoch_of_the_next_day = Astronoby::Epoch.from_time(time_of_the_next_day)
      sun_of_the_next_day = Astronoby::Sun.new(epoch: epoch_of_the_next_day)
      coordinates_of_the_next_day = sun_of_the_next_day
        .apparent_ecliptic_coordinates
        .to_apparent_equatorial(epoch: epoch_of_the_next_day)

      rising_time, transit_time, setting_time = described_class.new.compute(
        observer: observer,
        date: date,
        coordinates_of_the_previous_day: coordinates_of_the_previous_day,
        coordinates_of_the_day: coordinates_of_the_day,
        coordinates_of_the_next_day: coordinates_of_the_next_day,
        standard_altitude: Astronoby::Angle.from_dms(0, -50, 0)
      )

      expect(rising_time).to eq Time.utc(2015, 2, 5, 12, 13, 0)
      # Time from IMCCE: 2015-02-05T12:12:14

      expect(transit_time).to eq Time.utc(2015, 2, 5, 17, 25, 59)
      # Time from IMCCE: 2015-02-05T17:25:58

      expect(setting_time).to eq Time.utc(2015, 2, 5, 22, 39, 26)
      # Time from IMCCE: 2015-02-05T22:38:11
    end
  end
end
