# frozen_string_literal: true

RSpec.describe Astronoby::Events::TwilightEvents do
  describe "#morning_civil_twilight_time" do
    it "returns a time" do
      epoch = Astronoby::Epoch.from_time(Date.new)
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_civil_twilight_time).to be_a(Time)
    end

    it "returns when the morning civil twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_civil_twilight_time)
        .to eq Time.utc(1979, 9, 7, 4, 44, 23)
      # Time from IMCCE: 04:46
    end

    it "returns when the morning civil twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_civil_twilight_time)
        .to eq Time.utc(2024, 3, 14, 19, 25, 38)
      # Time from IMCCE: 19:29:29
    end

    context "when the civil twilight doesn't start" do
      it "returns nil" do
        epoch = Astronoby::Epoch.from_time(Time.utc(2024, 6, 20))
        sun = Astronoby::Sun.new(epoch: epoch)
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
      epoch = Astronoby::Epoch.from_time(Date.new)
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_civil_twilight_time).to be_a(Time)
    end

    it "returns when the evening civil twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_civil_twilight_time)
        .to eq Time.utc(1979, 9, 7, 19, 8, 22)
      # Time from IMCCE: 19:10
    end

    it "returns when the evening civil twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_civil_twilight_time)
        .to eq Time.utc(2024, 3, 14, 8, 38, 28)
      # Time from IMCCE: 08:39:23
    end

    context "when the civil twilight doesn't start" do
      it "returns nil" do
        epoch = Astronoby::Epoch.from_time(Time.utc(2024, 6, 20))
        sun = Astronoby::Sun.new(epoch: epoch)
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
      epoch = Astronoby::Epoch.from_time(Date.new)
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_nautical_twilight_time).to be_a(Time)
    end

    it "returns when the morning nautical twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_nautical_twilight_time)
        .to eq Time.utc(1979, 9, 7, 4, 2, 11)
      # Time from IMCCE: 04:03
    end

    it "returns when the morning nautical twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_nautical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 18, 56, 26)
      # Time from IMCCE: 19:00:13
    end

    context "when the nautical twilight doesn't start" do
      it "returns nil" do
        epoch = Astronoby::Epoch.from_time(Time.utc(2024, 6, 20))
        sun = Astronoby::Sun.new(epoch: epoch)
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
      epoch = Astronoby::Epoch.from_time(Date.new)
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_nautical_twilight_time).to be_a(Time)
    end

    it "returns when the evening nautical twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_nautical_twilight_time)
        .to eq Time.utc(1979, 9, 7, 19, 50, 34)
      # Time from IMCCE: 19:52
    end

    it "returns when the evening nautical twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_nautical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 9, 7, 39)
      # Time from IMCCE: 09:08:37
    end

    context "when the nautical twilight doesn't start" do
      it "returns nil" do
        epoch = Astronoby::Epoch.from_time(Time.utc(2024, 6, 20))
        sun = Astronoby::Sun.new(epoch: epoch)
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
      epoch = Astronoby::Epoch.from_time(Date.new)
      sun = Astronoby::Sun.new(epoch: epoch)
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
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_astronomical_twilight_time)
        .to eq Time.utc(1979, 9, 7, 3, 16, 13)
      # Time from Practical Astronomy: 03:12
      # Time from IMCCE: 03:17
    end

    it "returns when the morning astronomical twilight starts" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.morning_astronomical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 18, 26, 47)
      # Time from IMCCE: 18:30:31
    end

    context "when the astronomical twilight doesn't start" do
      it "returns nil" do
        epoch = Astronoby::Epoch.from_time(Time.utc(2024, 6, 20))
        sun = Astronoby::Sun.new(epoch: epoch)
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
      epoch = Astronoby::Epoch.from_time(Date.new)
      sun = Astronoby::Sun.new(epoch: epoch)
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
      epoch = Astronoby::Epoch.from_time(Time.utc(1979, 9, 7))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(52),
        longitude: Astronoby::Angle.zero
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_astronomical_twilight_time)
        .to eq Time.utc(1979, 9, 7, 20, 36, 33)
      # Time from Practical Astronomy: 20:43
      # Time from IMCCE: 20:37
    end

    it "returns when the evening astronomical twilight ends" do
      epoch = Astronoby::Epoch.from_time(Time.utc(2024, 3, 14))
      sun = Astronoby::Sun.new(epoch: epoch)
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_dms(-33, 52, 4),
        longitude: Astronoby::Angle.from_dms(151, 12, 26)
      )
      twilight_events = described_class.new(observer: observer, sun: sun)

      expect(twilight_events.evening_astronomical_twilight_time)
        .to eq Time.utc(2024, 3, 14, 9, 37, 18)
      # Time from IMCCE: 09:38:17
    end

    context "when the astronomical twilight doesn't start" do
      it "returns nil" do
        epoch = Astronoby::Epoch.from_time(Time.utc(2024, 6, 20))
        sun = Astronoby::Sun.new(epoch: epoch)
        observer = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(49),
          longitude: Astronoby::Angle.zero
        )
        twilight_events = described_class.new(observer: observer, sun: sun)

        expect(twilight_events.evening_astronomical_twilight_time).to be_nil
      end
    end
  end
end
