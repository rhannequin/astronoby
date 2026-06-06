# frozen_string_literal: true

RSpec.describe Astronoby::Center do
  describe ".barycentric" do
    it "returns a barycentric center" do
      center = described_class.barycentric

      expect(center).to be_barycentric
      expect(center).not_to be_geocentric
      expect(center).not_to be_topocentric
      expect(center).not_to be_observer_dependent
    end

    it "returns the same memoized instance" do
      expect(described_class.barycentric).to be(described_class.barycentric)
    end
  end

  describe ".geocentric" do
    it "returns a geocentric center" do
      center = described_class.geocentric

      expect(center).to be_geocentric
      expect(center).not_to be_barycentric
      expect(center).not_to be_topocentric
      expect(center).not_to be_observer_dependent
    end

    it "returns the same memoized instance" do
      expect(described_class.geocentric).to be(described_class.geocentric)
    end
  end

  describe ".topocentric" do
    it "returns a topocentric center carrying the observer" do
      observer = Astronoby::Observer.new(
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      )

      center = described_class.topocentric(observer)

      expect(center).to be_topocentric
      expect(center).to be_observer_dependent
      expect(center.observer).to eq(observer)
    end
  end

  describe "#==" do
    it "considers two barycentric centers equal" do
      expect(described_class.barycentric).to eq(described_class.barycentric)
    end

    it "considers two geocentric centers equal" do
      expect(described_class.geocentric).to eq(described_class.geocentric)
    end

    it "considers barycentric and geocentric centers different" do
      expect(described_class.barycentric).not_to eq(described_class.geocentric)
    end

    it "considers topocentric centers at the same location equal" do
      first = described_class.topocentric(
        Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522),
          elevation: Astronoby::Distance.from_meters(35)
        )
      )
      second = described_class.topocentric(
        Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522),
          elevation: Astronoby::Distance.from_meters(35)
        )
      )

      expect(first).to eq(second)
    end

    it "ignores atmospheric parameters when comparing locations" do
      location = {
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      }
      first = described_class.topocentric(
        Astronoby::Observer.new(**location, temperature: 280)
      )
      second = described_class.topocentric(
        Astronoby::Observer.new(**location, temperature: 300)
      )

      expect(first).to eq(second)
    end

    it "considers topocentric centers at different elevations different" do
      location = {
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      }
      first = described_class.topocentric(
        Astronoby::Observer.new(**location, elevation: Astronoby::Distance.zero)
      )
      second = described_class.topocentric(
        Astronoby::Observer.new(
          **location,
          elevation: Astronoby::Distance.from_meters(100)
        )
      )

      expect(first).not_to eq(second)
    end
  end

  describe "#hash" do
    it "lets equal centers be used interchangeably as hash keys" do
      hash = {described_class.geocentric => :earth}

      expect(hash[described_class.geocentric]).to eq(:earth)
    end

    it "matches topocentric centers at the same location" do
      location = {
        latitude: Astronoby::Angle.from_degrees(48.8566),
        longitude: Astronoby::Angle.from_degrees(2.3522)
      }
      hash = {
        described_class.topocentric(Astronoby::Observer.new(**location)) =>
          :paris
      }
      lookup = described_class.topocentric(Astronoby::Observer.new(**location))

      expect(hash[lookup]).to eq(:paris)
    end
  end
end
