# frozen_string_literal: true

RSpec.describe Astronoby::MeanObliquity do
  describe "::for_epoch" do
    it "returns an angle" do
      obliquity = described_class.for_epoch(Astronoby::Epoch::J2000)

      expect(obliquity).to be_kind_of(Astronoby::Angle)
    end

    it "returns the obliquity angle for standard epoch" do
      obliquity = described_class.for_epoch(Astronoby::Epoch::J2000)

      expect(obliquity.degrees.to_f).to eq(23.439291666666666)
    end

    it "returns the obliquity angle for epoch 1950" do
      obliquity = described_class.for_epoch(Astronoby::Epoch::J1950)

      expect(obliquity.degrees.to_f).to eq 23.445793854513887
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 27 - Ecliptic to equatorial coordinate conversion
    context "with real life arguments (book example)" do
      it "computes properly" do
        epoch = Astronoby::Epoch.from_time(Time.utc(2009, 7, 6, 0, 0, 0))
        obliquity = described_class.for_epoch(epoch)

        expect(obliquity.str(:dms)).to eq "+23° 26′ 16.9979″"
      end
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 22 - Nutation and the Obliquity of the Ecliptic
    context "with real life arguments (book example)" do
      it "computes properly" do
        epoch = Astronoby::Epoch.from_time(Time.utc(1987, 4, 10, 0, 0, 0))
        obliquity = described_class.for_epoch(epoch)

        expect(obliquity.str(:dms)).to eq "+23° 26′ 27.4093″"
      end
    end
  end
end
