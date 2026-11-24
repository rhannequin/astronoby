# frozen_string_literal: true

RSpec.describe Astronoby::Coordinates::Horizontal do
  describe "#refracted?" do
    it "is false by default" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      horizontal = described_class.new(
        azimuth: Astronoby::Angle.from_degrees(100),
        altitude: Astronoby::Angle.from_degrees(10),
        observer: observer
      )

      expect(horizontal.refracted?).to be false
    end
  end

  describe "#refract" do
    it "adds the refraction to the altitude" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      altitude = Astronoby::Angle.from_degrees(10)
      horizontal = described_class.new(
        azimuth: Astronoby::Angle.from_degrees(100),
        altitude: altitude,
        observer: observer
      )

      refracted = horizontal.refract

      expect(refracted.altitude).to eq(
        altitude +
          Astronoby::Refraction.angle(altitude: altitude, observer: observer)
      )
    end

    it "keeps the azimuth and the observer" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      azimuth = Astronoby::Angle.from_degrees(100)
      horizontal = described_class.new(
        azimuth: azimuth,
        altitude: Astronoby::Angle.from_degrees(10),
        observer: observer
      )

      refracted = horizontal.refract

      aggregate_failures do
        expect(refracted.azimuth).to eq azimuth
        expect(refracted.observer).to eq observer
      end
    end

    it "returns refracted coordinates" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      horizontal = described_class.new(
        azimuth: Astronoby::Angle.from_degrees(100),
        altitude: Astronoby::Angle.from_degrees(10),
        observer: observer
      )

      expect(horizontal.refract.refracted?).to be true
    end

    it "raises an error when the coordinates are already refracted" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      horizontal = described_class.new(
        azimuth: Astronoby::Angle.from_degrees(100),
        altitude: Astronoby::Angle.from_degrees(10),
        observer: observer,
        refracted: true
      )

      expect { horizontal.refract }.to raise_error(
        Astronoby::IncompatibleArgumentsError,
        "The horizontal coordinates are already refracted"
      )
    end
  end
end
