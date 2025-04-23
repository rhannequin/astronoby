# frozen_string_literal: true

RSpec.describe Astronoby::RiseTransitSetCalculator do
  include TestEphemHelper

  # Sunrise, sunset, moonrise and moonset times are compared to the USNO and not
  # the IMCCE as Astronoby implements the USNO's definitions of rising and
  # setting horizon angles.
  # Transit times are compared to the IMCCE as it is not related to the
  # horizon angle, and the USNO does not provide them.

  describe "#events_on" do
    it "computes lists of rising, transit and setting times for a given date" do
      ephem = test_ephem
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      date = Date.new(2025, 3, 14)
      calculator = described_class.new(
        body: Astronoby::Sun,
        observer: observer,
        ephem: ephem
      )

      events = calculator.events_on(date)

      aggregate_failures do
        expect(events.rising_times.first)
          .to eq Time.utc(2025, 3, 14, 6, 5, 50)
        # USNO:        2025-03-14T06:05:00+00:00
        # Stellarium:  2025-03-14T06:06:00+00:00
        # Skyfield:    2025-03-14T06:05:50+00:00
        # Timeanddate: 2025-03-14T06:05:00+00:00

        expect(events.transit_times.first)
          .to eq Time.utc(2025, 3, 14, 12, 9, 6)
        # IMCCE:       2025-03-14T12:09:06+00:00
        # Stellarium:  2025-03-14T12:09:00+00:00
        # Skyfield:    2025-03-14T12:09:06+00:00
        # Timeanddate: 2025-03-14T12:09:00+00:00

        expect(events.setting_times.first)
          .to eq Time.utc(2025, 3, 14, 18, 12, 22)
        # USNO:        2025-03-14T18:12:00+00:00
        # Stellarium:  2025-03-14T18:12:00+00:00
        # Skyfield:    2025-03-14T18:12:21+00:00
        # Timeanddate: 2025-03-14T18:12:00+00:00
      end
    end

    context "when the body does not rise" do
      it "returns nil for rising and setting" do
        ephem = test_ephem
        utc_offset = "+12:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(-67.56793423209638),
          longitude: Astronoby::Angle.from_degrees(-68.12415901809868)
        )
        date = Date.new(2025, 6, 21)
        calculator = described_class.new(
          body: Astronoby::Sun,
          observer: observer,
          ephem: ephem
        )

        events = calculator.events_on(date, utc_offset: utc_offset)

        aggregate_failures do
          expect(events.rising_times.first).to be_nil

          expect(events.transit_times.first.localtime(utc_offset))
            .to eq Time.new(2025, 6, 21, 4, 34, 11, utc_offset)
          # IMCCE:       2025-06-21T04:34:24+12:00
          # Stellarium:  2025-06-21T04:34:00+12:00
          # Skyfield:    2025-06-21T04:34:10+12:00
          # Timeanddate: 2025-06-21T04:32:00+12:00

          expect(events.setting_times.first).to be_nil
        end
      end
    end

    context "when the body does not set" do
      it "returns nil for rising and setting" do
        ephem = test_ephem
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(80),
          longitude: Astronoby::Angle.zero
        )
        date = Date.new(2025, 6, 21)
        calculator = described_class.new(
          body: Astronoby::Sun,
          observer: observer,
          ephem: ephem
        )

        events = calculator.events_on(date)

        aggregate_failures do
          expect(events.rising_times.first).to be_nil

          expect(events.transit_times.first)
            .to eq Time.utc(2025, 6, 21, 12, 1, 52)
          # IMCCE:       2025-06-21T12:01:51+00:00
          # Stellarium:  2025-06-21T12:02:00+00:00
          # Skyfield:    2025-06-21T12:01:51+00:00
          # Timeanddate: 2025-06-21T11:58:00+00:00

          expect(events.setting_times.first).to be_nil
        end
      end
    end

    context "when the body doesn't rise for one day because of its motion" do
      it "computes correct values on the day before" do
        ephem = test_ephem
        utc_offset = "-07:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(39.74),
          longitude: Astronoby::Angle.from_degrees(-104.99),
          elevation: Astronoby::Distance.zero
        )
        date = Date.new(2025, 12, 10)
        calculator = described_class.new(
          body: Astronoby::Moon,
          observer: observer,
          ephem: ephem
        )

        events = calculator.events_on(date, utc_offset: utc_offset)

        aggregate_failures do
          expect(events.rising_times.first.localtime(utc_offset))
            .to eq Time.new(2025, 12, 10, 23, 11, 16, utc_offset)
          # USNO:        2025-12-10T23:11:00-07:00
          # Stellarium:  2025-12-10T23:11:00-07:00
          # Skyfield:    2025-12-10T23:11:15-07:00
          # Timeanddate: 2025-12-10T23:11:00-07:00

          expect(events.transit_times.first.localtime(utc_offset))
            .to eq Time.new(2025, 12, 10, 5, 1, 55, utc_offset)
          # IMCCE:       2025-12-10T05:01:33-07:00
          # Stellarium:  2025-12-10T05:02:00-07:00
          # Skyfield:    2025-12-10T05:01:33-07:00
          # Timeanddate: 2025-12-10T05:01:00-07:00

          expect(events.setting_times.first.localtime(utc_offset))
            .to eq Time.new(2025, 12, 10, 11, 46, 17, utc_offset)
          # USNO:        2025-12-10T11:46:00-07:00
          # Stellarium:  2025-12-10T11:46:00-07:00
          # Skyfield:    2025-12-10T11:46:10-07:00
          # Timeanddate: 2025-12-10T11:46:00-07:00
        end
      end

      it "correctly set the rising time and azimuth to nil" do
        ephem = test_ephem
        utc_offset = "-07:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(39.74),
          longitude: Astronoby::Angle.from_degrees(-104.99),
          elevation: Astronoby::Distance.zero
        )
        date = Date.new(2025, 12, 11)
        calculator = described_class.new(
          body: Astronoby::Moon,
          observer: observer,
          ephem: ephem
        )

        events = calculator.events_on(date, utc_offset: utc_offset)

        aggregate_failures do
          expect(events.rising_times.first).to be_nil

          expect(events.transit_times.first.localtime(utc_offset))
            .to eq Time.new(2025, 12, 11, 5, 45, 29, utc_offset)
          # IMCCE:       2025-12-11T05:45:25-07:00
          # Stellarium:  2025-12-11T05:45:00-07:00
          # Skyfield:    2025-12-11T05:45:24-07:00
          # Timeanddate: 2025-12-11T05:45:00-07:00

          expect(events.setting_times.first.localtime(utc_offset))
            .to eq Time.new(2025, 12, 11, 12, 8, 25, utc_offset)
          # USNO:        2025-12-11T12:08:00-07:00
          # Stellarium:  2025-12-11T12:08:00-07:00
          # Skyfield:    2025-12-11T12:08:21-07:00
          # Timeanddate: 2025-12-11T12:08:00-07:00
        end
      end

      it "computes correct values on the day after" do
        ephem = test_ephem
        utc_offset = "-07:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(39.74),
          longitude: Astronoby::Angle.from_degrees(-104.99),
          elevation: Astronoby::Distance.zero
        )
        date = Date.new(2025, 12, 12)
        calculator = described_class.new(
          body: Astronoby::Moon,
          observer: observer,
          ephem: ephem
        )

        events = calculator.events_on(date, utc_offset: utc_offset)

        aggregate_failures do
          expect(events.rising_times.first.localtime(utc_offset))
            .to eq Time.new(2025, 12, 12, 0, 14, 27, utc_offset)
          # USNO:        2025-12-12T00:14:00-07:00
          # Stellarium:  2025-12-12T00:14:00-07:00
          # Skyfield:    2025-12-12T00:14:26-07:00
          # Timeanddate: 2025-12-12T00:14:00-07:00

          expect(events.transit_times.first.localtime(utc_offset))
            .to eq Time.new(2025, 12, 12, 6, 26, 52, utc_offset)
          # IMCCE:       2025-12-12T06:26:52-07:00
          # Stellarium:  2025-12-12T06:27:00-07:00
          # Skyfield:    2025-12-12T06:26:51-07:00
          # Timeanddate: 2025-12-12T06:26:00-07:00

          expect(events.setting_times.first.localtime(utc_offset))
            .to eq Time.new(2025, 12, 12, 12, 29, 16, utc_offset)
          # USNO:        2025-12-12T12:29:00-07:00
          # Stellarium:  2025-12-12T12:29:00-07:00
          # Skyfield:    2025-12-12T12:29:01-07:00
          # Timeanddate: 2025-12-12T12:29:00-07:00
        end
      end
    end

    context "when the observer is high above sea level" do
      it "takes the observer's elevation into account" do
        ephem = test_ephem
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(35.88071676915352),
          longitude: Astronoby::Angle.from_degrees(76.51522879779951),
          elevation: Astronoby::Distance.from_meters(8611)
        )
        date = Date.new(2025, 8, 7)
        calculator = described_class.new(
          body: Astronoby::Venus,
          observer: observer,
          ephem: ephem
        )

        events = calculator.events_on(date)

        aggregate_failures do
          expect(events.rising_times.first)
            .to eq Time.utc(2025, 8, 7, 21, 15, 3)
          # IMCCE:       2025-08-07T21:14:48+00:00
          # Stellarium:  2025-08-07T21:15:02+00:00
          # Skyfield:    2025-08-07T21:15:03+00:00

          expect(events.transit_times.first)
            .to eq Time.utc(2025, 8, 7, 4, 25, 19)
          # IMCCE:       2025-08-07T04:25:19+00:00
          # Stellarium:  2025-08-07T04:25:00+00:00
          # Skyfield:    2025-08-07T04:25:19+00:00

          expect(events.setting_times.first)
            .to eq Time.utc(2025, 8, 7, 11, 36, 44)
          # IMCCE:       2025-08-07T11:36:58+00:00
          # Stellarium:  2025-08-07T11:37:00+00:00
          # Skyfield:    2025-08-07T11:36:43+00:00
        end
      end
    end
  end

  describe "#events_between" do
    it "computes lists of rising, transit and setting times" do
      ephem = test_ephem
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      start_time = Time.utc(2025, 3, 10)
      end_time = Time.utc(2025, 3, 13)
      calculator = described_class.new(
        body: Astronoby::Sun,
        observer: observer,
        ephem: ephem
      )

      events = calculator.events_between(start_time, end_time)

      aggregate_failures do
        expect(events.rising_times.size).to eq 3
        expect(events.rising_times[0]).to eq Time.utc(2025, 3, 10, 6, 6, 55)
        expect(events.rising_times[1]).to eq Time.utc(2025, 3, 11, 6, 6, 39)
        expect(events.rising_times[2]).to eq Time.utc(2025, 3, 12, 6, 6, 23)

        expect(events.transit_times.size).to eq 3
        expect(events.transit_times[0]).to eq Time.utc(2025, 3, 10, 12, 10, 11)
        expect(events.transit_times[1]).to eq Time.utc(2025, 3, 11, 12, 9, 55)
        expect(events.transit_times[2]).to eq Time.utc(2025, 3, 12, 12, 9, 39)

        expect(events.setting_times.size).to eq 3
        expect(events.setting_times[0]).to eq Time.utc(2025, 3, 10, 18, 13, 26)
        expect(events.setting_times[1]).to eq Time.utc(2025, 3, 11, 18, 13, 11)
        expect(events.setting_times[2]).to eq Time.utc(2025, 3, 12, 18, 12, 55)
      end
    end
  end
end
