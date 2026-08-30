# frozen_string_literal: true

RSpec.describe Astronoby::LunarEclipsePhase do
  def geometry
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
      north_of_axis: true
    )
  end

  describe "#duration" do
    it "returns the duration between the boundary instants" do
      phase = described_class.new(
        starting_instant: Astronoby::Instant.from_time(
          Time.utc(2025, 3, 14, 6, 26, 6)
        ),
        ending_instant: Astronoby::Instant.from_time(
          Time.utc(2025, 3, 14, 7, 31, 26)
        ),
        starting_geometry: geometry,
        ending_geometry: geometry
      )

      expect(phase.duration.seconds).to be_within(1e-3).of(3920)
    end

    it "keeps the fraction of a second between the boundary instants" do
      phase = described_class.new(
        starting_instant: Astronoby::Instant.from_time(
          Time.utc(2025, 3, 14, 6, 0, 0)
        ),
        ending_instant: Astronoby::Instant.from_time(
          Time.utc(2025, 3, 14, 6, 0, 30, 400_000)
        ),
        starting_geometry: geometry,
        ending_geometry: geometry
      )

      expect(phase.duration.seconds).to be_within(1e-3).of(30.4)
    end
  end

  it "exposes its boundary instants" do
    starting = Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 26, 6))
    ending = Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 7, 31, 26))
    phase = described_class.new(
      starting_instant: starting,
      ending_instant: ending,
      starting_geometry: geometry,
      ending_geometry: geometry
    )

    expect(phase.starting_instant).to eq(starting)
    expect(phase.ending_instant).to eq(ending)
  end

  it "is immutable" do
    phase = described_class.new(
      starting_instant: Astronoby::Instant.from_time(
        Time.utc(2025, 3, 14, 6, 26, 6)
      ),
      ending_instant: Astronoby::Instant.from_time(
        Time.utc(2025, 3, 14, 7, 31, 26)
      ),
      starting_geometry: geometry,
      ending_geometry: geometry
    )

    expect(phase).to be_frozen
  end
end
