# frozen_string_literal: true

RSpec.describe Astronoby::Airmass do
  describe "object immutability" do
    it "is frozen" do
      expect(described_class.new(1.5)).to be_frozen
    end
  end

  describe "validation" do
    it "raises an error for a value of zero" do
      expect { described_class.new(0) }.to raise_error(
        Astronoby::IncompatibleArgumentsError,
        "Expected a positive airmass, got 0"
      )
    end

    it "raises an error for a value that is not a number" do
      expect { described_class.new(nil) }.to raise_error(
        Astronoby::IncompatibleArgumentsError,
        "Expected a positive airmass, got nil"
      )
    end

    it "raises an error for a negative value" do
      expect { described_class.new(-1) }
        .to raise_error(Astronoby::IncompatibleArgumentsError)
    end
  end

  describe "::from_true_altitude" do
    it "returns 1 at the zenith" do
      airmass = described_class.from_true_altitude(
        Astronoby::Angle.from_degrees(90)
      )

      expect(airmass.value.round(6)).to eq 1.0
      # pvlib young1994: 1.0000004
    end

    it "returns the airmass at 30°" do
      airmass = described_class.from_true_altitude(
        Astronoby::Angle.from_degrees(30)
      )

      expect(airmass.value.round(6)).to eq 1.991731
      # pvlib young1994: 1.991731
    end

    it "returns the airmass at 5°" do
      airmass = described_class.from_true_altitude(
        Astronoby::Angle.from_degrees(5)
      )

      expect(airmass.value.round(6)).to eq 10.058658
      # pvlib young1994: 10.058658
    end

    it "returns the airmass at the horizon" do
      airmass = described_class.from_true_altitude(Astronoby::Angle.zero)

      expect(airmass.value.round(6)).to eq 31.734862
      # pvlib young1994: 31.734862
    end

    it "returns nil below the horizon" do
      airmass = described_class.from_true_altitude(
        Astronoby::Angle.from_degrees(-0.1)
      )

      expect(airmass).to be_nil
    end

    it "refracts an altitude below the horizon when given an observer" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        temperature: Astronoby::Temperature.from_celsius(15),
        pressure: Astronoby::Pressure.standard_atmosphere
      )
      altitude = Astronoby::Angle.from_degrees(-0.3)

      airmass = described_class.from_true_altitude(altitude, observer: observer)

      expect(airmass.value.round(3)).to eq 34.796
      expect(airmass).to eq described_class.from_apparent_altitude(
        altitude +
          Astronoby::Refraction.angle(altitude: altitude, observer: observer)
      )
    end

    it "returns nil below the apparent horizon when given an observer" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        temperature: Astronoby::Temperature.from_celsius(15),
        pressure: Astronoby::Pressure.standard_atmosphere
      )

      airmass = described_class.from_true_altitude(
        Astronoby::Angle.from_degrees(-0.6),
        observer: observer
      )

      expect(airmass).to be_nil
    end

    it "ignores the observer above the horizon" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )
      altitude = Astronoby::Angle.from_degrees(5)

      airmass = described_class.from_true_altitude(altitude, observer: observer)

      expect(airmass).to eq described_class.from_true_altitude(altitude)
    end
  end

  describe "::from_apparent_altitude" do
    it "returns the airmass at 30°" do
      airmass = described_class.from_apparent_altitude(
        Astronoby::Angle.from_degrees(30)
      )

      expect(airmass.value.round(6)).to eq 1.994293
      # pvlib kastenyoung1989: 1.994293
    end

    it "returns the airmass at 5°" do
      airmass = described_class.from_apparent_altitude(
        Astronoby::Angle.from_degrees(5)
      )

      expect(airmass.value.round(6)).to eq 10.305791
      # pvlib kastenyoung1989: 10.305791
    end

    it "returns the airmass at the horizon" do
      airmass = described_class.from_apparent_altitude(Astronoby::Angle.zero)

      expect(airmass.value.round(6)).to eq 37.919608
      # pvlib kastenyoung1989: 37.919608
    end

    it "returns nil below the horizon" do
      airmass = described_class.from_apparent_altitude(
        Astronoby::Angle.from_degrees(-0.1)
      )

      expect(airmass).to be_nil
    end
  end

  it "agrees with the true altitude formula once refraction is applied" do
    observer = Astronoby::Observer.new(
      latitude: Astronoby::Angle.zero,
      longitude: Astronoby::Angle.zero,
      pressure: Astronoby::Pressure.standard_atmosphere
    )
    true_altitude = Astronoby::Angle.from_degrees(2)
    apparent_altitude = true_altitude +
      Astronoby::Refraction.angle(altitude: true_altitude, observer: observer)

    from_true = described_class.from_true_altitude(true_altitude)
    from_apparent = described_class.from_apparent_altitude(apparent_altitude)

    expect((from_apparent.value / from_true.value - 1).abs).to be < 0.01
  end

  describe "#value" do
    it "is a Float" do
      expect(described_class.new(2).value).to eq 2.0
      expect(described_class.new(2).value).to be_a Float
    end
  end

  describe "equality" do
    it "is equal to an airmass of the same value" do
      expect(described_class.new(2)).to eq described_class.new(2.0)
    end

    it "has the same hash as an equal airmass" do
      expect(described_class.new(2).hash).to eq described_class.new(2.0).hash
    end
  end

  describe "comparison" do
    it "orders airmasses" do
      expect(described_class.new(1.5)).to be < described_class.new(2)
    end

    it "compares with a number" do
      expect(described_class.new(1.5)).to be < 2
    end

    it "is not eql to a number of the same value" do
      expect(described_class.new(2)).not_to eql 2.0
    end
  end
end
