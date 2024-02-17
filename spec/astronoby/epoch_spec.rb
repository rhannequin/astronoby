# frozen_string_literal: true

RSpec.describe Astronoby::Epoch do
  describe "::from_time" do
    # Source: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
    it "returns the Julian day number associated with the time" do
      time = Time.utc(1582, 10, 15, 0, 0, 0)

      expect(described_class.from_time(time)).to eq(2299160.5)
    end

    # Source: https://github.com/observerly/polaris
    it "returns the Julian day number associated with the time" do
      time = Time.utc(2021, 5, 14, 0, 0, 0)

      expect(described_class.from_time(time)).to eq(2459348.5)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the Julian day number associated with the time" do
      time = Time.utc(2010, 11, 1, 0, 0, 0)

      expect(described_class.from_time(time)).to eq(2455501.5)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the Julian day number associated with the time" do
      time = Time.utc(2015, 5, 10, 6, 0, 0)

      expect(described_class.from_time(time)).to eq(2457152.75)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the Julian day number associated with the time" do
      time = Time.utc(2015, 5, 10, 18, 0, 0)

      expect(described_class.from_time(time)).to eq(2457153.25)
    end
  end

  describe "::to_utc" do
    # Source: https://quasar.as.utexas.edu/BillInfo/JulianDatesG.html
    it "returns the UTC Time object corresponding to a given Julian day number" do
      epoch = 2299160.5

      time = described_class.to_utc(epoch)

      expect(time).to eq Time.utc(1582, 10, 15, 0, 0, 0)
    end

    # Source: https://github.com/observerly/polaris
    it "returns the UTC Time object corresponding to a given Julian day number" do
      epoch = 2459348.5

      time = described_class.to_utc(epoch)

      expect(time).to eq Time.utc(2021, 5, 14, 0, 0, 0)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the UTC Time object corresponding to a given Julian day number" do
      epoch = 2369915.5

      time = described_class.to_utc(epoch)

      expect(time).to eq Time.utc(1776, 7, 4, 0, 0, 0)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the UTC Time object corresponding to a given Julian day number" do
      epoch = 2455323

      time = described_class.to_utc(epoch)

      expect(time).to eq Time.utc(2010, 5, 6, 12, 0, 0)
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 3 - Time Conversions
    it "returns the UTC Time object corresponding to a given Julian day number" do
      epoch = 2456019.37

      time = described_class.to_utc(epoch).round

      expect(time).to eq Time.utc(2012, 4, 1, 20, 52, 48)
    end
  end
end
