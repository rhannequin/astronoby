# frozen_string_literal: true

RSpec.describe Astronoby::Events::TwilightEvents do
  describe "#morning_civil_twilight_time" do
    it "returns a time" do
      sun = Astronoby::Sun.new(time: Time.new)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_civil_twilight_time).to be_a(Time)
    end

    it "returns when the morning civil twilight starts" do
      sun = Astronoby::Sun.new(time: Time.utc(1979, 9, 7))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_civil_twilight_time)
        .to eq Time.utc(1979, 9, 7, 4, 47, 13)
      # Time from IMCCE: 04:46
    end

    it "returns when the morning civil twilight starts" do
      sun = Astronoby::Sun.new(time: Time.utc(2024, 3, 14))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_civil_twilight_time)
        .to eq Time.utc(2024, 3, 14, 19, 28, 0)
      # Time from IMCCE: 19:29:29
    end

    context "when the civil twilight doesn't start" do
      it "returns nil" do
        sun = Astronoby::Sun.new(time: Time.utc(2024, 6, 20))
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(65),
          longitude: Astronoby::Angle.zero
        )
        twilight_events = described_class.new(observer: observer, sun: sun)

        expect(twilight_events.morning_civil_twilight_time).to be_nil
      end
    end
  end

  describe "#evening_civil_twilight_time" do
    it "returns a time" do
      sun = Astronoby::Sun.new(time: Time.new)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_civil_twilight_time).to be_a(Time)
    end

    it "returns when the evening civil twilight ends" do
      sun = Astronoby::Sun.new(time: Time.utc(1979, 9, 7))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_civil_twilight_time)
        .to eq Time.utc(1979, 9, 7, 19, 9, 8)
      # Time from IMCCE: 19:10
    end

    it "returns when the evening civil twilight ends" do
      sun = Astronoby::Sun.new(time: Time.utc(2024, 3, 14))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_civil_twilight_time)
        .to eq Time.utc(2024, 3, 14, 8, 39, 45)
      # Time from IMCCE: 08:39:23
    end

    context "when the civil twilight doesn't start" do
      it "returns nil" do
        sun = Astronoby::Sun.new(time: Time.utc(2024, 6, 20))
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(65),
          longitude: Astronoby::Angle.zero
        )
        twilight_events = described_class.new(observer: observer, sun: sun)

        expect(twilight_events.evening_civil_twilight_time).to be_nil
      end
    end
  end

  describe "#morning_nautical_twilight_time" do
    it "returns a time" do
      sun = Astronoby::Sun.new(time: Time.new)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_nautical_twilight_time).to be_a(Time)
    end

    it "returns when the morning nautical twilight starts" do
      sun = Astronoby::Sun.new(time: Time.utc(1979, 9, 7))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_nautical_twilight_time)
        .to eq Time.utc(1979, 9, 7, 4, 5, 7)
      # Time from IMCCE: 04:03
    end

    it "returns when the morning nautical twilight starts" do
      sun = Astronoby::Sun.new(time: Time.utc(2024, 3, 14))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_nautical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 18, 58, 49)
      # Time from IMCCE: 19:00:13
    end

    context "when the nautical twilight doesn't start" do
      it "returns nil" do
        sun = Astronoby::Sun.new(time: Time.utc(2024, 6, 20))
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(55),
          longitude: Astronoby::Angle.zero
        )
        twilight_events = described_class.new(observer: observer, sun: sun)

        expect(twilight_events.morning_nautical_twilight_time).to be_nil
      end
    end
  end

  describe "#evening_nautical_twilight_time" do
    it "returns a time" do
      sun = Astronoby::Sun.new(time: Time.new)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_nautical_twilight_time).to be_a(Time)
    end

    it "returns when the evening nautical twilight ends" do
      sun = Astronoby::Sun.new(time: Time.utc(1979, 9, 7))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_nautical_twilight_time)
        .to eq Time.utc(1979, 9, 7, 19, 51, 14)
      # Time from IMCCE: 19:52
    end

    it "returns when the evening nautical twilight ends" do
      sun = Astronoby::Sun.new(time: Time.utc(2024, 3, 14))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_nautical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 9, 8, 56)
      # Time from IMCCE: 09:08:37
    end

    context "when the nautical twilight doesn't start" do
      it "returns nil" do
        sun = Astronoby::Sun.new(time: Time.utc(2024, 6, 20))
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(55),
          longitude: Astronoby::Angle.zero
        )
        twilight_events = described_class.new(observer: observer, sun: sun)

        expect(twilight_events.evening_nautical_twilight_time).to be_nil
      end
    end
  end

  describe "#morning_astronomical_twilight_time" do
    it "returns a time" do
      sun = Astronoby::Sun.new(time: Time.new)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_astronomical_twilight_time).to be_a(Time)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 50 - Twilight, p.114
    it "returns when the morning astronomical twilight starts" do
      sun = Astronoby::Sun.new(time: Time.utc(1979, 9, 7))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_astronomical_twilight_time)
        .to eq Time.utc(1979, 9, 7, 3, 19, 20)
      # Time from Practical Astronomy: 03:12
      # Time from IMCCE: 03:17
    end

    it "returns when the morning astronomical twilight starts" do
      sun = Astronoby::Sun.new(time: Time.utc(2024, 3, 14))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_astronomical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 18, 29, 12)
      # Time from IMCCE: 18:30:31
    end

    context "when the astronomical twilight doesn't start" do
      it "returns nil" do
        sun = Astronoby::Sun.new(time: Time.utc(2024, 6, 20))
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(49),
          longitude: Astronoby::Angle.zero
        )
        twilight_events = described_class.new(observer: observer, sun: sun)

        expect(twilight_events.morning_astronomical_twilight_time).to be_nil
      end
    end
  end

  describe "#evening_astronomical_twilight_time" do
    it "returns a time" do
      sun = Astronoby::Sun.new(time: Time.new)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_astronomical_twilight_time).to be_a(Time)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 50 - Twilight, p.114
    it "returns when the evening astronomical twilight ends" do
      sun = Astronoby::Sun.new(time: Time.utc(1979, 9, 7))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_astronomical_twilight_time)
        .to eq Time.utc(1979, 9, 7, 20, 37, 1)
      # Time from Practical Astronomy: 20:43
      # Time from IMCCE: 20:37
    end

    it "returns when the evening astronomical twilight ends" do
      sun = Astronoby::Sun.new(time: Time.utc(2024, 3, 14))
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_astronomical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 9, 38, 33)
      # Time from IMCCE: 09:38:17
    end

    context "when the astronomical twilight doesn't start" do
      it "returns nil" do
        sun = Astronoby::Sun.new(time: Time.utc(2024, 6, 20))
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(49),
          longitude: Astronoby::Angle.zero
        )
        twilight_events = described_class.new(observer: observer, sun: sun)

        expect(twilight_events.evening_astronomical_twilight_time).to be_nil
      end
    end
  end

  describe "#time_for_zenith_angle" do
    it "returns a time" do
      sun = Astronoby::Sun.new(time: Time.new)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)
      zenith_angle = Astronoby::Angle.from_degrees(90 + 17)

      time = twilight_events.time_for_zenith_angle(
        period_of_the_day: :morning,
        zenith_angle: zenith_angle
      )

      expect(time).to be_a(Time)
    end

    context "when the period of time is incompatible" do
      it "raises an error" do
        sun = Astronoby::Sun.new(time: Time.new)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.zero,
          longitude: Astronoby::Angle.zero
        )
        twilight_events = described_class.new(observer: observer, sun: sun)
        zenith_angle = Astronoby::Angle.zero

        expect {
          twilight_events.time_for_zenith_angle(
            period_of_the_day: :afternoon,
            zenith_angle: zenith_angle
          )
        }.to raise_error(Astronoby::IncompatibleArgumentsError)
      end
    end
  end
end
