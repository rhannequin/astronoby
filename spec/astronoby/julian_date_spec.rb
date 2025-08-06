# frozen_string_literal: true

RSpec.describe Astronoby::JulianDate do
  describe "::from_time" do
    # Source: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
    it "returns the Julian date associated with the time" do
      time = Time.utc(1582, 10, 15, 0, 0, 0)

      expect(described_class.from_time(time)).to eq(2299160.5)
    end

    # Source: https://github.com/observerly/polaris
    it "returns the Julian date associated with the time" do
      time = Time.utc(2021, 5, 14, 0, 0, 0)

      expect(described_class.from_time(time)).to eq(2459348.5)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the Julian date associated with the time" do
      time = Time.utc(2010, 11, 1, 0, 0, 0)

      expect(described_class.from_time(time)).to eq(2455501.5)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the Julian date associated with the time" do
      time = Time.utc(2015, 5, 10, 6, 0, 0)

      expect(described_class.from_time(time)).to eq(2457152.75)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the Julian date associated with the time" do
      time = Time.utc(2015, 5, 10, 18, 0, 0)

      expect(described_class.from_time(time)).to eq(2457153.25)
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 7 - Julian Day
    [
      [Time.utc(2000, 1, 1, 12), 2451545],
      [Date.new(1999, 1, 1), 2451179.5],
      [DateTime.new(1987, 6, 19, 12), 2446966],
      [Date.new(1988, 1, 27), 2447187.5],
      [Time.utc(1988, 6, 19, 12), 2447332],
      [Date.new(1900, 1, 1), 2415020.5],
      [Date.new(1600, 1, 1), 2305447.5],
      [Date.new(1600, 12, 31), 2305812.5],
      [Date.new(837, 4, 10), 2026871.5],
      [Date.new(-123, 12, 31), 1676496.5],
      [Date.new(-122, 1, 1), 1676497.5],
      [DateTime.new(-1000, 7, 12, 12), 1356001],
      [Date.new(-1000, 2, 29), 1355866.5],
      [DateTime.new(-1001, 8, 17, 21, 36), 1355671.4],
      [DateTime.new(-4712, 1, 1, 12), 0]
    ].each do |time_or_date, expected|
      it "returns the Julian date associated with the time" do
        expect(described_class.from_time(time_or_date)).to eq(expected)
      end
    end
  end

  describe "::from_julian_year" do
    it "returns the Julian date corresponding to a given Julian year" do
      julian_year = 2000
      expected_date = 2451545.0

      expect(described_class.from_julian_year(julian_year)).to eq(expected_date)
    end

    it "returns the Julian date corresponding to a given Julian year" do
      julian_year = 1950
      expected_date = 2433282.5

      expect(described_class.from_julian_year(julian_year)).to eq(expected_date)
    end

    it "returns the Julian date corresponding to a given Julian year" do
      julian_year = 1999.9
      expected_date = 2451508.475

      expect(described_class.from_julian_year(julian_year)).to eq(expected_date)
    end

    it "returns the Julian date corresponding to a given Julian year" do
      julian_year = 1987.5
      expected_date = 2446979.375

      expect(described_class.from_julian_year(julian_year)).to eq(expected_date)
    end
  end

  describe "::from_besselian_year" do
    it "returns the Julian date corresponding to a given Besselian year" do
      besselian_year = 1900
      expected_date = 2415020.31352

      expect(described_class.from_besselian_year(besselian_year))
        .to eq(expected_date)
    end

    it "returns the Julian date corresponding to a given Besselian year" do
      besselian_year = 1950
      expected_date = 2433282.42345905

      expect(described_class.from_besselian_year(besselian_year))
        .to eq(expected_date)
    end

    it "returns the Julian date corresponding to a given Besselian year" do
      besselian_year = 1875
      expected_date = 2405889.258550475

      expect(described_class.from_besselian_year(besselian_year))
        .to eq(expected_date)
    end

    it "returns the Julian date corresponding to a given Besselian year" do
      besselian_year = 2000.1
      expected_date = 2451581.0576179777

      expect(described_class.from_besselian_year(besselian_year))
        .to eq(expected_date)
    end
  end
end
