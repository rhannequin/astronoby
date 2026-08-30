# frozen_string_literal: true

RSpec.describe Astronoby::Horizon do
  describe ".angle_for" do
    it "puts the Sun's centre 50 arcminutes below the horizon" do
      angle = described_class.angle_for(
        body: Astronoby::Sun,
        distance: Astronoby::Distance.from_astronomical_units(1)
      )

      expect(angle.degrees).to be_within(1e-12).of(-50.0 / 60)
    end

    it "adds the Moon's semidiameter to the refraction" do
      angle = described_class.angle_for(
        body: Astronoby::Moon,
        distance: Astronoby::Distance.from_kilometers(384_400)
      )

      expect(angle.str(:dms)).to eq("-0° 49′ 32.2697″")
    end

    it "grows with the Moon's distance, as its semidiameter shrinks" do
      perigee = described_class.angle_for(
        body: Astronoby::Moon,
        distance: Astronoby::Distance.from_kilometers(356_500)
      )
      apogee = described_class.angle_for(
        body: Astronoby::Moon,
        distance: Astronoby::Distance.from_kilometers(406_700)
      )

      expect(apogee.degrees).to be > perigee.degrees
    end

    it "refracts anything else by 34 arcminutes" do
      angle = described_class.angle_for(
        body: Astronoby::Jupiter,
        distance: Astronoby::Distance.from_astronomical_units(5)
      )

      expect(angle.degrees).to be_within(1e-12).of(-34.0 / 60)
    end
  end

  describe ".moon_semidiameter" do
    it "is 15.5 arcminutes at the Moon's mean distance" do
      semidiameter = described_class.moon_semidiameter(
        Astronoby::Distance.from_kilometers(384_400)
      )

      expect(semidiameter.degrees * 60).to be_within(0.05).of(15.5)
    end
  end

  describe ".moon_semidiameter_radians" do
    it "is the same angle, for callers working in radians" do
      distance = Astronoby::Distance.from_kilometers(384_400)

      radians = described_class.moon_semidiameter_radians(distance.m)

      expect(radians).to be_within(1e-15).of(
        described_class.moon_semidiameter(distance).radians
      )
    end

    it "does not lose the semidiameter to integer division" do
      radians = described_class.moon_semidiameter_radians(
        Astronoby::Distance.from_kilometers(384_400).m
      )

      expect(radians).to be > 0
    end
  end
end
