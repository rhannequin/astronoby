# frozen_string_literal: true

require "set" # rubocop:disable Lint/RedundantRequireStatement

RSpec.describe Astronoby::Velocity do
  describe "object immutability" do
    context "when a mutable method is added" do
      it "raises a FrozenError when immutability is broken" do
        described_class.class_eval do
          def clear
            @meters_per_second = 0
          end
        end

        expect { described_class.from_meters_per_second(1).clear }
          .to raise_error(FrozenError)
      end
    end
  end

  describe "::from_meters_per_second" do
    it "returns a Velocity object" do
      expect(described_class.from_meters_per_second(1)).to be_a(described_class)
    end
  end

  describe "::from_kilometers_per_second" do
    it "returns a Velocity object" do
      expect(described_class.from_kilometers_per_second(1))
        .to be_a(described_class)
    end

    it "converts kilometers per seconds to meters per second" do
      velocity = described_class.from_kilometers_per_second(1)

      expect(velocity.meters_per_second).to eq 1_000
    end
  end

  describe "::from_kilometers_per_day" do
    it "returns a Velocity object" do
      expect(described_class.from_kilometers_per_day(1))
        .to be_a(described_class)
    end

    it "converts kilometers per day to meters per second" do
      velocity = described_class.from_kilometers_per_day(172800)

      expect(velocity.meters_per_second).to eq 2_000
    end
  end

  describe "#meters" do
    it "returns the velocity value in meters per second" do
      meters_per_second = described_class.new(1).meters_per_second

      expect(meters_per_second).to eq 1
    end

    context "when the velocity is initialized from kilometers per second" do
      it "returns the velocity value in meters per second" do
        meters_per_second = described_class
          .from_kilometers_per_second(1)
          .meters_per_second

        expect(meters_per_second).to eq 1_000
      end
    end
  end

  describe "#kilometers_per_second" do
    it "returns the velocity value in kilometers per second" do
      kilometers_per_second = described_class
        .from_kilometers_per_second(1)
        .kilometers_per_second

      expect(kilometers_per_second).to eq 1
    end

    context "when the velocity is initialized from meters per seconds" do
      it "returns the velocity value in kilometers per second" do
        kilometers_per_second = described_class.new(1_000).kilometers_per_second

        expect(kilometers_per_second).to eq 1
      end
    end
  end

  describe "#kilometers_per_day" do
    it "returns the velocity value in kilometers per day" do
      kilometers_per_day = described_class
        .from_kilometers_per_day(1)
        .kilometers_per_day

      expect(kilometers_per_day).to eq 1
    end

    context "when the velocity is initialized from meters per seconds" do
      it "returns the velocity value in kilometers per second" do
        kilometers_per_day = described_class.from_kilometers_per_second(1)
          .kilometers_per_day

        expect(kilometers_per_day).to eq 86400
      end
    end
  end

  describe "#+" do
    it "returns a new velocity with a value of the two velocities added" do
      velocity_1 = described_class.from_meters_per_second(1)
      velocity_2 = described_class.from_kilometers_per_second(1)

      new_velocity = velocity_1 + velocity_2

      expect(new_velocity.meters_per_second).to eq 1001
    end
  end

  describe "#-" do
    it "returns a new velocity with a value of the two velocities subtracted" do
      velocity_1 = described_class.from_kilometers_per_second(1)
      velocity_2 = described_class.from_meters_per_second(1)

      new_velocity = velocity_1 - velocity_2

      expect(new_velocity.meters_per_second).to eq 999
    end
  end

  describe "#-@" do
    it "returns a new velocity with a negative value" do
      velocity = described_class.from_meters_per_second(1)

      new_velocity = -velocity

      expect(new_velocity.meters_per_second).to eq(-1)
    end
  end

  describe "#positive?" do
    it "returns true when the velocity is positive" do
      expect(described_class.from_meters_per_second(1).positive?).to be true
    end

    it "returns false when the velocity is negative" do
      expect(described_class.from_meters_per_second(-1).positive?).to be false
    end

    it "returns false when the velocity has a zero value" do
      expect(described_class.from_meters_per_second(0).positive?).to be false
    end
  end

  describe "#negative?" do
    it "returns false when the velocity is positive" do
      expect(described_class.from_meters_per_second(1).negative?).to be false
    end

    it "returns true when the velocity is negative" do
      expect(described_class.from_meters_per_second(-1).negative?).to be true
    end

    it "returns false when the velocity has a zero value" do
      expect(described_class.from_meters_per_second(0).negative?).to be false
    end
  end

  describe "zero?" do
    it "returns true when the velocity has a zero value" do
      expect(described_class.from_meters_per_second(0).zero?).to be true
    end

    it "returns false when the velocity has a non-zero value" do
      expect(described_class.from_meters_per_second(1).zero?).to be false
    end
  end

  describe "equivalence (#==)" do
    it "returns true when the velocities are equal" do
      velocity1 = described_class.from_meters_per_second(1)
      velocity2 = described_class.from_meters_per_second(1)

      expect(velocity1 == velocity2).to be true
    end

    it "returns false when the velocities are not equal" do
      velocity1 = described_class.from_meters_per_second(1)
      velocity2 = described_class.from_meters_per_second(2)

      expect(velocity1 == velocity2).to be false
    end

    it "returns false when the velocities are not of the same type" do
      velocity = described_class.from_meters_per_second(1)

      expect(velocity == 1).to be false
    end
  end

  describe "hash equality" do
    it "returns the same hash for equal velocities" do
      velocity1 = described_class.from_meters_per_second(1)
      velocity2 = described_class.from_meters_per_second(1)

      expect(Set[velocity1, velocity2].size).to eq 1
    end

    it "returns different hashes for different velocities" do
      velocity1 = described_class.from_meters_per_second(1)
      velocity2 = described_class.from_meters_per_second(2)

      expect(Set[velocity1, velocity2].size).to eq 2
    end
  end

  describe "comparison" do
    it "handles comparison of velocities" do
      velocity = described_class.from_meters_per_second(10)
      same_velocity = described_class.from_mps(10)
      greater_velocity = described_class.from_meters_per_second(20)
      smaller_velocity = described_class.from_meters_per_second(5)
      negative_velocity = described_class.from_meters_per_second(-10)

      expect(velocity == same_velocity).to be true
      expect(velocity != same_velocity).to be false
      expect(velocity > same_velocity).to be false
      expect(velocity >= same_velocity).to be true
      expect(velocity < same_velocity).to be false
      expect(velocity <= same_velocity).to be true

      expect(velocity < greater_velocity).to be true
      expect(velocity == greater_velocity).to be false
      expect(velocity != greater_velocity).to be true
      expect(velocity > greater_velocity).to be false

      expect(velocity < smaller_velocity).to be false
      expect(velocity == smaller_velocity).to be false
      expect(velocity != smaller_velocity).to be true
      expect(velocity > smaller_velocity).to be true

      expect(velocity < negative_velocity).to be false
      expect(velocity == negative_velocity).to be false
      expect(velocity != negative_velocity).to be true
      expect(velocity > negative_velocity).to be true
    end

    it "doesn't support comparison of velocities with other types" do
      velocity = described_class.from_meters_per_second(10)

      expect(velocity <=> 10).to be_nil
    end
  end
end
