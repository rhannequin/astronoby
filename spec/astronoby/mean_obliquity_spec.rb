# frozen_string_literal: true

RSpec.describe Astronoby::MeanObliquity do
  describe "::at" do
    it "returns an angle" do
      instant = Astronoby::Instant
        .from_terrestrial_time(Astronoby::JulianDate::J2000)
      obliquity = described_class.at(instant)

      expect(obliquity).to be_kind_of(Astronoby::Angle)
    end

    it "returns the obliquity angle for standard epoch" do
      instant = Astronoby::Instant
        .from_terrestrial_time(Astronoby::JulianDate::J2000)
      obliquity = described_class.at(instant)

      expect(obliquity.degrees).to eq(23.439279444444445)
    end

    it "returns the obliquity angle for epoch 1950" do
      instant = Astronoby::Instant
        .from_terrestrial_time(Astronoby::JulianDate::J1950)
      obliquity = described_class.at(instant)

      expect(obliquity.degrees).to eq 23.445784468962604
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 27 - Ecliptic to equatorial coordinate conversion
    context "with real life arguments (book example)" do
      it "computes properly" do
        instant = Astronoby::Instant.from_time(Time.utc(2009, 7, 6, 0, 0, 0))
        obliquity = described_class.at(instant)

        expect(obliquity.str(:dms)).to eq "+23° 26′ 16.9518″"
      end
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

        expect(obliquity.str(:dms)).to eq "+23° 26′ 27.3681″"
      end
    end
  end
end
