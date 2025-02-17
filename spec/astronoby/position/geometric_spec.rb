# frozen_string_literal: true

RSpec.describe Astronoby::Position::Geometric do
  describe "#to_astrometric" do
    it "returns an Astrometric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: double(x: 1, y: 2, z: 3),
        velocity: double(x: 4, y: 5, z: 6)
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      geometric = Astronoby::Jupiter.geometric(
        ephem: ephem,
        instant: instant
      )
      earth_double = instance_double(
        described_class,
        position: Astronoby::Vector[
          Astronoby::Distance.zero,
          Astronoby::Distance.zero,
          Astronoby::Distance.zero
        ],
        velocity: Astronoby::Vector[
          Astronoby::Velocity.zero,
          Astronoby::Velocity.zero,
          Astronoby::Velocity.zero
        ],
        instant: instant
      )
      allow(Astronoby::Earth).to receive(:geometric).and_return(earth_double)
      allow(Astronoby::Correction::LightTimeDelay).to(
        receive(:compute)
          .and_return([geometric.position, geometric.velocity])
      )

      astrometric = geometric.to_astrometric(ephem: ephem)

      expect(astrometric).to be_a(Astronoby::Position::Astrometric)
    end

    it "returns an Astrometric position with the correct position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: double(x: 1000, y: 2000, z: 3000),
        velocity: double(x: 86.4, y: 172.8, z: 259.2)
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      geometric = Astronoby::Jupiter.geometric(
        ephem: ephem,
        instant: instant
      )
      earth_double = instance_double(
        described_class,
        position: Astronoby::Vector[
          Astronoby::Distance.from_km(5),
          Astronoby::Distance.from_km(5),
          Astronoby::Distance.from_km(5)
        ],
        velocity: Astronoby::Vector[
          Astronoby::Velocity.from_mps(10),
          Astronoby::Velocity.from_mps(20),
          Astronoby::Velocity.from_mps(30)
        ],
        instant: instant
      )
      allow(Astronoby::Earth).to receive(:geometric).and_return(earth_double)
      allow(Astronoby::Correction::LightTimeDelay).to(
        receive(:compute)
          .and_return([geometric.position, geometric.velocity])
      )

      astrometric = geometric.to_astrometric(ephem: ephem)

      expect(astrometric.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(995),
            Astronoby::Distance.from_kilometers(1995),
            Astronoby::Distance.from_kilometers(2995)
          ]
        )
      expect(astrometric.velocity)
        .to eq(
          Astronoby::Vector[
            Astronoby::Velocity.from_mps(-9),
            Astronoby::Velocity.from_mps(-18),
            Astronoby::Velocity.from_mps(-27)
          ]
        )
    end

    it "uses the light-time delay correction" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: double(x: 100, y: 200, z: 300),
        velocity: double(x: 1, y: 2, z: 3)
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      geometric = Astronoby::Jupiter.geometric(
        ephem: ephem,
        instant: instant
      )
      earth_double = instance_double(
        described_class,
        position: Astronoby::Vector[
          Astronoby::Distance.from_km(5),
          Astronoby::Distance.from_km(5),
          Astronoby::Distance.from_km(5)
        ],
        velocity: Astronoby::Vector[
          Astronoby::Velocity.from_mps(1),
          Astronoby::Velocity.from_mps(2),
          Astronoby::Velocity.from_mps(3)
        ],
        instant: instant
      )
      allow(Astronoby::Earth).to receive(:geometric).and_return(earth_double)
      allow(Astronoby::Correction::LightTimeDelay)
        .to receive(:compute).and_return(
          [
            Astronoby::Vector[
              Astronoby::Distance.from_km(50),
              Astronoby::Distance.from_km(100),
              Astronoby::Distance.from_km(150)
            ],
            Astronoby::Vector[
              Astronoby::Velocity.from_mps(3),
              Astronoby::Velocity.from_mps(6),
              Astronoby::Velocity.from_mps(9)
            ]
          ]
        )

      astrometric = geometric.to_astrometric(ephem: ephem)

      expect(astrometric.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(45),
            Astronoby::Distance.from_kilometers(95),
            Astronoby::Distance.from_kilometers(145)
          ]
        )

      expect(astrometric.velocity)
        .to eq(
          Astronoby::Vector[
            Astronoby::Velocity.from_mps(2),
            Astronoby::Velocity.from_mps(4),
            Astronoby::Velocity.from_mps(6)
          ]
        )
    end
  end
end
