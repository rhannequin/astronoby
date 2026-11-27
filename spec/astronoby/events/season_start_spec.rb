# frozen_string_literal: true

RSpec.describe Astronoby::SeasonStart do
  it "is an equinox in March and September" do
    instant = Astronoby::Instant.from_time(Time.utc(2025, 3, 20))

    march = described_class.new(instant: instant, kind: :march_equinox)
    september = described_class.new(instant: instant, kind: :september_equinox)

    expect([march, september]).to all(be_equinox)
    expect([march, september]).not_to include(be_solstice)
  end

  it "is a solstice in June and December" do
    instant = Astronoby::Instant.from_time(Time.utc(2025, 6, 21))

    june = described_class.new(instant: instant, kind: :june_solstice)
    december = described_class.new(instant: instant, kind: :december_solstice)

    expect([june, december]).to all(be_solstice)
    expect([june, december]).not_to include(be_equinox)
  end
end
