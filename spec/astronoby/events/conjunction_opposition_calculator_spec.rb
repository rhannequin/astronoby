# frozen_string_literal: true

RSpec.describe Astronoby::ConjunctionOppositionCalculator do
  include TestEphemHelper

  describe "#opposition_events_between" do
    it "finds Mars' 2025 opposition" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(body: Astronoby::Mars, ephem: ephem)

      events = calculator.opposition_events_between(
        Time.utc(2024, 12, 1),
        Time.utc(2025, 3, 1)
      )

      expect(events.size).to eq(1)
      expect(events.first).to be_a(Astronoby::Opposition)
      expect(events.first.body).to eq(Astronoby::Mars)
      expect(events.first.instant.to_time.round)
        .to eq(Time.utc(2025, 1, 16, 2, 38, 35))
      # IMCCE:    2025-01-16T02:38:35Z
      # Skyfield: 2025-01-16T02:38:35Z
    end

    it "finds Saturn's 2025 opposition" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(body: Astronoby::Saturn, ephem: ephem)

      events = calculator.opposition_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(events.size).to eq(1)
      expect(events.first.instant.to_time.round)
        .to eq(Time.utc(2025, 9, 21, 5, 45, 38))
      # IMCCE:    2025-09-21T05:45:38Z
      # Skyfield: 2025-09-21T05:45:38Z
    end
  end

  describe "#conjunction_events_between" do
    it "finds and classifies Venus' 2025 inferior conjunction" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(body: Astronoby::Venus, ephem: ephem)

      events = calculator.conjunction_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(events.size).to eq(1)
      expect(events.first).to be_a(Astronoby::Conjunction)
      expect(events.first).to be_inferior
      expect(events.first.instant.to_time.round)
        .to eq(Time.utc(2025, 3, 23, 1, 7, 30))
      # Skyfield: 2025-03-23T01:07:30Z
    end

    it "classifies a superior planet's conjunction as superior" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(body: Astronoby::Saturn, ephem: ephem)

      events = calculator.conjunction_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(events.size).to eq(1)
      expect(events.first).to be_superior
      expect(events.first.instant.to_time.round)
        .to eq(Time.utc(2025, 3, 12, 10, 28, 58))
      # Skyfield: 2025-03-12T10:28:58Z
    end

    it "alternates Mercury's inferior and superior conjunctions" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(body: Astronoby::Mercury, ephem: ephem)

      events = calculator.conjunction_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(
        events.map { |event| [event.instant.to_time.round, event.subtype] }
      ).to eq(
        [
          [Time.utc(2025, 2, 9, 12, 8, 6), :superior],
          [Time.utc(2025, 3, 24, 19, 48, 20), :inferior],
          [Time.utc(2025, 5, 30, 4, 12, 46), :superior],
          [Time.utc(2025, 7, 31, 23, 41, 17), :inferior],
          [Time.utc(2025, 9, 13, 10, 51, 47), :superior],
          [Time.utc(2025, 11, 20, 9, 23, 14), :inferior]
        ]
      )
      # Inferior conjunctions from Skyfield: 2025-03-24T19:48:20Z,
      # 2025-07-31T23:41:17Z, 2025-11-20T09:23:14Z
    end
  end
end
