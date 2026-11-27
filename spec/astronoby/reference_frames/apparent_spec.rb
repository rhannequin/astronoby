# frozen_string_literal: true

RSpec.describe Astronoby::Apparent do
  include TestEphemHelper

  describe "::build_from_astrometric" do
    context "when no Earth geometric frame is given" do
      it "only rotates, as with a motionless Earth" do
        instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
        astrometric = instance_double(
          Astronoby::Astrometric,
          position: Astronoby::Distance.vector_from_meters(
            [1.0e20, 2.0e20, 3.0e20]
          ),
          velocity: Astronoby::Velocity.vector_from_mps(
            [1000.0, 2000.0, 3000.0]
          )
        )
        motionless_earth = instance_double(
          Astronoby::Geometric,
          velocity: Astronoby::Velocity.vector_from_mps([0.0, 0.0, 0.0])
        )

        without_earth = described_class.build_from_astrometric(
          instant: instant,
          target_astrometric: astrometric,
          target_body: nil
        )
        with_motionless_earth = described_class.build_from_astrometric(
          instant: instant,
          target_astrometric: astrometric,
          earth_geometric: motionless_earth,
          target_body: nil
        )

        expect(without_earth.position.map(&:m).to_a)
          .to eq(with_motionless_earth.position.map(&:m).to_a)
        expect(without_earth.velocity.map(&:mps).to_a)
          .to eq(with_motionless_earth.velocity.map(&:mps).to_a)
      end
    end

    it "does not deflect the light of the Moon" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      ephem = test_ephem
      moon = Astronoby::Moon.new(instant: instant, ephem: ephem)

      with_ephem = described_class.build_from_astrometric(
        instant: instant,
        target_astrometric: moon.astrometric,
        earth_geometric: moon.earth_geometric,
        ephem: ephem,
        target_body: Astronoby::Moon
      )
      without_ephem = described_class.build_from_astrometric(
        instant: instant,
        target_astrometric: moon.astrometric,
        earth_geometric: moon.earth_geometric,
        target_body: Astronoby::Moon
      )

      expect(with_ephem.position.map(&:m).to_a)
        .to eq(without_ephem.position.map(&:m).to_a)
    end

    it "deflects the light of a planet when given the ephemeris" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      ephem = test_ephem
      mars = Astronoby::Mars.new(instant: instant, ephem: ephem)

      with_ephem = described_class.build_from_astrometric(
        instant: instant,
        target_astrometric: mars.astrometric,
        earth_geometric: mars.earth_geometric,
        ephem: ephem,
        target_body: Astronoby::Mars
      )
      without_ephem = described_class.build_from_astrometric(
        instant: instant,
        target_astrometric: mars.astrometric,
        earth_geometric: mars.earth_geometric,
        target_body: Astronoby::Mars
      )

      expect(with_ephem.position.map(&:m).to_a)
        .not_to eq(without_ephem.position.map(&:m).to_a)
    end
  end
end
