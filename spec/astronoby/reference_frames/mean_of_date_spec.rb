# frozen_string_literal: true

RSpec.describe Astronoby::MeanOfDate do
  describe "::build_from_geometric" do
    it "returns a MeanOfDate position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: double(x: 1, y: 2, z: 3),
        velocity: double(x: 4, y: 5, z: 6)
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
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

      mean_of_date = described_class.build_from_geometric(
        instant: instant,
        target_geometric: geometric,
        earth_geometric: earth_double,
        target_body: Astronoby::Jupiter
      )

      expect(mean_of_date).to be_a(Astronoby::MeanOfDate)
    end

    it "returns a MeanOfDate position with the correct position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: double(x: 1000, y: 2000, z: 3000),
        velocity: double(x: 86.4, y: 172.8, z: 259.2)
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment, :type => ::Ephem::SPK::JPL_DE)
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
      allow(Astronoby::Precession).to receive(:matrix_for).and_return(
        Matrix[[1, 0, 0], [0, 1, 0], [0, 0, 1]]
      )

      mean_of_date = described_class.build_from_geometric(
        instant: instant,
        target_geometric: geometric,
        earth_geometric: earth_double,
        target_body: Astronoby::Jupiter
      )

      expect(mean_of_date.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(995),
            Astronoby::Distance.from_kilometers(1995),
            Astronoby::Distance.from_kilometers(2995)
          ]
        )
      expect(mean_of_date.velocity)
        .to eq(
          Astronoby::Vector[
            Astronoby::Velocity.from_mps(-9),
            Astronoby::Velocity.from_mps(-18),
            Astronoby::Velocity.from_mps(-27)
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
      mean_of_date = described_class.new(
        position: position,
        velocity: kind_of(Vector),
        instant: kind_of(Astronoby::Instant),
        center_identifier: Astronoby::SolarSystemBody::EARTH,
        target_body: Astronoby::Jupiter
      )

      expect(mean_of_date.equatorial).to be_a(Astronoby::Coordinates::Equatorial)
    end
  end

  describe "#distance" do
    it "extracts the distance from Cartesian coordinates" do
      position = Astronoby::Vector[
        Astronoby::Distance.from_kilometers(2),
        Astronoby::Distance.from_kilometers(2),
        Astronoby::Distance.from_kilometers(1)
      ]
      mean_of_date = described_class.new(
        position: position,
        velocity: kind_of(Vector),
        instant: kind_of(Astronoby::Instant),
        center_identifier: Astronoby::SolarSystemBody::EARTH,
        target_body: Astronoby::Jupiter
      )

      expect(mean_of_date.distance).to eq(Astronoby::Distance.from_kilometers(3))
    end

    context "when the distance is null" do
      it "returns a null distance" do
        position = Astronoby::Vector[
          Astronoby::Distance.zero,
          Astronoby::Distance.zero,
          Astronoby::Distance.zero
        ]
        mean_of_date = described_class.new(
          position: position,
          velocity: kind_of(Vector),
          instant: kind_of(Astronoby::Instant),
          center_identifier: Astronoby::SolarSystemBody::EARTH,
          target_body: Astronoby::Jupiter
        )

        expect(mean_of_date.distance).to eq(Astronoby::Distance.zero)
      end
    end
  end
end
