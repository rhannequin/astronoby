# frozen_string_literal: true

require "set" # rubocop:disable Lint/RedundantRequireStatement

RSpec.describe Astronoby::Observer do
  describe "equivalence (#==)" do
    it "returns true when the observers are equivalent" do
      observer1 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        utc_offset: "+01:00",
        temperature: Astronoby::Temperature.from_kelvins(280),
        pressure: Astronoby::Pressure.from_millibars(10)
      )
      observer2 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        utc_offset: "+01:00",
        temperature: Astronoby::Temperature.from_kelvins(280),
        pressure: Astronoby::Pressure.from_millibars(10)
      )

      expect(observer1).to eq observer2
    end

    it "returns true when the observers are not equivalent" do
      observer1 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        utc_offset: "+01:00",
        temperature: Astronoby::Temperature.from_kelvins(280),
        pressure: Astronoby::Pressure.from_millibars(10)
      )
      observer2 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        utc_offset: "+01:00",
        temperature: Astronoby::Temperature.from_kelvins(280),
        pressure: Astronoby::Pressure.from_millibars(15)
      )

      expect(observer1).not_to eq observer2
    end
  end

  describe "hash equality" do
    it "makes an observer foundable as a Hash key" do
      observer1 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        utc_offset: "+01:00",
        temperature: Astronoby::Temperature.from_kelvins(280),
        pressure: Astronoby::Pressure.from_millibars(10)
      )
      observer2 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        utc_offset: "+01:00",
        temperature: Astronoby::Temperature.from_kelvins(280),
        pressure: Astronoby::Pressure.from_millibars(10)
      )
      map = {observer1 => :observer}

      expect(map[observer2]).to eq :observer
    end

    it "makes an observer foundable in a Set" do
      observer1 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        utc_offset: "+01:00",
        temperature: Astronoby::Temperature.from_kelvins(280),
        pressure: Astronoby::Pressure.from_millibars(10)
      )
      observer2 = described_class.new(
        latitude: Astronoby::Angle.from_degrees(45),
        longitude: Astronoby::Angle.from_degrees(90),
        elevation: Astronoby::Distance.from_meters(100),
        utc_offset: "+01:00",
        temperature: Astronoby::Temperature.from_kelvins(280),
        pressure: Astronoby::Pressure.from_millibars(10)
      )
      set = Set.new([observer1])

      expect(set.include?(observer2)).to be true
    end
  end

  describe "#temperature" do
    it "is 10 °C by default" do
      observer = described_class.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      expect(observer.temperature).to eq Astronoby::Temperature.from_celsius(10)
    end

    it "raises an error when given a number" do
      expect {
        described_class.new(
          latitude: Astronoby::Angle.zero,
          longitude: Astronoby::Angle.zero,
          temperature: 283.15
        )
      }.to raise_error(
        Astronoby::IncompatibleArgumentsError,
        "Expected temperature to be an Astronoby::Temperature, got 283.15"
      )
    end
  end

  describe "#pressure" do
    it "returns the pressure at the observer's elevation" do
      observer = described_class.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        elevation: Astronoby::Distance.from_meters(100),
        temperature: Astronoby::Temperature.from_celsius(10)
      )

      expect(observer.pressure.millibars.ceil(4)).to eq 1001.0982
    end

    it "is the standard atmosphere at sea level by default" do
      observer = described_class.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      expect(observer.pressure).to eq Astronoby::Pressure.standard_atmosphere
    end

    it "returns the given pressure" do
      pressure = Astronoby::Pressure.from_millibars(990)
      observer = described_class.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero,
        pressure: pressure
      )

      expect(observer.pressure).to eq pressure
    end

    it "raises an error when given a number" do
      expect {
        described_class.new(
          latitude: Astronoby::Angle.zero,
          longitude: Astronoby::Angle.zero,
          pressure: 1013.25
        )
      }.to raise_error(
        Astronoby::IncompatibleArgumentsError,
        "Expected pressure to be an Astronoby::Pressure, got 1013.25"
      )
    end
  end

  describe "#earth_fixed_rotation_matrix_for" do
    it "returns a Matrix" do
      time = Time.now
      instant = Astronoby::Instant.from_time(time)
      observer = described_class.new(
        latitude: Astronoby::Angle.zero,
        longitude: Astronoby::Angle.zero
      )

      matrix = observer.earth_fixed_rotation_matrix_for(instant)

      expect(matrix).to be_a(Matrix)
    end
  end
end
