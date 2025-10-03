# frozen_string_literal: true

RSpec.describe Astronoby::AngularVelocity do
  describe "object immutability" do
    context "when a mutable method is added" do
      it "raises a FrozenError when immutability is broken" do
        described_class.class_eval do
          def clear
            @radians_per_second = 0
          end
        end

        expect { described_class.from_radians_per_second(180).clear }
          .to raise_error(FrozenError)
      end
    end
  end

  describe "::from_radians_per_second" do
    it "returns an AngularVelocity object" do
      expect(described_class.from_radians_per_second(Math::PI))
        .to be_a(described_class)
    end
  end

  describe "::from_milliarcseconds_per_year" do
    it "returns an AngularVelocity object" do
      expect(described_class.from_milliarcseconds_per_year(180))
        .to be_a(described_class)
    end
  end

  describe "#radians_per_second" do
    it "returns the angular velocity value in radians per second" do
      radians_per_second = described_class.new(Math::PI).radians_per_second

      expect(radians_per_second).to eq Math::PI
    end

    context "when the angle is initialized from milliarcseconds per year" do
      it "returns the angular velocity value in radians per second" do
        radians_per_second = described_class
          .from_milliarcseconds_per_year(1_000_000)
          .radians_per_second

        expect(radians_per_second)
          .to eq 1.5362818500441606e-10
      end
    end
  end

  describe "#milliarcseconds_per_year" do
    it "returns the angle value in milliarcseconds per year" do
      milliarcseconds_per_year = described_class
        .from_milliarcseconds_per_year(10)
        .milliarcseconds_per_year

      expect(milliarcseconds_per_year).to eq 10
    end

    context "when the angle is initialized from radians per second" do
      it "returns the angle value in milliarcseconds per year" do
        milliarcseconds_per_year = described_class
          .from_radians_per_second(Math::PI)
          .milliarcseconds_per_year

        expect(milliarcseconds_per_year).to eq 2.04493248e+16
      end
    end
  end

  describe "#+" do
    it "returns a new angular velocity with a value of the two added" do
      angular_velocity_1 = described_class.from_radians_per_second(10)
      angular_velocity_2 = described_class.from_milliarcseconds_per_year(10)

      new_angular_velocity = angular_velocity_1 + angular_velocity_2

      expect(new_angular_velocity.milliarcseconds_per_year)
        .to eq 2.4193572896233696e+16
    end
  end
end
