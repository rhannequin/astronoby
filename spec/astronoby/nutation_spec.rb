# frozen_string_literal: true

RSpec.describe Astronoby::Nutation do
  describe "::for_ecliptic_longitude" do
    it "returns an Angle object" do
      nutation = described_class.for_ecliptic_longitude(
        epoch: Astronoby::Epoch::J2000
      )

      expect(nutation).to be_a(Astronoby::Angle)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 35 - Nutation
    it "returns the nutation angle" do
      nutation = described_class.for_ecliptic_longitude(
        epoch: Astronoby::Epoch.from_time(Time.utc(1988, 9, 1, 0, 0, 0))
      )

      expect(nutation.str(:dms)).to eq "+0° 0′ 5.4929″"
    end
  end

  describe "::for_obliquity_of_the_ecliptic" do
    it "returns an Angle object" do
      nutation = described_class.for_obliquity_of_the_ecliptic(
        epoch: Astronoby::Epoch::J2000
      )

      expect(nutation).to be_a(Astronoby::Angle)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 35 - Nutation
    it "returns the nutation angle" do
      nutation = described_class.for_obliquity_of_the_ecliptic(
        epoch: Astronoby::Epoch.from_time(Time.utc(1988, 9, 1, 0, 0, 0))
      )

      expect(nutation.str(:dms)).to eq "+0° 0′ 9.2415″"
    end
  end
end
