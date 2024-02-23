# frozen_string_literal: true

RSpec.describe Astronoby::Angle do
  describe "::as_radians" do
    it "returns an Angle object" do
      expect(described_class.as_radians(described_class::PI))
        .to be_a(described_class)
    end
  end

  describe "::as_degrees" do
    it "returns an Angle object" do
      expect(described_class.as_degrees(180)).to be_a(described_class)
    end
  end

  describe "::as_hours" do
    it "returns an Angle object" do
      expect(described_class.as_hours(23)).to be_a(described_class)
    end
  end

  describe "::asin" do
    it "returns an Angle object" do
      expect(described_class.asin(1)).to be_a(described_class)
    end

    it "initializes an angle with the inverse sine of a ratio" do
      ratio = 0.5
      angle = described_class.asin(ratio)
      precision = 10**-described_class::PRECISION
      radians = described_class::PI / 6

      expect(angle.radians).to be_within(precision).of(radians)
    end
  end

  describe "::acos" do
    it "returns an Angle object" do
      expect(described_class.acos(0.5)).to be_a(described_class)
    end

    it "initializes an angle with the inverse sine of a ratio" do
      ratio = 0.5
      angle = described_class.acos(ratio)
      precision = 10**-described_class::PRECISION
      radians = described_class::PI / 3

      expect(angle.radians).to be_within(precision).of(radians)
    end
  end

  describe "::atan" do
    it "returns an Angle object" do
      expect(described_class.atan(1)).to be_a(described_class)
    end

    it "initializes an angle with the inverse sine of a ratio" do
      ratio = 1
      angle = described_class.atan(ratio)
      precision = 10**-described_class::PRECISION
      radians = described_class::PI / 4

      expect(angle.radians).to be_within(precision).of(radians)
    end
  end

  describe "#radians" do
    it "returns the angle value in radian unit" do
      radians = described_class.new(described_class::PI).radians

      expect(radians).to eq described_class::PI
    end

    context "when the angle is initialized from degrees" do
      it "returns the angle value in radian unit" do
        radians = described_class.as_degrees(180).radians

        expect(radians).to eq described_class::PI
      end
    end

    context "when the angle is initialized from hours" do
      it "returns the angle value in radian unit within fixed precision" do
        radians = described_class.as_hours(12).radians

        expect(radians)
          .to be_within(10**-described_class::PRECISION).of(described_class::PI)
      end
    end
  end

  describe "#degrees" do
    it "returns the angle value in degree unit" do
      degrees = described_class.as_degrees(180).degrees

      expect(degrees).to eq 180
    end

    context "when the angle is initialized from radians" do
      it "returns the angle value in degree unit" do
        degrees = described_class.as_radians(described_class::PI).degrees

        expect(degrees).to eq 180
      end
    end

    context "when the angle is initialized from hours" do
      it "returns the angle value in degree unit within fixed precision" do
        degrees = described_class.as_hours(12).degrees

        expect(degrees).to be_within(10**-described_class::PRECISION).of(180)
      end
    end
  end

  describe "#hours" do
    it "returns the angle value in degree unit within fixed precision" do
      hours = described_class.as_hours(12).hours

      expect(hours).to eq 12
    end

    context "when the angle is initialized from radians" do
      it "returns the angle value in degree unit within fixed precision" do
        hours = described_class.as_radians(described_class::PI).hours

        expect(hours).to be_within(10**-described_class::PRECISION).of(12)
      end
    end

    context "when the angle is initialized from degrees" do
      it "returns the angle value in degree unit within fixed precision" do
        hours = described_class.as_degrees(180).hours

        expect(hours).to be_within(10**-described_class::PRECISION).of(12)
      end
    end
  end

  describe "#+" do
    it "returns a new angle with a value of the two angles added" do
      angle_1 = described_class.as_radians(described_class::PI)
      angle_2 = described_class.as_degrees(45)

      new_angle = angle_1 + angle_2

      expect(new_angle.degrees).to eq 225
    end
  end

  describe "#-" do
    it "returns a new angle with a value of the two angles substracted" do
      angle_1 = described_class.as_radians(described_class::PI)
      angle_2 = described_class.as_degrees(45)

      new_angle = angle_1 - angle_2

      expect(new_angle.degrees).to eq 135
    end
  end

  describe "#sin" do
    it "returns the sine value of the angle" do
      radians = described_class::PI / 6
      angle = described_class.as_radians(radians)

      sine = angle.sin.ceil(described_class::PRECISION)

      expect(sine).to eq 0.5
    end
  end

  describe "#cos" do
    it "returns the cosine value of the angle" do
      radians = described_class::PI / 3
      angle = described_class.as_radians(radians)

      cosine = angle.cos.ceil(described_class::PRECISION)

      expect(cosine).to eq 0.5
    end
  end

  describe "#tan" do
    it "returns the tangent value of the angle" do
      radians = described_class::PI / 4
      angle = described_class.as_radians(radians)

      tangent = angle.tan.ceil(described_class::PRECISION)

      expect(tangent).to eq 1
    end
  end

  describe "#positive?" do
    it "returns true when the angle is positive" do
      expect(described_class.as_degrees(90).positive?).to be true
    end

    it "returns false when the angle is negative" do
      expect(described_class.as_degrees(-90).positive?).to be false
    end

    it "returns famse when the angle has a zero value" do
      expect(described_class.as_degrees(0).positive?).to be false
    end
  end

  describe "#negative?" do
    it "returns false when the angle is positive" do
      expect(described_class.as_degrees(90).negative?).to be false
    end

    it "returns true when the angle is negative" do
      expect(described_class.as_degrees(-90).negative?).to be true
    end

    it "returns false when the angle has a zero value" do
      expect(described_class.as_degrees(0).negative?).to be false
    end
  end

  describe "#zero?" do
    it "returns false when the angle is positive" do
      expect(described_class.as_degrees(90).zero?).to be false
    end

    it "returns false when the angle is negative" do
      expect(described_class.as_degrees(-90).zero?).to be false
    end

    it "returns true when the angle has a zero value" do
      expect(described_class.as_degrees(0).zero?).to be true
    end
  end

  describe "#str" do
    it "returns a String" do
      angle = described_class.as_degrees(180)

      expect(angle.str(:dms)).to be_a(String)
    end

    describe "to the DMS format" do
      context "when the angle is positive" do
        it "properly formats the angle" do
          angle = described_class.as_degrees(10.2958)

          expect(angle.str(:dms)).to eq "+10° 17′ 44.88″"
        end
      end

      context "when the angle is negative" do
        it "properly formats the angle" do
          angle = described_class.as_degrees(-10.2958)

          expect(angle.str(:dms)).to eq "-10° 17′ 44.88″"
        end
      end
    end

    describe "to the HMS format" do
      it "properly formats the angle" do
        angle = described_class.as_hours(12.345678)

        expect(angle.str(:hms)).to eq "12h 20m 44.4408s"
      end
    end

    describe "to an unsupported format" do
      it "raises an UnsupportedFormatError exception" do
        angle = described_class.as_degrees(180)

        expect { angle.str(:unknown) }
          .to raise_error(Astronoby::UnsupportedFormatError, "Expected a format between dms, hms, got unknown")
      end
    end
  end
end
