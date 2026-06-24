# frozen_string_literal: true

RSpec.describe Astronoby::LunarEclipse do
  def phase_at(starting, ending)
    Astronoby::EclipsePhase.new(
      starting_instant: Astronoby::Instant.from_time(starting),
      ending_instant: Astronoby::Instant.from_time(ending)
    )
  end

  describe "#instant" do
    it "is aliased as #greatest_eclipse" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 58, 43))
      eclipse = Astronoby::LunarEclipse.new(
        instant: instant,
        kind: :total,
        umbral_magnitude: 1.178,
        penumbral_magnitude: 2.261,
        gamma: 0.348,
        shadow_axis_distance: Astronoby::Distance.from_kilometers(2219.6),
        penumbral: phase_at(
          Time.utc(2025, 3, 14, 3, 57),
          Time.utc(2025, 3, 14, 10, 0)
        )
      )

      expect(eclipse.greatest_eclipse).to eq(instant)
      expect(eclipse.greatest_eclipse).to eq(eclipse.instant)
    end
  end

  describe "#shadow_axis_distance" do
    it "exposes the axis distance as a Distance, the dimensional form of gamma" do
      eclipse = Astronoby::LunarEclipse.new(
        instant: Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 58, 43)),
        kind: :total,
        umbral_magnitude: 1.178,
        penumbral_magnitude: 2.261,
        gamma: 0.348,
        shadow_axis_distance: Astronoby::Distance.from_kilometers(2219.6),
        penumbral: phase_at(
          Time.utc(2025, 3, 14, 3, 57),
          Time.utc(2025, 3, 14, 10, 0)
        )
      )

      expect(eclipse.shadow_axis_distance)
        .to eq(Astronoby::Distance.from_kilometers(2219.6))
    end
  end

  describe "predicates" do
    it "is total and exposes the total phase" do
      eclipse = Astronoby::LunarEclipse.new(
        instant: Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 58, 43)),
        kind: :total,
        umbral_magnitude: 1.178,
        penumbral_magnitude: 2.261,
        gamma: 0.348,
        shadow_axis_distance: Astronoby::Distance.from_kilometers(2219.6),
        penumbral: phase_at(
          Time.utc(2025, 3, 14, 3, 57),
          Time.utc(2025, 3, 14, 10, 0)
        ),
        partial: phase_at(
          Time.utc(2025, 3, 14, 5, 9),
          Time.utc(2025, 3, 14, 8, 47)
        ),
        total: phase_at(
          Time.utc(2025, 3, 14, 6, 26),
          Time.utc(2025, 3, 14, 7, 31)
        )
      )

      expect(eclipse).to be_total
      expect(eclipse).not_to be_partial
      expect(eclipse).not_to be_penumbral
      expect(eclipse.total).not_to be_nil
      expect(eclipse.partial).not_to be_nil
    end

    it "is penumbral with no partial or total phase" do
      eclipse = Astronoby::LunarEclipse.new(
        instant: Astronoby::Instant.from_time(Time.utc(2024, 3, 25, 7, 12, 45)),
        kind: :penumbral,
        umbral_magnitude: -0.13,
        penumbral_magnitude: 0.956,
        gamma: 1.072,
        shadow_axis_distance: Astronoby::Distance.from_kilometers(6837.4),
        penumbral: phase_at(
          Time.utc(2024, 3, 25, 4, 53),
          Time.utc(2024, 3, 25, 9, 32)
        )
      )

      expect(eclipse).to be_penumbral
      expect(eclipse.partial).to be_nil
      expect(eclipse.total).to be_nil
    end
  end

  it "is immutable" do
    eclipse = Astronoby::LunarEclipse.new(
      instant: Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 58, 43)),
      kind: :total,
      umbral_magnitude: 1.178,
      penumbral_magnitude: 2.261,
      gamma: 0.348,
      shadow_axis_distance: Astronoby::Distance.from_kilometers(2219.6),
      penumbral: phase_at(
        Time.utc(2025, 3, 14, 3, 57),
        Time.utc(2025, 3, 14, 10, 0)
      )
    )

    expect(eclipse).to be_frozen
  end
end
