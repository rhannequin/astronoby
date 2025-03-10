# frozen_string_literal: true

RSpec.describe Astronoby::CelestialEventCalculator do
  include TestEphemHelper

  describe "#calculate_rising_time" do
    it "computes all values correctly" do
      ephem = test_ephem
      date = Date.new(2025, 3, 14)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      calculator = Astronoby::CelestialEventCalculator.new(
        observer: observer,
        target_body: Astronoby::Sun,
        ephem: ephem
      )

      events = calculator.calculate_events(date)

      aggregate_failures do
        expect(events.rising_time)
          .to eq Time.utc(2025, 3, 14, 6, 5, 50)
        # USNO:        2025-03-14T06:05:00+00:00
        # Stellarium:  2025-03-14T06:06:00+00:00
        # Skyfield:    2025-03-14T06:05:50+00:00
        # Timeanddate: 2025-03-14T06:05:00+00:00

        expect(events.transit_time)
          .to eq Time.utc(2025, 3, 14, 12, 9, 6)
        # Stellarium:  2025-03-14T12:09:00+00:00
        # Skyfield:    2025-03-14T12:09:06+00:00
        # Timeanddate: 2025-03-14T12:09:00+00:00

        expect(events.setting_time)
          .to eq Time.utc(2025, 3, 14, 18, 12, 21)
        # USNO:        2025-03-14T18:12:00+00:00
        # Stellarium:  2025-03-14T18:12:00+00:00
        # Skyfield:    2025-03-14T18:12:21+00:00
        # Timeanddate: 2025-03-14T18:12:00+00:00

        expect(events.rising_azimuth.str(:dms))
          .to eq "+92° 25′ 10.0331″"
        # Skyfield:    +92° 25′ 9.9″
        # Timeanddate: 92°

        expect(events.transit_altitude.str(:dms))
          .to eq "+87° 40′ 48.8399″"
        # Skyfield:    +87° 40′ 48.9″
        # Timeanddate: 180°

        expect(events.setting_azimuth.str(:dms))
          .to eq "+267° 46′ 46.7417″"
        # Skyfield:    +267° 46′ 46.8″
        # Timeanddate: 268°
      end
    end

    context "when the body does not rise" do
      it "returns nil for rising and setting" do
        ephem = test_ephem
        date = Date.new(2025, 6, 21)
        utc_offset = "+12:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(-67.56793423209638),
          longitude: Astronoby::Angle.from_degrees(-68.12415901809868),
          utc_offset: utc_offset
        )
        calculator = described_class.new(
          observer: observer,
          target_body: Astronoby::Sun,
          ephem: ephem
        )

        events = calculator.calculate_events(date)

        aggregate_failures do
          expect(events.rising_time).to be_nil

          expect(events.transit_time.localtime(utc_offset))
            .to eq Time.new(2025, 6, 21, 4, 34, 11, utc_offset)
          # Stellarium:  2025-06-21T04:34:00+12:00
          # Skyfield:    2025-06-21T04:34:10+12:00
          # Timeanddate: 2025-06-21T04:32:00+12:00

          expect(events.setting_time).to be_nil

          expect(events.rising_azimuth).to be_nil

          expect(events.transit_altitude.str(:dms))
            .to eq "-1° 0′ 28.9844″"
          # Skyfield:    -1° 0′ 29.0″
          # Timeanddate: 0°

          expect(events.setting_azimuth).to be_nil
        end
      end
    end

    context "when the body doesn't rise for one day because of its motion" do
      it "computes correct values on the day before" do
        ephem = test_ephem
        date = Date.new(2025, 12, 10)
        utc_offset = "-07:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(39.74),
          longitude: Astronoby::Angle.from_degrees(-104.99),
          elevation: Astronoby::Distance.zero,
          utc_offset: utc_offset
        )
        calculator = described_class.new(
          observer: observer,
          target_body: Astronoby::Moon,
          ephem: ephem
        )

        events = calculator.calculate_events(date)

        aggregate_failures do
          expect(events.rising_time.localtime(utc_offset))
            .to eq Time.new(2025, 12, 10, 23, 11, 16, utc_offset)
          # USNO:        2025-12-10T23:11:00-07:00
          # Stellarium:  2025-12-10T23:11:00-07:00
          # Skyfield:    2025-12-10T23:11:15-07:00
          # Timeanddate: 2025-12-10T23:11:00-07:00

          expect(events.transit_time.localtime(utc_offset))
            .to eq Time.new(2025, 12, 10, 5, 1, 32, utc_offset)
          # Stellarium:  2025-12-10T05:02:00-07:00
          # Skyfield:    2025-12-10T05:01:33-07:00
          # Timeanddate: 2025-12-10T05:01:00-07:00

          expect(events.setting_time.localtime(utc_offset))
            .to eq Time.new(2025, 12, 10, 11, 46, 10, utc_offset)
          # USNO:        2025-12-10T11:46:00-07:00
          # Stellarium:  2025-12-10T11:46:00-07:00
          # Skyfield:    2025-12-10T11:46:10-07:00
          # Timeanddate: 2025-12-10T11:46:00-07:00

          expect(events.rising_azimuth.str(:dms))
            .to eq "+80° 59′ 13.6311″"
          # Skyfield:    +80° 59′ 13.1″
          # Timeanddate: 81°

          expect(events.transit_altitude.str(:dms))
            .to eq "+61° 13′ 31.1915″"
          # Skyfield:    +61° 13′ 29.9″
          # Timeanddate: 61.2°

          expect(events.setting_azimuth.str(:dms))
            .to eq "+282° 40′ 22.8518″"
          # Skyfield:    +282° 40′ 23.8″
          # Timeanddate: 283°
        end
      end

      it "correctly set the rising time and azimuth to nil" do
        ephem = test_ephem
        date = Date.new(2025, 12, 11)
        utc_offset = "-07:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(39.74),
          longitude: Astronoby::Angle.from_degrees(-104.99),
          elevation: Astronoby::Distance.zero,
          utc_offset: utc_offset
        )
        calculator = described_class.new(
          observer: observer,
          target_body: Astronoby::Moon,
          ephem: ephem
        )

        events = calculator.calculate_events(date)

        aggregate_failures do
          expect(events.rising_time).to be_nil

          expect(events.transit_time.localtime(utc_offset))
            .to eq Time.new(2025, 12, 11, 5, 45, 24, utc_offset)
          # Stellarium:  2025-12-11T05:45:00-07:00
          # Skyfield:    2025-12-11T05:45:24-07:00
          # Timeanddate: 2025-12-11T05:45:00-07:00

          expect(events.setting_time.localtime(utc_offset))
            .to eq Time.new(2025, 12, 11, 12, 8, 22, utc_offset)
          # USNO:        2025-12-11T12:08:00-07:00
          # Stellarium:  2025-12-11T12:08:00-07:00
          # Skyfield:    2025-12-11T12:08:21-07:00
          # Timeanddate: 2025-12-11T12:08:00-07:00

          expect(events.rising_azimuth).to be_nil

          expect(events.transit_altitude.str(:dms))
            .to eq "+55° 5′ 53.8296″"
          # Skyfield:    +55° 5′ 51.8″
          # Timeanddate: 55.1°

          expect(events.setting_azimuth.str(:dms))
            .to eq "+274° 50′ 50.6497″"
          # Skyfield:    +274° 50′ 44.9″
          # Timeanddate: 275°
        end
      end

      it "computes correct values on the day after" do
        ephem = test_ephem
        date = Date.new(2025, 12, 12)
        utc_offset = "-07:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(39.74),
          longitude: Astronoby::Angle.from_degrees(-104.99),
          elevation: Astronoby::Distance.zero,
          utc_offset: utc_offset
        )
        calculator = described_class.new(
          observer: observer,
          target_body: Astronoby::Moon,
          ephem: ephem
        )

        events = calculator.calculate_events(date)

        aggregate_failures do
          expect(events.rising_time.localtime(utc_offset))
            .to eq Time.new(2025, 12, 12, 0, 14, 27, utc_offset)
          # USNO:        2025-12-12T00:14:00-07:00
          # Stellarium:  2025-12-12T00:14:00-07:00
          # Skyfield:    2025-12-12T00:14:26-07:00
          # Timeanddate: 2025-12-12T00:14:00-07:00

          expect(events.transit_time.localtime(utc_offset))
            .to eq Time.new(2025, 12, 12, 6, 26, 51, utc_offset)
          # Stellarium:  2025-12-12T06:27:00-07:00
          # Skyfield:    2025-12-12T06:26:51-07:00
          # Timeanddate: 2025-12-12T06:26:00-07:00

          expect(events.setting_time.localtime(utc_offset))
            .to eq Time.new(2025, 12, 12, 12, 29, 1, utc_offset)
          # USNO:        2025-12-12T12:29:00-07:00
          # Stellarium:  2025-12-12T12:29:00-07:00
          # Skyfield:    2025-12-12T12:29:01-07:00
          # Timeanddate: 2025-12-12T12:29:00-07:00

          expect(events.rising_azimuth.str(:dms))
            .to eq "+89° 1′ 52.5722″"
          # Skyfield:    +89° 1′ 57.1″
          # Timeanddate: 89°

          expect(events.transit_altitude.str(:dms))
            .to eq "+48° 56′ 46.8685″"
          # Skyfield:    +48° 56′ 45.0″
          # Timeanddate: 49°

          expect(events.setting_azimuth.str(:dms))
            .to eq "+267° 5′ 4.5545″"
          # Skyfield:    +267° 5′ 5.4″
          # Timeanddate: 267°
        end
      end
    end

    context "when the observer is high above sea level" do
      it "takes the observer's elevation into account" do
        ephem = test_ephem
        date = Date.new(2025, 8, 7)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(35.88071676915352),
          longitude: Astronoby::Angle.from_degrees(76.51522879779951),
          elevation: Astronoby::Distance.from_meters(8611)
        )
        calculator = described_class.new(
          observer: observer,
          target_body: Astronoby::Venus,
          ephem: ephem
        )

        events = calculator.calculate_events(date)

        aggregate_failures do
          expect(events.rising_time)
            .to eq Time.utc(2025, 8, 7, 21, 15, 3)
          # Stellarium:  2025-08-07T21:15:02+00:00
          # Skyfield:    2025-08-07T21:15:03+00:00

          expect(events.transit_time)
            .to eq Time.utc(2025, 8, 7, 4, 25, 19)
          # Stellarium:  2025-08-07T04:25:00+00:00
          # Skyfield:    2025-08-07T04:25:19+00:00

          expect(events.setting_time)
            .to eq Time.utc(2025, 8, 7, 11, 36, 44)
          # Stellarium:  2025-08-07T11:37:00+00:00
          # Skyfield:    2025-08-07T11:36:43+00:00

          expect(events.rising_azimuth.str(:dms))
            .to eq "+62° 1′ 39.2946″"
          # Skyfield: +62° 1′ 36.2″

          expect(events.transit_altitude.str(:dms))
            .to eq "+76° 6′ 44.3832″"
          # Skyfield: +76° 6′ 44.4″

          expect(events.setting_azimuth.str(:dms))
            .to eq "+297° 59′ 9.7066″"
          # Skyfield: +297° 59′ 7.3″
        end
      end
    end
  end
end
