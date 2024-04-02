# frozen_string_literal: true

RSpec.describe Astronoby::Angle do
  describe "object immutability" do
    context "when a mutable method is added" do
      it "raises a FrozenError when immutability is broken" do
        described_class.class_eval do
          def clear
            @radians = 0
          end
        end

        expect { described_class.from_degrees(180).clear }
          .to raise_error(FrozenError)
      end
    end
  end

  describe "::from_radians" do
    it "returns an Angle object" do
      expect(described_class.from_radians(Math::PI)).to be_a(described_class)
    end

    it "normalizes the angle" do
      expect(described_class.from_radians(2 * Math::PI).radians).to eq 0

      expect(described_class.from_radians(3 * Math::PI).radians).to eq Math::PI

      expect(described_class.from_radians(-5 * Math::PI).radians)
        .to eq(-Math::PI)

      expect(described_class.from_radians(Math::PI / 2).radians)
        .to eq Math::PI / 2
    end
  end

  describe "::from_degrees" do
    it "returns an Angle object" do
      expect(described_class.from_degrees(180)).to be_a(described_class)
    end

    it "normalizes the angle" do
      expect(described_class.from_degrees(360).degrees.round).to eq 0
      expect(described_class.from_degrees(365).degrees.round).to eq 5
      expect(described_class.from_degrees(-365).degrees.round).to eq(-5)
      expect(described_class.from_degrees(70).degrees.round).to eq 70
      expect(described_class.from_degrees(-70).degrees.round).to eq(-70)
    end
  end

  describe "::from_hours" do
    it "returns an Angle object" do
      expect(described_class.from_hours(23)).to be_a(described_class)
    end

    it "normalizes the angle" do
      expect(described_class.from_hours(24).hours.round).to eq 0
      expect(described_class.from_hours(26).hours.round).to eq 2
      expect(described_class.from_hours(-26).hours.round).to eq(-2)
      expect(described_class.from_hours(23).hours.round).to eq 23
      expect(described_class.from_hours(-23).hours.round).to eq(-23)
    end
  end

  describe "::asin" do
    it "returns an Angle object" do
      expect(described_class.asin(1)).to be_a(described_class)
    end

    it "initializes an angle with the inverse sine of a ratio" do
      ratio = 0.5
      precision = 10**-described_class::MIN_PRECISION

      angle = described_class.asin(ratio)

      expect(angle.radians).to be_within(precision).of(Math::PI / 6)
    end
  end

  describe "::acos" do
    it "returns an Angle object" do
      expect(described_class.acos(0.5)).to be_a(described_class)
    end

    it "initializes an angle with the inverse sine of a ratio" do
      ratio = 0.5
      precision = 10**-described_class::MIN_PRECISION

      angle = described_class.acos(ratio)

      expect(angle.radians).to be_within(precision).of(Math::PI / 3)
    end
  end

  describe "::atan" do
    it "returns an Angle object" do
      expect(described_class.atan(1)).to be_a(described_class)
    end

    it "initializes an angle with the inverse sine of a ratio" do
      ratio = 1
      precision = 10**-described_class::MIN_PRECISION

      angle = described_class.atan(ratio)

      expect(angle.radians).to be_within(precision).of(Math::PI / 4)
    end
  end

  describe "#radians" do
    it "returns the angle value in radian unit" do
      radians = described_class.new(Math::PI).radians

      expect(radians).to eq Math::PI
    end

    context "when the angle is initialized from degrees" do
      it "returns the angle value in radian unit" do
        radians = described_class.from_degrees(180).radians

        expect(radians).to eq Math::PI
      end
    end

    context "when the angle is initialized from hours" do
      it "returns the angle value in radian unit" do
        radians = described_class.from_hours(12).radians

        expect(radians).to eq Math::PI
      end
    end
  end

  describe "#degrees" do
    it "returns the angle value in degree unit" do
      degrees = described_class.from_degrees(180).degrees

      expect(degrees).to eq 180
    end

    context "when the angle is initialized from radians" do
      it "returns the angle value in degree unit" do
        degrees = described_class.from_radians(Math::PI).degrees

        expect(degrees).to eq 180
      end
    end

    context "when the angle is initialized from hours" do
      it "returns the angle value in degree unit" do
        degrees = described_class.from_hours(12).degrees

        expect(degrees).to eq 180
      end
    end
  end

  describe "#hours" do
    it "returns the angle value in degree unit" do
      hours = described_class.from_hours(12).hours

      expect(hours).to eq 12
    end

    context "when the angle is initialized from radians" do
      it "returns the angle value in degree unit" do
        hours = described_class.from_radians(Math::PI).hours

        expect(hours).to eq 12
      end
    end

    context "when the angle is initialized from degrees" do
      it "returns the angle value in degree unit" do
        hours = described_class.from_degrees(180).hours

        expect(hours).to eq 12
      end
    end
  end

  describe "#+" do
    it "returns a new angle with a value of the two angles added" do
      angle_1 = described_class.from_radians(Math::PI)
      angle_2 = described_class.from_degrees(45)

      new_angle = angle_1 + angle_2

      expect(new_angle.degrees).to eq 225
    end
  end

  describe "#-" do
    it "returns a new angle with a value of the two angles substracted" do
      angle_1 = described_class.from_radians(Math::PI)
      angle_2 = described_class.from_degrees(45)

      new_angle = angle_1 - angle_2

      expect(new_angle.degrees).to eq 135
    end
  end

  describe "#sin" do
    it "returns the sine value of the angle" do
      radians = Math::PI / 6
      angle = described_class.from_radians(radians)

      sine = angle.sin.round(described_class::MIN_PRECISION)

      expect(sine).to eq 0.5
    end
  end

  describe "#cos" do
    it "returns the cosine value of the angle" do
      radians = Math::PI / 3
      angle = described_class.from_radians(radians)

      cosine = angle.cos.round(described_class::MIN_PRECISION)

      expect(cosine).to eq 0.5
    end
  end

  describe "#tan" do
    it "returns the tangent value of the angle" do
      radians = Math::PI / 4
      angle = described_class.from_radians(radians)

      tangent = angle.tan.round(described_class::MIN_PRECISION)

      expect(tangent).to eq 1
    end
  end

  describe "#positive?" do
    it "returns true when the angle is positive" do
      expect(described_class.from_degrees(90).positive?).to be true
    end

    it "returns false when the angle is negative" do
      expect(described_class.from_degrees(-90).positive?).to be false
    end

    it "returns famse when the angle has a zero value" do
      expect(described_class.from_degrees(0).positive?).to be false
    end
  end

  describe "#negative?" do
    it "returns false when the angle is positive" do
      expect(described_class.from_degrees(90).negative?).to be false
    end

    it "returns true when the angle is negative" do
      expect(described_class.from_degrees(-90).negative?).to be true
    end

    it "returns false when the angle has a zero value" do
      expect(described_class.from_degrees(0).negative?).to be false
    end
  end

  describe "#zero?" do
    it "returns false when the angle is positive" do
      expect(described_class.from_degrees(90).zero?).to be false
    end

    it "returns false when the angle is negative" do
      expect(described_class.from_degrees(-90).zero?).to be false
    end

    it "returns true when the angle has a zero value" do
      expect(described_class.from_degrees(0).zero?).to be true
    end
  end

  describe "equivalence (#==)" do
    it "returns true when the angle is equivalent" do
      angle1 = Astronoby::Angle.from_degrees(180)
      angle2 = Astronoby::Angle.from_degrees(180)

      expect(angle1).to eq angle2
    end

    it "returns true when the angle is not equivalent" do
      angle1 = Astronoby::Angle.from_degrees(180)
      angle2 = Astronoby::Angle.from_degrees(90)

      expect(angle1).not_to eq angle2
    end
  end

  describe "hash equality" do
    it "makes an angle foundable as a Hash key" do
      angle1 = Astronoby::Angle.from_degrees(180)
      angle1_bis = Astronoby::Angle.from_degrees(180)
      map = {angle1 => :angle}

      expect(map[angle1_bis]).to eq :angle
    end

    it "makes an angle foundable in a Set" do
      angle1 = Astronoby::Angle.from_degrees(180)
      angle1_bis = Astronoby::Angle.from_degrees(180)
      set = Set.new([angle1])

      expect(set.include?(angle1_bis)).to be true
    end
  end

  describe "comparison" do
    it "handles comparison of angles" do
      angle = described_class.from_degrees(10)
      same_angle = described_class.from_degrees(10)
      greater_angle = described_class.from_radians(Math::PI)
      smaller_angle = described_class.from_degrees(5)
      way_greater_angle = described_class.from_degrees(365)
      negative_angle = described_class.from_radians(-Math::PI)

      expect(angle == same_angle).to be true
      expect(angle != same_angle).to be false
      expect(angle > same_angle).to be false
      expect(angle >= same_angle).to be true
      expect(angle < same_angle).to be false
      expect(angle <= same_angle).to be true

      expect(angle < greater_angle).to be true
      expect(angle == greater_angle).to be false
      expect(angle != greater_angle).to be true
      expect(angle > greater_angle).to be false

      expect(angle < smaller_angle).to be false
      expect(angle == smaller_angle).to be false
      expect(angle != smaller_angle).to be true
      expect(angle > smaller_angle).to be true

      expect(angle < way_greater_angle).to be false
      expect(angle == way_greater_angle).to be false
      expect(angle != way_greater_angle).to be true
      expect(angle > way_greater_angle).to be true

      expect(angle < negative_angle).to be false
      expect(angle == negative_angle).to be false
      expect(angle != negative_angle).to be true
      expect(angle > negative_angle).to be true
    end

    it "doesn't support comparison of angles with other types" do
      angle = Astronoby::Angle.from_degrees(10)

      expect(angle <=> 10).to be_nil
    end
  end

  describe "#str" do
    it "returns a String" do
      angle = described_class.from_degrees(180)

      expect(angle.str(:dms)).to be_a(String)
    end

    describe "to the DMS format" do
      context "when the angle is positive" do
        it "properly formats the angle" do
          angle = described_class.from_degrees(10.2958)

          expect(angle.str(:dms)).to eq "+10° 17′ 44.8799″"
        end
      end

      context "when the angle is negative" do
        it "properly formats the angle" do
          angle = described_class.from_degrees(-10.2958)

          expect(angle.str(:dms)).to eq "-10° 17′ 44.88″"
        end
      end
    end

    describe "to the HMS format" do
      it "properly formats the angle" do
        angle = described_class.from_hours(12.345678)

        expect(angle.str(:hms)).to eq "12h 20m 44.4407s"
      end
    end

    describe "to an unsupported format" do
      it "raises an UnsupportedFormatError exception" do
        angle = described_class.from_degrees(180)

        expect { angle.str(:unknown) }.to raise_error(
          Astronoby::UnsupportedFormatError,
          "Expected a format between dms, hms, got unknown"
        )
      end
    end
  end
end
