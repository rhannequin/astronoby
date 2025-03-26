# frozen_string_literal: true

RSpec.describe Astronoby::Astrometric do
  describe "::build_from_geometric" do
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

      astrometric = described_class.build_from_geometric(
        instant: instant,
        earth_geometric: earth_double,
        light_time_corrected_position: geometric.position,
        light_time_corrected_velocity: geometric.velocity,
        target_body: Astronoby::Jupiter
      )

      expect(astrometric).to be_a(Astronoby::Astrometric)
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

      astrometric = described_class.build_from_geometric(
        instant: instant,
        earth_geometric: earth_double,
        light_time_corrected_position: geometric.position,
        light_time_corrected_velocity: geometric.velocity,
        target_body: Astronoby::Jupiter
      )

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
      Astronoby::Jupiter.geometric(
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
      light_time_corrected_position = Astronoby::Vector[
        Astronoby::Distance.from_km(50),
        Astronoby::Distance.from_km(100),
        Astronoby::Distance.from_km(150)
      ]
      light_time_corrected_velocity = Astronoby::Vector[
        Astronoby::Velocity.from_mps(3),
        Astronoby::Velocity.from_mps(6),
        Astronoby::Velocity.from_mps(9)
      ]
      allow(Astronoby::Earth).to receive(:geometric).and_return(earth_double)

      astrometric = described_class.build_from_geometric(
        instant: instant,
        earth_geometric: earth_double,
        light_time_corrected_position: light_time_corrected_position,
        light_time_corrected_velocity: light_time_corrected_velocity,
        target_body: Astronoby::Jupiter
      )

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

  describe "#equatorial" do
    it "returns equatorial coordinates" do
      position = Astronoby::Vector[
        Astronoby::Distance.from_kilometers(1),
        Astronoby::Distance.from_kilometers(1),
        Astronoby::Distance.from_kilometers(1)
      ]
      astrometric = described_class.new(
        position: position,
        velocity: kind_of(Vector),
        instant: kind_of(Astronoby::Instant),
        center_identifier: Astronoby::SolarSystemBody::EARTH,
        target_body: Astronoby::Jupiter
      )

      expect(astrometric.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
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
        center_identifier: Astronoby::SolarSystemBody::EARTH,
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
          center_identifier: Astronoby::SolarSystemBody::EARTH,
          target_body: Astronoby::Jupiter
        )

        expect(astrometric.distance).to eq(Astronoby::Distance.zero)
      end
    end
  end
end
