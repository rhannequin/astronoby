# frozen_string_literal: true

RSpec.describe Astronoby::EquinoxSolstice do
  describe ".new" do
    it "raises an error if the event is not supported" do
      expect { described_class.new(2024, 4) }.to(
        raise_error(
          Astronoby::UnsupportedEventError,
          "Expected a format between 0, 1, 2, 3, got 4"
        )
      )
    end
  end

  describe "::march_equinox" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "it returns the time for the 2004 March equinox" do
      year = 2004

      equinox = described_class.march_equinox(year)

      expect(equinox).to eq Time.utc(2004, 3, 20, 6, 47, 17)
      # Time from Celestial Calculations: 2004-03-20T06:42:36
      # Time from Astronomical Algorithms: 2004-03-20T06:49:42
      # Time from IMCCE: 2004-03-20T06:48:38
    end

    it "it returns the time for the 2024 March equinox" do
      year = 2024

      equinox = described_class.march_equinox(year)

      expect(equinox).to eq Time.utc(2024, 3, 20, 3, 5, 0)
      # Time from IMCCE: 2024-03-20T03:06:24
    end
  end

  describe "::june_solstice" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "it returns the time for the 2004 June solstice" do
      year = 2004

      equinox = described_class.june_solstice(year)

      expect(equinox).to eq Time.utc(2004, 6, 21, 0, 54, 25)
      # Time from Celestial Calculations: 2004-03-21T00:49:41
      # Time from Astronomical Algorithms: 2004-03-21T00:57:57
      # Time from IMCCE: 2004-06-21T00:56:52
    end

    it "it returns the time for the 2024 June solstice" do
      year = 2024

      equinox = described_class.june_solstice(year)

      expect(equinox).to eq Time.utc(2024, 6, 20, 20, 50, 14)
      # Time from IMCCE: 2024-06-20T20:51:00
    end
  end

  describe "::september_equinox" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "it returns the time for the 2024 September equinox" do
      year = 2004

      equinox = described_class.september_equinox(year)

      expect(equinox).to eq Time.utc(2004, 9, 22, 16, 31, 21)
      # Time from Celestial Calculations: 2004-09-22T16:30:54
      # Time from Astronomical Algorithms: 2004-09-22T16:27:20
      # Time from IMCCE: 2004-09-22T16:29:50
    end

    it "it returns the time for the 2024 September equinox" do
      year = 2024

      equinox = described_class.september_equinox(year)

      expect(equinox).to eq Time.utc(2024, 9, 22, 12, 38, 28)
      # Time from IMCCE: 2024-09-22T12:43:40
    end
  end

  describe "::december_solstice" do
    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 6 - The Sun
    it "it returns the time for the 2024 December solstice" do
      year = 2004

      equinox = described_class.december_solstice(year)

      expect(equinox).to eq Time.utc(2004, 12, 21, 12, 47, 45)
      # Time from Celestial Calculations: 2004-12-21T12:44:22
      # Time from Astronomical Algorithms: 2004-12-21T12:42:40
      # Time from IMCCE: 2004-12-21T12:41:36
    end

    it "it returns the time for the 2024 December solstice" do
      year = 2024

      equinox = described_class.december_solstice(year)

      expect(equinox).to eq Time.utc(2024, 12, 21, 9, 15, 22)
      # Time from IMCCE: 2024-12-21T09:20:34
    end
  end
end
