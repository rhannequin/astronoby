# frozen_string_literal: true

RSpec.describe Astronoby::Obliquity do
  describe "::for_epoch" do
    it "returns an angle" do
      obliquity = described_class.for_epoch(Astronoby::Epoch::J2000).value

      expect(obliquity).to be_kind_of(Astronoby::Angle)
    end

    it "returns the obliquity angle for standard epoch" do
      obliquity = described_class.for_epoch(Astronoby::Epoch::J2000).value

      expect(obliquity.to_degrees.value).to eq(23.439279444444)
    end

    it "returns the obliquity angle for epoch 1950" do
      obliquity = described_class.for_epoch(Astronoby::Epoch::J1950).value

      expect(obliquity.to_degrees.value).to eq(23.44578463353696)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 27 - Ecliptic to equatorial coordinate conversion
    context "with real life arguments (book example)" do
      it "computes properly" do
        epoch = Astronoby::Epoch.from_time(Time.utc(2009, 7, 6, 0, 0, 0))
        obliquity = described_class.for_epoch(epoch).value

        expect(obliquity.to_degrees.to_dms.format).to(
          eq("+23° 26′ 16.9518″")
        )
      end
    end
  end
end
