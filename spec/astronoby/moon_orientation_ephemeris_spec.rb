# frozen_string_literal: true

RSpec.describe Astronoby::MoonOrientationEphemeris do
  include TestEphemHelper

  describe "#libration" do
    it "returns the libration for 2025-03-01" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 3, 1))
      moon = Astronoby::Moon.new(
        instant: instant,
        ephem: test_ephem_moon,
        orientation: test_orientation
      )

      libration = described_class.new(moon).libration

      aggregate_failures do
        expect(libration.longitude.str(:dms))
          .to eq("-2° 4′ 44.4397″")
        # Horizons: -2° 4′ 44.4396″
        expect(libration.latitude.str(:dms))
          .to eq("+0° 27′ 27.7258″")
        # Horizons: +0° 27′ 27.7236″
      end
    end

    it "returns the libration for 2025-09-20" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 9, 20))
      moon = Astronoby::Moon.new(
        instant: instant,
        ephem: test_ephem_moon,
        orientation: test_orientation
      )

      libration = described_class.new(moon).libration

      aggregate_failures do
        expect(libration.longitude.str(:dms))
          .to eq("+5° 26′ 26.2678″")
        # Horizons: +5° 26′ 26.2644″
        expect(libration.latitude.str(:dms))
          .to eq("-1° 23′ 48.7966″")
        # Horizons: -1° 23′ 48.7896″
      end
    end
  end

  describe "#position_angle_of_axis" do
    it "returns the position angle of the axis for 2025-09-20" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 9, 20))
      moon = Astronoby::Moon.new(
        instant: instant,
        ephem: test_ephem_moon,
        orientation: test_orientation
      )

      position_angle = described_class.new(moon).position_angle_of_axis

      expect(position_angle.str(:dms))
        .to eq("+20° 11′ 15.8176″")
      # Horizons: +20° 11′ 15.72″
    end
  end
end
