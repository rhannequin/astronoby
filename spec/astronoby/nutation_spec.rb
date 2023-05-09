# frozen_string_literal: true

RSpec.describe Astronoby::Nutation do
  describe "::for_ecliptic_longitude" do
    it "returns an angle in degrees" do
      initial_longitude = Astronoby::Angle.as_degrees(20)
      new_longitude = described_class.for_ecliptic_longitude(
        initial_longitude,
        epoch: Astronoby::Epoch::J2000
      )

      expect(new_longitude).to be_a(Astronoby::Degree)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 35 - Nutation
    it "returns the new longitude with nutation" do
      initial_longitude = Astronoby::Angle.as_degrees(20)
      new_longitude = described_class.for_ecliptic_longitude(
        initial_longitude,
        epoch: Astronoby::Epoch.from_time(Time.utc(1988, 9, 1, 0, 0, 0))
      )

      expect(new_longitude.to_degrees.to_dms.format).to(
        eq("+20° 0′ 5.4929″")
      )
    end
  end

  describe "::for_obliquity_of_the_ecliptic" do
    it "returns an angle in degrees" do
      initial_longitude = Astronoby::Angle.as_degrees(20)
      new_longitude = described_class.for_obliquity_of_the_ecliptic(
        initial_longitude,
        epoch: Astronoby::Epoch::J2000
      )

      expect(new_longitude).to be_a(Astronoby::Degree)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 35 - Nutation
    it "returns the new obliquity with nutation" do
      initial_obliquity = Astronoby::Angle.as_degrees(23)
      new_obliquity = described_class.for_obliquity_of_the_ecliptic(
        initial_obliquity,
        epoch: Astronoby::Epoch.from_time(Time.utc(1988, 9, 1, 0, 0, 0))
      )

      expect(new_obliquity.to_degrees.to_dms.format).to(
        eq("+23° 0′ 9.2415″")
      )
    end
  end

  describe "#for_ecliptic_longitude" do
    it "returns an angle in degrees" do
      epoch = Astronoby::Epoch::J2000
      nutation = described_class.new(epoch).for_ecliptic_longitude

      expect(nutation).to be_a(Astronoby::Degree)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 35 - Nutation
    it "returns the new longitude with nutation" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1988, 9, 1, 0, 0, 0))
      nutation = described_class.new(epoch).for_ecliptic_longitude

      expect(nutation.to_degrees.to_dms.format).to(
        eq("+0° 0′ 5.4929″")
      )
    end
  end

  describe "#for_obliquity_of_the_ecliptic" do
    it "returns an angle in degrees" do
      epoch = Astronoby::Epoch::J2000
      nutation = described_class.new(epoch).for_obliquity_of_the_ecliptic

      expect(nutation).to be_a(Astronoby::Degree)
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 35 - Nutation
    it "returns the new longitude with nutation" do
      epoch = Astronoby::Epoch.from_time(Time.utc(1988, 9, 1, 0, 0, 0))
      nutation = described_class.new(epoch).for_obliquity_of_the_ecliptic

      expect(nutation.to_degrees.to_dms.format).to(
        eq("+0° 0′ 9.2415″")
      )
    end
  end
end
