# frozen_string_literal: true

RSpec.describe Astronoby::TrueObliquity do
  describe "::for_epoch" do
    it "returns an angle" do
      obliquity = described_class.for_epoch(Astronoby::Epoch::J2000).value

      expect(obliquity).to be_kind_of(Astronoby::Angle)
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 22 - Nutation and the Obliquity of the Ecliptic
    context "with real life arguments (book example)" do
      it "computes properly" do
        epoch = Astronoby::Epoch.from_time(Time.utc(1987, 4, 10, 0, 0, 0))
        obliquity = described_class.for_epoch(epoch).value

        expect(obliquity.to_degrees.to_dms.format).to(
          eq("+23° 26′ 36.8401″")
        )
      end
    end
  end
end
