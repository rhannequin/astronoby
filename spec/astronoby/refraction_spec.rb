# frozen_string_literal: true

RSpec.describe Astronoby::Refraction do
  describe "::angle" do
    it "returns an Angle" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      angle = described_class.angle(
        altitude: Astronoby::Angle.from_degrees(45),
        observer: observer
      )

      expect(angle).to be_a Astronoby::Angle
    end

    it "computes the refraction at the horizon" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      angle = described_class.angle(
        altitude: Astronoby::Angle.zero,
        observer: observer
      )

      expect(angle.str(:dms, precision: 2)).to eq "+0° 28′ 59.98″"
      # Skyfield: 28′ 59.75″
    end

    it "computes the refraction close to the horizon" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      angle = described_class.angle(
        altitude: Astronoby::Angle.from_degrees(1),
        observer: observer
      )

      expect(angle.str(:dms, precision: 2)).to eq "+0° 21′ 48.78″"
      # Skyfield: 21′ 48.60″
    end

    it "computes the refraction at low altitude" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      angle = described_class.angle(
        altitude: Astronoby::Angle.from_degrees(5),
        observer: observer
      )

      expect(angle.str(:dms, precision: 2)).to eq "+0° 9′ 39.63″"
      # Skyfield: 9′ 39.55″
    end

    it "computes the refraction at high altitude" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      angle = described_class.angle(
        altitude: Astronoby::Angle.from_degrees(45),
        observer: observer
      )

      expect(angle.str(:dms, precision: 2)).to eq "+0° 0′ 59.81″"
      # Skyfield: 59.81″
    end

    it "scales the refraction with the temperature and the pressure" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        temperature: Astronoby::Temperature.from_celsius(-15),
        pressure: Astronoby::Pressure.from_millibars(1030)
      )

      angle = described_class.angle(
        altitude: Astronoby::Angle.from_degrees(10),
        observer: observer
      )

      expect(angle.str(:dms, precision: 2)).to eq "+0° 5′ 58.3″"
      # Skyfield: 5′ 58.26″
    end

    it "scales the refraction the same for whole-number conditions" do
      whole_numbers = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        temperature: Astronoby::Temperature.from_kelvins(298),
        pressure: Astronoby::Pressure.from_millibars(990)
      )
      floats = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        temperature: Astronoby::Temperature.from_kelvins(298.0),
        pressure: Astronoby::Pressure.from_millibars(990.0)
      )
      altitude = Astronoby::Angle.from_degrees(10)

      expect(described_class.angle(altitude: altitude, observer: whole_numbers))
        .to eq described_class.angle(altitude: altitude, observer: floats)
    end

    it "computes no refraction without an atmosphere" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        pressure: Astronoby::Pressure.from_pascals(0)
      )

      angle = described_class.angle(
        altitude: Astronoby::Angle.from_degrees(10),
        observer: observer
      )

      expect(angle).to eq Astronoby::Angle.zero
    end

    it "puts the apparent horizon close to the true altitude of -34′" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      true_altitude = Astronoby::Horizon::REFRACTION_ANGLE

      apparent_altitude = true_altitude +
        described_class.angle(altitude: true_altitude, observer: observer)

      expect(apparent_altitude.degrees.abs)
        .to be < Astronoby::Angle.from_dms(0, 1, 0).degrees
    end

    it "keeps the refraction constant below the lowest altitude" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      at_limit = described_class.angle(
        altitude: described_class::LOWEST_ALTITUDE,
        observer: observer
      )
      below_limit = described_class.angle(
        altitude: Astronoby::Angle.from_degrees(-5),
        observer: observer
      )

      expect(below_limit).to eq at_limit
    end

    it "makes the apparent altitude grow with the true altitude" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      apparent_altitudes = (-50..50).map do |tenth_of_degree|
        true_altitude = Astronoby::Angle.from_degrees(tenth_of_degree / 10.0)
        true_altitude +
          described_class.angle(altitude: true_altitude, observer: observer)
      end

      expect(apparent_altitudes.each_cons(2).all? { |a, b| b > a }).to be true
    end
  end
end
