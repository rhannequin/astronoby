# frozen_string_literal: true

require "set" # rubocop:disable Lint/RedundantRequireStatement

RSpec.describe Astronoby::Distance do
  describe "object immutability" do
    context "when a mutable method is added" do
      it "raises a FrozenError when immutability is broken" do
        described_class.class_eval do
          def clear
            @meters = 0
          end
        end

        expect { described_class.from_meters(180).clear }
          .to raise_error(FrozenError)
      end
    end
  end

  describe "::from_meters" do
    it "returns a Distance object" do
      expect(described_class.from_meters(1)).to be_a(described_class)
    end
  end

  describe "::from_kilometers" do
    it "returns a Distance object" do
      expect(described_class.from_kilometers(1)).to be_a(described_class)
    end

    it "converts kilometers to meters" do
      distance = described_class.from_kilometers(1)

      expect(distance.meters).to eq 1_000
    end
  end

  describe "::from_astronomical_units" do
    it "returns a Distance object" do
      expect(described_class.from_astronomical_units(1))
        .to be_a(described_class)
    end

    it "converts astronomical units to meters" do
      distance = described_class.from_astronomical_units(1)

      expect(distance.meters)
        .to eq Astronoby::Constants::ASTRONOMICAL_UNIT_IN_METERS
    end
  end

  describe "::vector_from_meters" do
    it "returns a Vector of Distance objects" do
      vector = described_class.vector_from_meters([1, 2, 3])

      expect(vector).to be_a(Astronoby::Vector)
      expect(vector).to all(be_a(described_class))
    end
  end

  describe "#meters" do
    it "returns the distance value in meters" do
      meters = described_class.new(1).meters

      expect(meters).to eq 1
    end

    context "when the distance is initialized from kilometers" do
      it "returns the distance value in meters" do
        meters = described_class.from_kilometers(1).meters

        expect(meters).to eq 1_000
      end
    end

    context "when the distance is initialized from astronomical units" do
      it "returns the distance value in meters" do
        meters = described_class.from_astronomical_units(1).meters

        expect(meters).to eq Astronoby::Constants::ASTRONOMICAL_UNIT_IN_METERS
      end
    end
  end

  describe "#kilometers" do
    it "returns the distance value in kilometers" do
      kilometers = described_class.from_kilometers(1).kilometers

      expect(kilometers).to eq 1
    end

    context "when the distance is initialized from meters" do
      it "returns the distance value in kilometers" do
        kilometers = described_class.new(1_000).kilometers

        expect(kilometers).to eq 1
      end
    end
  end

  describe "#astronomical_units" do
    it "returns the distance value in astronomical units" do
      astronomical_units =
        described_class.from_astronomical_units(1).astronomical_units

      expect(astronomical_units).to eq 1
    end

    context "when the distance is initialized from meters" do
      it "returns the distance value in astronomical units" do
        astronomical_units = described_class
          .new(Astronoby::Constants::ASTRONOMICAL_UNIT_IN_METERS)
          .astronomical_units

        expect(astronomical_units).to eq 1
      end
    end
  end

  describe "#+" do
    it "returns a new distance with a value of the two distances added" do
      distance_1 = described_class.from_meters(1)
      distance_2 = described_class.from_kilometers(1)

      new_distance = distance_1 + distance_2

      expect(new_distance.meters).to eq 1001
    end
  end

  describe "#-" do
    it "returns a new distance with a value of the two distances subtracted" do
      distance_1 = described_class.from_kilometers(1)
      distance_2 = described_class.from_meters(1)

      new_distance = distance_1 - distance_2

      expect(new_distance.meters).to eq 999
    end
  end

  describe "#-@" do
    it "returns a new distance with a negative value" do
      distance = described_class.from_meters(1)

      new_distance = -distance

      expect(new_distance.meters).to eq(-1)
    end
  end

  describe "#positive?" do
    it "returns true when the distance is positive" do
      expect(described_class.from_meters(1).positive?).to be true
    end

    it "returns false when the distance is negative" do
      expect(described_class.from_meters(-1).positive?).to be false
    end

    it "returns false when the distance has a zero value" do
      expect(described_class.from_meters(0).positive?).to be false
    end
  end

  describe "#negative?" do
    it "returns false when the distance is positive" do
      expect(described_class.from_meters(1).negative?).to be false
    end

    it "returns true when the distance is negative" do
      expect(described_class.from_meters(-1).negative?).to be true
    end

    it "returns false when the distance has a zero value" do
      expect(described_class.from_meters(0).negative?).to be false
    end
  end

  describe "zero?" do
    it "returns true when the distance has a zero value" do
      expect(described_class.from_meters(0).zero?).to be true
    end

    it "returns false when the distance has a non-zero value" do
      expect(described_class.from_meters(1).zero?).to be false
    end
  end

  describe "#abs2" do
    it "returns the square of the distance value" do
      expect(described_class.from_meters(3).abs2).to eq 9
    end
  end

  describe "equivalence (#==)" do
    it "returns true when the distances are equal" do
      distance1 = described_class.from_meters(1)
      distance2 = described_class.from_meters(1)

      expect(distance1 == distance2).to be true
    end

    it "returns false when the distances are not equal" do
      distance1 = described_class.from_meters(1)
      distance2 = described_class.from_meters(2)

      expect(distance1 == distance2).to be false
    end

    it "returns false when the distances are not of the same type" do
      distance = described_class.from_meters(1)

      expect(distance == 1).to be false
    end
  end

  describe "hash equality" do
    it "returns the same hash for equal distances" do
      distance1 = described_class.from_meters(1)
      distance2 = described_class.from_meters(1)

      expect(Set[distance1, distance2].size).to eq 1
    end

    it "returns different hashes for different distances" do
      distance1 = described_class.from_meters(1)
      distance2 = described_class.from_meters(2)

      expect(Set[distance1, distance2].size).to eq 2
    end
  end

  describe "comparison" do
    it "handles comparison of distances" do
      distance = described_class.from_meters(10)
      same_distance = described_class.from_m(10)
      greater_distance = described_class.from_meters(20)
      smaller_distance = described_class.from_meters(5)
      negative_distance = described_class.from_meters(-10)

      expect(distance == same_distance).to be true
      expect(distance != same_distance).to be false
      expect(distance > same_distance).to be false
      expect(distance >= same_distance).to be true
      expect(distance < same_distance).to be false
      expect(distance <= same_distance).to be true

      expect(distance < greater_distance).to be true
      expect(distance == greater_distance).to be false
      expect(distance != greater_distance).to be true
      expect(distance > greater_distance).to be false

      expect(distance < smaller_distance).to be false
      expect(distance == smaller_distance).to be false
      expect(distance != smaller_distance).to be true
      expect(distance > smaller_distance).to be true

      expect(distance < negative_distance).to be false
      expect(distance == negative_distance).to be false
      expect(distance != negative_distance).to be true
      expect(distance > negative_distance).to be true
    end

    it "doesn't support comparison of distances with other types" do
      distance = described_class.from_meters(10)

      expect(distance <=> 10).to be_nil
    end
  end
end
