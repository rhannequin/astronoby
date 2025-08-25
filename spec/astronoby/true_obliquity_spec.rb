# frozen_string_literal: true

RSpec.describe Astronoby::TrueObliquity do
  describe "::at" do
    it "returns an angle" do
      instant = Astronoby::Instant
        .from_terrestrial_time(Astronoby::JulianDate::J2000)
      obliquity = described_class.at(instant)

      expect(obliquity).to be_kind_of(Astronoby::Angle)
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 22 - Nutation and the Obliquity of the Ecliptic
    context "with real life arguments (book example)" do
      it "computes properly" do
        instant = Astronoby::Instant.from_time(Time.utc(1987, 4, 10, 0, 0, 0))
        obliquity = described_class.at(instant)

        expect(obliquity.str(:dms)).to eq "+23° 26′ 36.8137″"
      end
    end
  end
end
