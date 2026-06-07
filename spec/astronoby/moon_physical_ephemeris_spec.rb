# frozen_string_literal: true

RSpec.describe Astronoby::MoonPhysicalEphemeris do
  include TestEphemHelper

  describe "#libration" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 53 - Ephemeris for Physical Observations of the Moon
    #  Example: 53.a, 1992 April 12, at 0h TD
    it "reproduces Meeus's worked example" do
      instant = Astronoby::Instant.from_terrestrial_time(
        Astronoby::JulianDate.from_time(Time.utc(1992, 4, 12))
      )
      moon = Astronoby::Moon.new(instant: instant, ephem: test_ephem_inpop_full)

      libration = described_class.new(moon).libration

      aggregate_failures do
        expect(libration.longitude.degrees.round(2)).to eq(-1.23)
        # Meeus:    -1.23°
        # Horizons: -1.232°
        # IMCCE:    -1.33°

        expect(libration.latitude.degrees.round(2)).to eq(4.20)
        # Meeus:    +4.20°
        # Horizons: +4.175°
        # IMCCE:    +4.17°
      end
    end
  end

  describe "#position_angle_of_axis" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 53 - Ephemeris for Physical Observations of the Moon
    #  Example: 53.a, 1992 April 12, at 0h TD
    it "reproduces Meeus's worked example" do
      instant = Astronoby::Instant.from_terrestrial_time(
        Astronoby::JulianDate.from_time(Time.utc(1992, 4, 12))
      )
      moon = Astronoby::Moon.new(instant: instant, ephem: test_ephem_inpop_full)

      position_angle = described_class.new(moon).position_angle_of_axis

      expect(position_angle.degrees.round(2)).to eq(15.08)
      # Meeus:    15.08°
      # Horizons: 15.086°
      # IMCCE:    15.09°
    end
  end
end
