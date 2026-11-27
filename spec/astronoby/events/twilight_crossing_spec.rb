# frozen_string_literal: true

RSpec.describe Astronoby::TwilightCrossing do
  it "is a dawn when the Sun rises through the altitude" do
    crossing = described_class.new(
      instant: Astronoby::Instant.from_time(Time.utc(2025, 10, 1, 5)),
      direction: :rising,
      kind: :civil
    )

    expect(crossing.kind).to eq(:civil)
    expect(crossing).to be_dawn
    expect(crossing).not_to be_dusk
  end

  it "is a dusk when the Sun sets through the altitude" do
    crossing = described_class.new(
      instant: Astronoby::Instant.from_time(Time.utc(2025, 10, 1, 18)),
      direction: :setting,
      kind: :nautical
    )

    expect(crossing).to be_dusk
    expect(crossing).not_to be_dawn
  end
end
