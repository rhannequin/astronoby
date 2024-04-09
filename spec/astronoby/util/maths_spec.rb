# frozen_string_literal: true

RSpec.describe Astronoby::Util::Maths do
  describe "::interpolate" do
    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 3 - Interpolation, p.25
    it "calculates the interpolation for 3 terms" do
      interpolation = described_class.interpolate(
        [0.884226, 0.877366, 0.870531],
        0.18125
      )

      expect(interpolation.round(6)).to eq 0.876125
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 3 - Interpolation, p.25
    it "calculates the interpolation for 3 terms" do
      interpolation = described_class.interpolate(
        [1.3814294, 1.3812213, 1.3812453],
        0.3966
      )

      expect(interpolation.round(6)).to eq 1.381203
    end

    # Source:
    #  Title: Astronomical Algorithms
    #  Author: Jean Meeus
    #  Edition: 2nd edition
    #  Chapter: 3 - Interpolation, p.25
    it "calculates the interpolation for 5 terms" do
      interpolation = described_class.interpolate(
        [
          Astronoby::Angle.from_hms(0, 54, 36.125).hours * 3600,
          Astronoby::Angle.from_hms(0, 54, 24.606).hours * 3600,
          Astronoby::Angle.from_hms(0, 54, 15.486).hours * 3600,
          Astronoby::Angle.from_hms(0, 54, 8.694).hours * 3600,
          Astronoby::Angle.from_hms(0, 54, 4.133).hours * 3600
        ],
        0.27777778
      )

      expect(interpolation.round(3))
        .to eq(Astronoby::Angle.from_hms(0, 54, 13.369).hours * 3600)
    end

    context "when the interpolation factor is out of range" do
      it "raises an error" do
        expect { described_class.interpolate([1, 2, 3], 4) }
          .to raise_error(
            Astronoby::IncompatibleArgumentsError,
            "Interpolation factor must be between 0 and 1"
          )
      end
    end
  end
end
