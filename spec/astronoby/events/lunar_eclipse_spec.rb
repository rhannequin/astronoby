# frozen_string_literal: true

RSpec.describe Astronoby::LunarEclipse do
  def phase_at(starting, ending)
    Astronoby::LunarEclipsePhase.new(
      starting_instant: Astronoby::Instant.from_time(starting),
      ending_instant: Astronoby::Instant.from_time(ending),
      starting_geometry: geometry,
      ending_geometry: geometry
    )
  end

  def geometry(north_of_axis: true)
    Astronoby::LunarEclipseGeometry.new(
      axis_distance: Astronoby::Distance.from_kilometers(2219.6),
      position_angle: Astronoby::Angle.from_degrees(208.2),
      umbra_radius: Astronoby::Distance.from_kilometers(4664.4),
      penumbra_radius: Astronoby::Distance.from_kilometers(8254.0),
      moon_distance: Astronoby::Distance.from_kilometers(382601.0),
      moon_coordinates: Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(11, 38, 22.98),
        declination: Astronoby::Angle.from_dms(2, 40, 54.72)
      ),
      north_of_axis: north_of_axis
    )
  end

  describe "#instant" do
    it "is aliased as #greatest_eclipse_instant" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 58, 43))
      eclipse = Astronoby::LunarEclipse.new(
        instant: instant,
        kind: :total,
        geometry: geometry,
        penumbral: phase_at(
          Time.utc(2025, 3, 14, 3, 57),
          Time.utc(2025, 3, 14, 10, 0)
        )
      )

      expect(eclipse.greatest_eclipse_instant).to eq(instant)
      expect(eclipse.greatest_eclipse_instant).to eq(eclipse.instant)
    end
  end

  describe "#shadow_axis_distance" do
    it "exposes the axis distance as a Distance, the dimensional form of gamma" do
      eclipse = Astronoby::LunarEclipse.new(
        instant: Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 58, 43)),
        kind: :total,
        geometry: geometry,
        penumbral: phase_at(
          Time.utc(2025, 3, 14, 3, 57),
          Time.utc(2025, 3, 14, 10, 0)
        )
      )

      expect(eclipse.shadow_axis_distance)
        .to eq(Astronoby::Distance.from_kilometers(2219.6))
    end
  end

  describe "#gamma" do
    it "is the axis distance in Earth radii, signed by the side of the axis" do
      northern = Astronoby::LunarEclipse.new(
        instant: Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 58, 43)),
        kind: :total,
        geometry: geometry(north_of_axis: true),
        penumbral: phase_at(
          Time.utc(2025, 3, 14, 3, 57),
          Time.utc(2025, 3, 14, 10, 0)
        )
      )
      southern = Astronoby::LunarEclipse.new(
        instant: Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 58, 43)),
        kind: :total,
        geometry: geometry(north_of_axis: false),
        penumbral: phase_at(
          Time.utc(2025, 3, 14, 3, 57),
          Time.utc(2025, 3, 14, 10, 0)
        )
      )

      earth_radii = 2219.6 * 1000 /
        Astronoby::Constants::WGS84_EARTH_EQUATORIAL_RADIUS_IN_METERS.to_f

      expect(northern.gamma).to be_within(1e-12).of(earth_radii)
      expect(southern.gamma).to be_within(1e-12).of(-earth_radii)
    end
  end

  describe "magnitudes" do
    it "comes from the geometry, so the two cannot disagree" do
      eclipse = Astronoby::LunarEclipse.new(
        instant: Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 58, 43)),
        kind: :total,
        geometry: geometry,
        penumbral: phase_at(
          Time.utc(2025, 3, 14, 3, 57),
          Time.utc(2025, 3, 14, 10, 0)
        )
      )

      expect(eclipse.umbral_magnitude).to eq(geometry.umbral_magnitude)
      expect(eclipse.penumbral_magnitude).to eq(geometry.penumbral_magnitude)
      expect(eclipse.shadow_axis_distance).to eq(geometry.axis_distance)
    end
  end

  describe "predicates" do
    it "is total and exposes the total phase" do
      eclipse = Astronoby::LunarEclipse.new(
        instant: Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 58, 43)),
        kind: :total,
        geometry: geometry,
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
        geometry: geometry,
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
      geometry: geometry,
      penumbral: phase_at(
        Time.utc(2025, 3, 14, 3, 57),
        Time.utc(2025, 3, 14, 10, 0)
      )
    )

    expect(eclipse).to be_frozen
  end
end
