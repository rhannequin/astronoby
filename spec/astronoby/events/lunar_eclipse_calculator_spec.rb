# frozen_string_literal: true

RSpec.describe Astronoby::LunarEclipseCalculator do
  include TestEphemHelper

  describe "#events_between" do
    it "finds and fully describes the 2025-03-14 total lunar eclipse" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2025, 3, 1),
        Time.utc(2025, 4, 1)
      )

      expect(events.size).to eq(1)
      eclipse = events.first
      expect(eclipse).to be_total
      expect(eclipse.instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 6, 58, 47))
      # IMCCE: 2025-03-14T06:58:47Z
      expect(eclipse.umbral_magnitude.round(5)).to eq(1.17904)
      # IMCCE: 1.17874

      expect(eclipse.penumbral.starting_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 3, 57, 29))
      # IMCCE: 2025-03-14T03:57:29Z (P1)
      expect(eclipse.partial.starting_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 5, 9, 37))
      # IMCCE: 2025-03-14T05:09:36Z (U1)
      expect(eclipse.total.starting_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 6, 26, 1))
      # IMCCE: 2025-03-14T06:26:02Z (U2)
      expect(eclipse.total.ending_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 7, 31, 32))
      # IMCCE: 2025-03-14T07:31:30Z (U3)
      expect(eclipse.partial.ending_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 8, 47, 55))
      # IMCCE: 2025-03-14T08:47:55Z (U4)
      expect(eclipse.penumbral.ending_instant.to_time.round)
        .to eq(Time.utc(2025, 3, 14, 10, 0, 8))
      # IMCCE: 2025-03-14T10:00:09Z (P2)
    end

    it "finds the 2025-09-07 total lunar eclipse" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2025, 8, 1),
        Time.utc(2025, 10, 1)
      )

      expect(events.size).to eq(1)
      eclipse = events.first
      expect(eclipse).to be_total
      expect(eclipse.instant.to_time.round)
        .to eq(Time.utc(2025, 9, 7, 18, 11, 49))
      # IMCCE: 2025-09-07T18:11:49Z
      expect(eclipse.umbral_magnitude.round(5)).to eq(1.36248)
      # IMCCE: 1.36214
    end

    it "finds and classifies the 2024-09-18 partial lunar eclipse" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2024, 9, 1),
        Time.utc(2024, 10, 1)
      )

      expect(events.size).to eq(1)
      eclipse = events.first
      expect(eclipse).to be_partial
      expect(eclipse.total).to be_nil
      expect(eclipse.partial).not_to be_nil
      expect(eclipse.instant.to_time.round)
        .to eq(Time.utc(2024, 9, 18, 2, 44, 17))
      # IMCCE: 2024-09-18T02:44:16Z
      expect(eclipse.umbral_magnitude.round(5)).to eq(0.08517)
      # IMCCE: 0.08519
    end

    it "finds the 2023-05-05 penumbral lunar eclipse" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2023, 4, 15),
        Time.utc(2023, 5, 15)
      )

      expect(events.size).to eq(1)
      eclipse = events.first
      expect(eclipse).to be_penumbral
      expect(eclipse.partial).to be_nil
      expect(eclipse.total).to be_nil
      expect(eclipse.instant.to_time.round)
        .to eq(Time.utc(2023, 5, 5, 17, 23, 1))
      # IMCCE: 2023-05-05T17:22:55Z
      expect(eclipse.penumbral_magnitude.round(5)).to eq(0.96371)
      # IMCCE: 0.9635
    end

    it "finds and classifies every lunar eclipse between 2023 and 2025" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2023, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(events.map { |event| [event.instant.to_time.utc.strftime("%Y-%m-%d"), event.kind] })
        .to eq(
          [
            ["2023-05-05", :penumbral],
            ["2023-10-28", :partial],
            ["2024-03-25", :penumbral],
            ["2024-09-18", :partial],
            ["2025-03-14", :total],
            ["2025-09-07", :total]
          ]
        )
      # IMCCE: 2023-05-05 PenumbralEclipse
      # IMCCE: 2023-10-28 PartialEclipse
      # IMCCE: 2024-03-25 PenumbralEclipse
      # IMCCE: 2024-09-18 PartialEclipse
      # IMCCE: 2025-03-14 TotalEclipse
      # IMCCE: 2025-09-07 TotalEclipse
    end

    it "returns an empty array when no eclipse occurs in the range" do
      ephem = test_ephem_inpop_2000_2050
      calculator = described_class.new(ephem: ephem)

      events = calculator.events_between(
        Time.utc(2025, 1, 1),
        Time.utc(2025, 2, 1)
      )

      expect(events).to be_empty
    end
  end
end
