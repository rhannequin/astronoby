# frozen_string_literal: true

RSpec.describe Astronoby::Moon do
  describe "#apparent_ecliptic_coordinates" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 47 - Position of the Moon, p.342
    it "returns the apparent ecliptic coordinates for 1992-04-12" do
      # Example gives 1992-04-12 00:00:00 TT (and not UTC)
      time = Time.utc(1992, 4, 12, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      moon = described_class.new(time: time)

      coordinates = moon.apparent_ecliptic_coordinates

      expect(coordinates.latitude.str(:dms)).to eq "-3° 13′ 44.8543″"
      # Result from the book: -3° 13′ 45″
      # Result from IMCCE: -3° 13′ 44.184″

      expect(coordinates.longitude.str(:dms)).to eq "+133° 10′ 1.834″"
      # Result from the book: 133° 10′ 02″
      # Result from IMCCE: 133° 10′ 0.157″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.166
    it "returns the apparent ecliptic coordinates for 2015-01-01" do
      moon = described_class.new(time: Time.new(2015, 1, 1, 22, 0, 0, "-05:00"))

      coordinates = moon.apparent_ecliptic_coordinates

      expect(coordinates.latitude.str(:dms)).to eq "-3° 50′ 46.0007″"
      # Result from the book: -3° 57′ 22.5179″ (-3.956255°)
      # Result from IMCCE: -3° 50′ 55.417″

      expect(coordinates.longitude.str(:dms)).to eq "+65° 21′ 5.9223″"
      # Result from the book: +65° 3′ 35.3304″ (65.059814°)
      # Result from IMCCE: +65° 21′ 3.629″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent ecliptic coordinates for 2000-08-09" do
      moon = described_class.new(time: Time.new(2000, 8, 9, 12, 0, 0, "-05:00"))

      coordinates = moon.apparent_ecliptic_coordinates

      expect(coordinates.latitude.str(:dms)).to eq "+3° 11′ 22.0683″"
      # Result from the book: +3° 2′ 40.2″ (3.0445°)
      # Result from IMCCE: +3° 11′ 25.819″

      expect(coordinates.longitude.str(:dms)).to eq "+257° 17′ 32.7597″"
      # Result from the book: +257° 13′ 11.784″ (257.21994°)
      # Result from IMCCE: +257° 17′ 32.387″
    end

    # Source:
    #  Title: Celestial Calculations
    #  Author: J. L. Lawrence
    #  Edition: MIT Press
    #  Chapter: 7 - The Moon, p.185
    it "returns the apparent ecliptic coordinates for 2010-05-15" do
      moon = described_class.new(time: Time.new(2010, 5, 15, 14, 30, 0, "-04:00"))

      coordinates = moon.apparent_ecliptic_coordinates

      expect(coordinates.latitude.str(:dms)).to eq "+2° 16′ 12.4064″"
      # Result from the book: +2° 25′ 1.7975″ (2.417166°)
      # Result from IMCCE: +2° 16′ 15.434″

      expect(coordinates.longitude.str(:dms)).to eq "+76° 35′ 31.0243″"
      # Result from the book: +76° 24′ 58.8924″ (76.416359°)
      # Result from IMCCE: +76° 35′ 32.198″
    end

    # Source:
    #  Title: Practical Astronomy with your Calculator or Spreadsheet
    #  Authors: Peter Duffett-Smith and Jonathan Zwart
    #  Edition: Cambridge University Press
    #  Chapter: 65 - Calculating the Moon’s position, p.165
    it "returns the apparent ecliptic coordinates for 2003-09-01" do
      moon = described_class.new(time: Time.utc(2003, 9, 1))

      coordinates = moon.apparent_ecliptic_coordinates

      expect(coordinates.latitude.str(:dms)).to eq "+1° 37′ 12.7837″"
      # Result from the book: +1° 42′ 57.8664″ (1.716074°)
      # Result from IMCCE: +1° 37′ 9.680″

      expect(coordinates.longitude.str(:dms)).to eq "+214° 46′ 16.0171″"
      # Result from the book: +214° 52′ 3.0107″ (214.867503°)
      # Result from IMCCE: +214° 46′ 16.888″
    end
  end

  describe "#distance" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 47 - Position of the Moon, p.342
    it "returns the distance for 1992-04-12" do
      # Example gives 1992-04-12 00:00:00 TT (and not UTC)
      time = Time.utc(1992, 4, 12, 0, 0, 0)
      time -= Astronoby::Util::Time.terrestrial_universal_time_delta(time)
      moon = described_class.new(time: time)

      distance = moon.distance

      expect(distance).to eq 368409707
      # Result from the book: 368409700 (36849.7 km)
      # Result from IMCCE: 368439405 (0.002462865305 AU)
    end
  end
end
