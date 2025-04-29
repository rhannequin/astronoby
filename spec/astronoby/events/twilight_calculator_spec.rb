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
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.morning_civil_twilight_time)
        .to eq Time.utc(2024, 3, 14, 19, 28, 0)
      # Time from IMCCE: 19:29:29
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
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.evening_civil_twilight_time)
        .to eq Time.utc(2024, 3, 14, 8, 39, 45)
      # Time from IMCCE: 08:39:23
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
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.morning_nautical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 18, 58, 49)
      # Time from IMCCE: 19:00:13
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
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.evening_nautical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 9, 8, 55)
      # Time from IMCCE: 09:08:37
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
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.morning_astronomical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 18, 29, 12)
      # Time from IMCCE: 18:30:31
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
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      calculator = described_class.new(
        observer: observer,
        ephem: ephem
      )

      event = calculator.event_on(date)

      expect(event.evening_astronomical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 9, 38, 32)
      # Time from IMCCE: 09:38:17
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
  end
end
