# frozen_string_literal: true

RSpec.describe Astronoby::TwilightCalculator do
  include TestEphemHelper

  describe "#morning_civil_twilight_time" do
    it "returns a time" do
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(Date.new(2025, 1, 1))

      expect(event.morning_civil_twilight_time).to be_a(Time)
    end

    it "returns when the morning civil twilight starts" do
      date = Date.new(2024, 3, 14)
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8575),
        longitude: Astronoby::Angle.from_degrees(2.3514)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.morning_civil_twilight_time)
        .to eq Time.utc(2024, 3, 14, 5, 33, 56)
      # IMCCE:       05:33:55
      # USNO:        05:34
      # Skyfield:    05:33:54
      # Timeanddate: 05:33
    end

    context "when the civil twilight doesn't start" do
      it "returns nil" do
        date = Date.new(2024, 6, 20)
        ephem = test_ephem_sun
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(65),
          longitude: Astronoby::Angle.zero
        )
        calculator = described_class.new(
          observer: observer,
          ephem: ephem
        )

        event = calculator.event_on(date)

        expect(event.morning_civil_twilight_time).to be_nil
      end
    end
  end

  describe "#evening_civil_twilight_time" do
    it "returns a time" do
      date = Date.today
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.evening_civil_twilight_time).to be_a(Time)
    end

    it "returns when the evening civil twilight ends" do
      date = Date.new(2024, 3, 14)
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8575),
        longitude: Astronoby::Angle.from_degrees(2.3514)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.evening_civil_twilight_time)
        .to eq Time.utc(2024, 3, 14, 18, 26, 14)
      # IMCCE:       18:26:20
      # USNO:        18:26
      # Skyfield:    18:26:20
      # Timeanddate: 18:26
    end

    context "when the civil twilight doesn't start" do
      it "returns nil" do
        date = Date.new(2024, 6, 20)
        ephem = test_ephem_sun
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(65),
          longitude: Astronoby::Angle.zero
        )
        calculator = described_class.new(
          observer: observer,
          ephem: ephem
        )

        event = calculator.event_on(date)

        expect(event.evening_civil_twilight_time).to be_nil
      end
    end
  end

  describe "#morning_nautical_twilight_time" do
    it "returns a time" do
      date = Date.today
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.morning_nautical_twilight_time).to be_a(Time)
    end

    it "returns when the morning nautical twilight starts" do
      date = Date.new(2024, 3, 14)
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8575),
        longitude: Astronoby::Angle.from_degrees(2.3514)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.morning_nautical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 4, 57, 16)
      # IMCCE:       04:57:12
      # USNO:        04:57
      # Skyfield:    04:57:12
      # Timeanddate: 04:57
    end

    context "when the nautical twilight doesn't start" do
      it "returns nil" do
        date = Date.new(2024, 6, 20)
        ephem = test_ephem_sun
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(55),
          longitude: Astronoby::Angle.zero
        )
        calculator = described_class.new(
          observer: observer,
          ephem: ephem
        )

        event = calculator.event_on(date)

        expect(event.morning_nautical_twilight_time).to be_nil
      end
    end
  end

  describe "#evening_nautical_twilight_time" do
    it "returns a time" do
      date = Date.today
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.evening_nautical_twilight_time).to be_a(Time)
    end

    it "returns when the evening nautical twilight ends" do
      date = Date.new(2024, 3, 14)
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8575),
        longitude: Astronoby::Angle.from_degrees(2.3514)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.evening_nautical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 19, 2, 55)
      # IMCCE:       19:03:10
      # USNO:        19:03
      # Skyfield:    19:03:09
      # Timeanddate: 19:03
    end

    context "when the nautical twilight doesn't start" do
      it "returns nil" do
        date = Date.new(2024, 6, 20)
        ephem = test_ephem_sun
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(55),
          longitude: Astronoby::Angle.zero
        )
        calculator = described_class.new(
          observer: observer,
          ephem: ephem
        )

        event = calculator.event_on(date)

        expect(event.evening_nautical_twilight_time).to be_nil
      end
    end
  end

  describe "#morning_astronomical_twilight_time" do
    it "returns a time" do
      date = Date.today
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.morning_astronomical_twilight_time).to be_a(Time)
    end

    it "returns when the morning astronomical twilight starts" do
      date = Date.new(2024, 3, 14)
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8575),
        longitude: Astronoby::Angle.from_degrees(2.3514)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.morning_astronomical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 4, 19, 44)
      # IMCCE:       04:19:38
      # USNO:        04:20
      # Skyfield:    04:19:37
      # Timeanddate: 04:19
    end

    context "when the astronomical twilight doesn't start" do
      it "returns nil" do
        date = Date.new(2024, 6, 20)
        ephem = test_ephem_sun
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(49),
          longitude: Astronoby::Angle.zero
        )
        calculator = described_class.new(
          observer: observer,
          ephem: ephem
        )

        event = calculator.event_on(date)

        expect(event.morning_astronomical_twilight_time).to be_nil
      end
    end
  end

  describe "#evening_astronomical_twilight_time" do
    it "returns a time" do
      date = Date.today
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.evening_astronomical_twilight_time).to be_a(Time)
    end

    it "returns when the evening astronomical twilight ends" do
      date = Date.new(2024, 3, 14)
      ephem = test_ephem_sun
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8575),
        longitude: Astronoby::Angle.from_degrees(2.3514)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.evening_astronomical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 19, 40, 30)
      # IMCCE:       19:40:54
      # USNO:        19:41
      # Skyfield:    19:40:54
      # Timeanddate: 19:40
    end

    context "when the astronomical twilight doesn't start" do
      it "returns nil" do
        date = Date.new(2024, 6, 20)
        ephem = test_ephem_sun
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(49),
          longitude: Astronoby::Angle.zero
        )
        calculator = described_class.new(
          observer: observer,
          ephem: ephem
        )

        event = calculator.event_on(date)

        expect(event.evening_astronomical_twilight_time).to be_nil
      end
    end

    context "with utc_offset" do
      it "uses the utc_offset for day boundaries" do
        ephem = test_ephem_sun
        date = Date.new(2025, 1, 1)
        utc_offset = "-10:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(-17.4747),
          longitude: Astronoby::Angle.from_degrees(-149.4822)
        )
        calculator = described_class.new(
          observer: observer,
          ephem: ephem
        )

        event = calculator.event_on(date, utc_offset: utc_offset)

        expect(event.morning_civil_twilight_time.localtime(utc_offset))
          .to eq(Time.new(2025, 1, 1, 5, 3, 18, utc_offset))
        # IMCCE:       2025-01-01T05:03:14-10:00
        # USNO:        2025-01-01T05:03   -10:00
        # Skyfield:    2025-01-01T05:03:13-10:00
        # Timeanddate: 2025-01-01T05:03   -10:00
        expect(event.evening_civil_twilight_time.localtime(utc_offset))
          .to eq(Time.new(2025, 1, 1, 19, 0, 14, utc_offset))
        # IMCCE:       2025-01-01T19:00:17-10:00
        # USNO:        2025-01-01T19:00   -10:00
        # Skyfield:    2025-01-01T19:00:17-10:00
        # Timeanddate: 2025-01-01T19:00   -10:00
      end
    end
  end

  describe "#time_for_zenith_angle" do
    it "returns a time" do
      ephem = test_ephem_sun
      date = Date.new(2025, 1, 1)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )
      zenith_angle = Astronoby::Angle.from_degrees(90 + 17)

      time = calculator.time_for_zenith_angle(
        date: date,
        period_of_the_day: :morning,
        zenith_angle: zenith_angle
      )

      expect(time).to eq(Time.utc(2025, 1, 1, 4, 50, 48))
    end

    context "when the period of time is incompatible" do
      it "raises an error" do
        ephem = test_ephem_sun
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.zero,
          longitude: Astronoby::Angle.zero
        )
        calculator = described_class.new(
          observer: observer,
          ephem: ephem
        )
        zenith_angle = Astronoby::Angle.zero

        expect {
          calculator.time_for_zenith_angle(
            date: Date.new(2025, 1, 1),
            period_of_the_day: :afternoon,
            zenith_angle: zenith_angle
          )
        }.to raise_error(Astronoby::IncompatibleArgumentsError)
      end
    end

    context "with utc_offset" do
      it "calculates zenith angle times for local time instead of UTC" do
        ephem = test_ephem_sun
        date = Date.new(2025, 1, 1)
        utc_offset = "-10:00"
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(-17.4747),
          longitude: Astronoby::Angle.from_degrees(-149.4822)
        )
        calculator = described_class.new(
          observer: observer,
          ephem: ephem
        )
        zenith_angle = Astronoby::Angle.from_degrees(90 + 17)

        time = calculator.time_for_zenith_angle(
          date: date,
          period_of_the_day: :evening,
          zenith_angle: zenith_angle,
          utc_offset: utc_offset
        )

        expect(time.localtime(utc_offset))
          .to eq(Time.new(2025, 1, 1, 19, 51, 35, utc_offset))
      end
    end
  end
end
