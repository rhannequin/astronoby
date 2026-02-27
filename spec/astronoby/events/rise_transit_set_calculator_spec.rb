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
          .to eq Time.utc(2025, 3, 14, 18, 12, 21)
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
            .to eq Time.utc(2025, 6, 21, 12, 1, 51)
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
            .to eq Time.new(2025, 12, 10, 23, 11, 15, utc_offset)
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
            .to eq Time.new(2025, 12, 11, 5, 45, 28, utc_offset)
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
            .to eq Time.new(2025, 12, 12, 6, 26, 51, utc_offset)
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
            .to eq Time.utc(2025, 8, 7, 21, 15, 2)
          # IMCCE:       2025-08-07T21:14:48+00:00
          # Stellarium:  2025-08-07T21:15:02+00:00
          # Skyfield:    2025-08-07T21:15:03+00:00

          expect(events.transit_times.first)
            .to eq Time.utc(2025, 8, 7, 4, 25, 19)
          # IMCCE:       2025-08-07T04:25:19+00:00
          # Stellarium:  2025-08-07T04:25:00+00:00
          # Skyfield:    2025-08-07T04:25:19+00:00

          expect(events.setting_times.first)
            .to eq Time.utc(2025, 8, 7, 11, 36, 43)
          # IMCCE:       2025-08-07T11:36:58+00:00
          # Stellarium:  2025-08-07T11:37:00+00:00
          # Skyfield:    2025-08-07T11:36:43+00:00
        end
      end
    end

    context "when the body is a deep sky object" do
      it "computes correct values" do
        ephem = test_ephem
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(51.5072),
          longitude: Astronoby::Angle.from_degrees(-0.1276)
        )
        date = Date.new(2025, 10, 1)
        body = Astronoby::DeepSkyObject.new(
          equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
            right_ascension: Astronoby::Angle.from_hms(6, 45, 8.917),
            declination: Astronoby::Angle.from_dms(-16, 42, 58.02)
          ),
          proper_motion_ra: Astronoby::AngularVelocity
            .from_milliarcseconds_per_year(-546.01),
          proper_motion_dec: Astronoby::AngularVelocity
            .from_milliarcseconds_per_year(-1223.08),
          parallax: Astronoby::Angle.from_degree_arcseconds(379.21 / 1000.0),
          radial_velocity: Astronoby::Velocity.from_kilometers_per_second(-5.50)
        )
        calculator = described_class.new(
          body: body,
          observer: observer,
          ephem: ephem
        )

        events = calculator.events_on(date)

        aggregate_failures do
          expect(events.rising_times.first)
            .to eq Time.utc(2025, 10, 1, 1, 31, 27)
          # USNO:       2025-10-01T01:31    UTC
          # Stellarium: 2025-10-01T01:31:27 UTC
          # Skyfield:   2025-10-01T01:36    UTC

          expect(events.transit_times.first)
            .to eq Time.utc(2025, 10, 1, 6, 5, 52)
          # USNO:       2025-10-01T06:06    UTC
          # Stellarium: 2025-10-01T06:05:51 UTC
          # Skyfield:   2025-10-01T06:06    UTC

          expect(events.setting_times.first)
            .to eq Time.utc(2025, 10, 1, 10, 40, 16)
          # USNO:       2025-10-01T10:40    UTC
          # Stellarium: 2025-10-01T10:40:16 UTC
          # Skyfield:   2025-10-01T10:36    UTC
        end
      end

      context "when ephem is not provided" do
        it "computes correct values" do
          observer = Astronoby::Observer.new(
            latitude: Astronoby::Angle.from_degrees(51.5072),
            longitude: Astronoby::Angle.from_degrees(-0.1276)
          )
          date = Date.new(2025, 10, 1)
          body = Astronoby::DeepSkyObject.new(
            equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
              right_ascension: Astronoby::Angle.from_hms(6, 45, 8.917),
              declination: Astronoby::Angle.from_dms(-16, 42, 58.02)
            )
          )
          calculator = described_class.new(body: body, observer: observer)

          events = calculator.events_on(date)

          aggregate_failures do
            expect(events.rising_times.first)
              .to eq Time.utc(2025, 10, 1, 1, 31, 27)
            expect(events.transit_times.first)
              .to eq Time.utc(2025, 10, 1, 6, 5, 53)
            expect(events.setting_times.first)
              .to eq Time.utc(2025, 10, 1, 10, 40, 19)
          end
        end
      end
    end
  end

  describe "#event_on" do
    it "returns the first rising, transit and setting times for a given date" do
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

      event = calculator.event_on(date)

      aggregate_failures do
        expect(event.rising_time).to eq Time.utc(2025, 3, 14, 6, 5, 50)
        expect(event.transit_time).to eq Time.utc(2025, 3, 14, 12, 9, 6)
        expect(event.setting_time).to eq Time.utc(2025, 3, 14, 18, 12, 21)
      end
    end

    context "when caching is enabled" do
      it "returns the right event with acceptable precision" do
        Astronoby.configuration.cache_enabled = true
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

        event = calculator.event_on(date)

        aggregate_failures do
          expect(event.rising_time).to eq Time.utc(2025, 3, 14, 6, 5, 50)
          expect(event.transit_time).to eq Time.utc(2025, 3, 14, 12, 9, 6)
          expect(event.setting_time).to eq Time.utc(2025, 3, 14, 18, 12, 21)
        end

        Astronoby.reset_configuration!
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
        expect(events.rising_times[0]).to eq Time.utc(2025, 3, 10, 6, 6, 54)
        expect(events.rising_times[1]).to eq Time.utc(2025, 3, 11, 6, 6, 39)
        expect(events.rising_times[2]).to eq Time.utc(2025, 3, 12, 6, 6, 23)

        expect(events.transit_times.size).to eq 3
        expect(events.transit_times[0]).to eq Time.utc(2025, 3, 10, 12, 10, 10)
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
