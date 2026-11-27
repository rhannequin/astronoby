# frozen_string_literal: true

RSpec.describe Astronoby::LeapSeconds do
  describe "::at" do
    it "returns TAI - UTC in seconds" do
      julian_date = Astronoby::JulianDate.from_time(Time.utc(2025, 1, 1))

      expect(described_class.at(julian_date)).to eq(37)
      # IERS Bulletin C: TAI - UTC = 37 s since 2017-01-01
    end

    it "changes at the leap second midnight" do
      midnight = Astronoby::JulianDate.from_time(Time.utc(2017, 1, 1))
      just_before = midnight - Rational(1, 86400)

      expect(described_class.at(just_before)).to eq(36)
      expect(described_class.at(midnight)).to eq(37)
    end

    it "returns a fraction of a second while UTC drifted, before 1972" do
      julian_date = Astronoby::JulianDate.from_time(Time.utc(1966, 6, 1))

      expect(described_class.at(julian_date).to_f)
        .to be_within(1e-9).of(4.704562)
      # IERS: 4.3131700 + (MJD - 39126) * 0.002592, MJD 39277
    end

    it "raises an error before 1961, when UTC did not run yet" do
      julian_date = Astronoby::JulianDate.from_time(Time.utc(1950, 1, 1))

      expect { described_class.at(julian_date) }
        .to raise_error(IERS::OutOfRangeError)
    end
  end
end
