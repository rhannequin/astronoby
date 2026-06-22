# frozen_string_literal: true

RSpec.describe Astronoby::GreatestElongationCalculator do
  include TestEphemHelper

  describe "#greatest_elongation_events_between" do
    it "finds Venus' 2025 morning and evening elongations" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(body: Astronoby::Venus, ephem: ephem)

      events = calculator.greatest_elongation_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(events.size).to eq(2)

      expect(events.first).to be_a(Astronoby::GreatestElongation)
      expect(events.first).to be_eastern
      expect(events.first.instant.to_time.round)
        .to eq(Time.utc(2025, 1, 10, 5, 1, 35))
      # IMCCE:    2025-01-10T05:01:19Z
      # Skyfield: 2025-01-10T05:01:36Z
      expect(events.first.angle.degrees.round(4)).to eq(47.1687)
      # IMCCE:    47.1668°
      # Skyfield: 47.2°

      expect(events.last).to be_western
      expect(events.last.instant.to_time.round)
        .to eq(Time.utc(2025, 6, 1, 3, 28, 33))
      # IMCCE:    2025-06-01T03:28:39Z
      # Skyfield: 2025-06-01T03:28:32Z
      expect(events.last.angle.degrees.round(4)).to eq(45.883)
      # IMCCE:    45.8846°
      # Skyfield: 45.9°
    end

    it "finds Mercury's six 2025 greatest elongations, alternating sides" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(body: Astronoby::Mercury, ephem: ephem)

      events = calculator.greatest_elongation_events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(
        events.map { |event| [event.instant.to_time.round, event.direction] }
      ).to eq(
        [
          [Time.utc(2025, 3, 8, 6, 9, 18), :eastern],
          [Time.utc(2025, 4, 21, 18, 49, 6), :western],
          [Time.utc(2025, 7, 4, 4, 38, 47), :eastern],
          [Time.utc(2025, 8, 19, 9, 48, 4), :western],
          [Time.utc(2025, 10, 29, 22, 2, 12), :eastern],
          [Time.utc(2025, 12, 7, 21, 2, 53), :western]
        ]
      )

      expect(events.map { |event| event.angle.degrees.round(2) })
        .to eq([18.25, 27.39, 25.93, 18.58, 23.88, 20.73])
      # Angles from IMCCE: 18.2478°, 27.3909°, 25.9330°, 18.5837°,
      #   23.8823°, 20.7298°
    end
  end
end
