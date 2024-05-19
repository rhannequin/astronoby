# frozen_string_literal: true

require "set" # rubocop:disable Lint/RedundantRequireStatement

RSpec.describe Astronoby::Observer do
  describe "equivalence (#==)" do
    it "returns true when the observers are equivalent" do
      observer1 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        temperature: 280,
        pressure: 10
      )
      observer2 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        temperature: 280,
        pressure: 10
      )

      expect(observer1).to eq observer2
    end

    it "returns true when the observers are not equivalent" do
      observer1 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        temperature: 280,
        pressure: 10
      )
      observer2 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        temperature: 280,
        pressure: 15
      )

      expect(observer1).not_to eq observer2
    end
  end

  describe "hash equality" do
    it "makes an angle foundable as a Hash key" do
      observer1 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        temperature: 280,
        pressure: 10
      )
      observer2 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        temperature: 280,
        pressure: 10
      )
      map = {observer1 => :observer}

      expect(map[observer2]).to eq :observer
    end

    it "makes an angle foundable in a Set" do
      observer1 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        temperature: 280,
        pressure: 10
      )
      observer2 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        temperature: 280,
        pressure: 10
      )
      set = Set.new([observer1])

      expect(set.include?(observer2)).to be true
    end
  end

  describe "#pressure" do
    it "returns the computed pression in millibars" do
      latitude = Astronoby::Angle.from_degrees(0)
      longitude = Astronoby::Angle.from_degrees(0)
      elevation = Astronoby::Distance.from_meters(100)
      temperature = 273.15 + 10

      pressure = described_class.new(
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        temperature: temperature
      ).pressure

      expect(pressure.ceil(4)).to eq 1001.0982
    end

    context "when elevation and temperature are not provided" do
      it "returns the computed pression in millibars" do
        latitude = Astronoby::Angle.from_degrees(0)
        longitude = Astronoby::Angle.from_degrees(0)

        pressure = described_class
          .new(latitude: latitude, longitude: longitude)
          .pressure

        expect(pressure).to eq described_class::PRESSURE_AT_SEA_LEVEL
      end
    end
  end
end
