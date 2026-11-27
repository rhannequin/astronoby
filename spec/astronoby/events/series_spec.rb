# frozen_string_literal: true

RSpec.describe Astronoby::Events::Series do
  def instant_at(time)
    Astronoby::Instant.from_time(time)
  end

  describe "#between" do
    it "returns the events in the range, ends included, sorted by time" do
      events = [
        instant_at(Time.utc(2025, 10, 3)),
        instant_at(Time.utc(2025, 10, 1)),
        instant_at(Time.utc(2025, 10, 5))
      ]
      series = described_class.new(window: 1, horizon: 10, time_of: :itself.to_proc) do
        events
      end

      found = series.between(Time.utc(2025, 10, 1), instant_at(Time.utc(2025, 10, 3)))

      expect(found).to eq([events[1], events[0]])
    end
  end

  describe "#on" do
    it "returns the events of the civil day in the given offset" do
      events = [
        instant_at(Time.utc(2025, 9, 30, 21, 59)),
        instant_at(Time.utc(2025, 9, 30, 22)),
        instant_at(Time.utc(2025, 10, 1, 21, 59)),
        instant_at(Time.utc(2025, 10, 1, 22))
      ]
      series = described_class.new(window: 1, horizon: 10, time_of: :itself.to_proc) do
        events
      end

      found = series.on(Date.new(2025, 10, 1), utc_offset: "+02:00")

      expect(found).to eq(events[1..2])
    end
  end

  describe "#from" do
    it "searches one window at a time, only as far as asked" do
      windows = []
      series = described_class.new(window: 1, horizon: 10, time_of: :itself.to_proc) do |start, finish|
        windows << [start, finish]
        [Astronoby::Instant.from_terrestrial_time(start.tt + 0.5)]
      end
      start = instant_at(Time.utc(2025, 10, 1))

      found = series.from(start).first(2)

      expect(found.map(&:tt)).to eq([start.tt + 0.5, start.tt + 1.5])
      expect(windows.size).to eq(2)
    end

    it "stops after the horizon" do
      series = described_class.new(window: 1, horizon: 3, time_of: :itself.to_proc) do |start, _|
        [Astronoby::Instant.from_terrestrial_time(start.tt + 0.5)]
      end

      found = series.from(instant_at(Time.utc(2025, 10, 1))).to_a

      expect(found.size).to eq(3)
    end

    it "stops at the end of the ephemeris" do
      start = instant_at(Time.utc(2025, 10, 1))
      series = described_class.new(window: 1, horizon: 10, time_of: :itself.to_proc) do |window_start, _|
        if window_start.tt >= start.tt + 2
          raise ::Ephem::OutOfRangeError.new("out", window_start.tt)
        end

        [Astronoby::Instant.from_terrestrial_time(window_start.tt + 0.5)]
      end

      found = series.from(start).to_a

      expect(found.size).to eq(2)
    end

    it "stops at the last time the ephemeris covers" do
      start = instant_at(Time.utc(2025, 10, 1))
      windows = []
      series = described_class.new(
        window: 1,
        horizon: 10,
        time_of: :itself.to_proc,
        last_tt: start.tt + 2.5
      ) do |window_start, window_end|
        windows << window_end.tt - window_start.tt
        []
      end

      series.from(start).to_a

      expect(windows).to eq([1, 1, 0.5])
    end

    it "raises when the start is after the last time the ephemeris covers" do
      start = instant_at(Time.utc(2025, 10, 1))
      series = described_class.new(
        window: 1,
        horizon: 10,
        time_of: :itself.to_proc,
        last_tt: start.tt - 1
      ) { [] }

      expect { series.from(start).first }
        .to raise_error(::Ephem::OutOfRangeError)
    end

    it "raises when the ephemeris does not cover the start" do
      series = described_class.new(window: 1, horizon: 10, time_of: :itself.to_proc) do |start, _|
        raise ::Ephem::OutOfRangeError.new("out", start.tt)
      end

      expect { series.from(instant_at(Time.utc(2025, 10, 1))).first }
        .to raise_error(::Ephem::OutOfRangeError)
    end
  end
end
