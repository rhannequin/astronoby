# frozen_string_literal: true

RSpec.describe Astronoby::EclipsePhase do
  describe "#duration" do
    it "returns the duration between the boundary instants" do
      phase = described_class.new(
        starting_instant: Astronoby::Instant.from_time(
          Time.utc(2025, 3, 14, 6, 26, 6)
        ),
        ending_instant: Astronoby::Instant.from_time(
          Time.utc(2025, 3, 14, 7, 31, 26)
        )
      )

      expect(phase.duration).to eq(Astronoby::Duration.from_seconds(3920))
    end

    it "rounds the duration to the nearest second" do
      phase = described_class.new(
        starting_instant: Astronoby::Instant.from_time(
          Time.utc(2025, 3, 14, 6, 0, 0)
        ),
        ending_instant: Astronoby::Instant.from_time(
          Time.utc(2025, 3, 14, 6, 0, 30, 400_000)
        )
      )

      expect(phase.duration.seconds).to eq(30)
    end
  end

  it "exposes its boundary instants" do
    starting = Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 6, 26, 6))
    ending = Astronoby::Instant.from_time(Time.utc(2025, 3, 14, 7, 31, 26))
    phase = described_class.new(
      starting_instant: starting,
      ending_instant: ending
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
      )
    )

    expect(phase).to be_frozen
  end
end
