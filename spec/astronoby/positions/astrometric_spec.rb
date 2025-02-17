# frozen_string_literal: true

RSpec.describe Astronoby::Astrometric do
  describe "#right_ascension" do
    it "extracts the right ascension from Cartesian coordinates" do
      position = Astronoby::Vector[
        Astronoby::Distance.from_kilometers(1),
        Astronoby::Distance.from_kilometers(1),
        Astronoby::Distance.from_kilometers(1)
      ]
      astrometric = described_class.new(
        position: position,
        velocity: kind_of(Vector),
        instant: kind_of(Astronoby::Instant),
        center_identifier: Astronoby::Planet::EARTH,
        target_body: Astronoby::Jupiter
      )

      expect(astrometric.right_ascension.str(:hms)).to eq("3h 0m 0.0s")
    end

    context "when the distance is null" do
      it "returns a null angle" do
        position = Astronoby::Vector[
          Astronoby::Distance.zero,
          Astronoby::Distance.zero,
          Astronoby::Distance.zero
        ]
        astrometric = described_class.new(
          position: position,
          velocity: kind_of(Vector),
          instant: kind_of(Astronoby::Instant),
          center_identifier: Astronoby::Planet::EARTH,
          target_body: Astronoby::Jupiter
        )

        expect(astrometric.right_ascension).to eq(Astronoby::Angle.zero)
      end
    end
  end

  describe "#declination" do
    it "extracts the declination from Cartesian coordinates" do
      position = Astronoby::Vector[
        Astronoby::Distance.from_kilometers(1),
        Astronoby::Distance.from_kilometers(1),
        Astronoby::Distance.from_kilometers(1)
      ]
      astrometric = described_class.new(
        position: position,
        velocity: kind_of(Vector),
        instant: kind_of(Astronoby::Instant),
        center_identifier: Astronoby::Planet::EARTH,
        target_body: Astronoby::Jupiter
      )

      expect(astrometric.declination.str(:dms)).to eq("+35° 15′ 51.8028″")
    end

    context "when the distance is null" do
      it "returns a null angle" do
        position = Astronoby::Vector[
          Astronoby::Distance.zero,
          Astronoby::Distance.zero,
          Astronoby::Distance.zero
        ]
        astrometric = described_class.new(
          position: position,
          velocity: kind_of(Vector),
          instant: kind_of(Astronoby::Instant),
          center_identifier: Astronoby::Planet::EARTH,
          target_body: Astronoby::Jupiter
        )

        expect(astrometric.declination).to eq(Astronoby::Angle.zero)
      end
    end
  end

  describe "#distance" do
    it "extracts the distance from Cartesian coordinates" do
      position = Astronoby::Vector[
        Astronoby::Distance.from_kilometers(2),
        Astronoby::Distance.from_kilometers(2),
        Astronoby::Distance.from_kilometers(1)
      ]
      astrometric = described_class.new(
        position: position,
        velocity: kind_of(Vector),
        instant: kind_of(Astronoby::Instant),
        center_identifier: Astronoby::Planet::EARTH,
        target_body: Astronoby::Jupiter
      )

      expect(astrometric.distance).to eq(Astronoby::Distance.from_kilometers(3))
    end

    context "when the distance is null" do
      it "returns a null distance" do
        position = Astronoby::Vector[
          Astronoby::Distance.zero,
          Astronoby::Distance.zero,
          Astronoby::Distance.zero
        ]
        astrometric = described_class.new(
          position: position,
          velocity: kind_of(Vector),
          instant: kind_of(Astronoby::Instant),
          center_identifier: Astronoby::Planet::EARTH,
          target_body: Astronoby::Jupiter
        )

        expect(astrometric.distance).to eq(Astronoby::Distance.zero)
      end
    end
  end
end
