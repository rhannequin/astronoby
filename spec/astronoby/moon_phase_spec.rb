# frozen_string_literal: true

RSpec.describe Astronoby::MoonPhase do
  it "derives the time from the instant, rounded to the second" do
    instant = Astronoby::Instant.from_time(Time.utc(2025, 1, 13, 22, 26, 55.4))

    phase = described_class.new(instant: instant, phase: :full_moon)

    expect(phase.time).to eq(Time.utc(2025, 1, 13, 22, 26, 55))
    expect(phase.instant).to be(instant)
  end

  it "derives the instant from the time" do
    time = Time.utc(2025, 1, 13, 22, 26, 56)

    phase = described_class.full_moon(time)

    expect(phase.instant.to_time).to eq(time)
  end
end
