# frozen_string_literal: true

RSpec.describe Astronoby::Position::Barycentric do
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
      barycentric = Astronoby::Jupiter.barycentric(
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
        instant: instant
      )
      allow(Astronoby::Earth).to receive(:barycentric).and_return(earth_double)
      allow(Astronoby::Correction::LightTimeDelay)
        .to receive(:compute).and_return(barycentric.position)

      astrometric = barycentric.to_astrometric(ephem: ephem)

      expect(astrometric).to be_a(Astronoby::Position::Astrometric)
    end

    it "returns an Astrometric position with the correct position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: double(x: 100, y: 200, z: 300),
        velocity: double(x: 4, y: 5, z: 6)
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      barycentric = Astronoby::Jupiter.barycentric(
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
        instant: instant
      )
      allow(Astronoby::Earth).to receive(:barycentric).and_return(earth_double)
      allow(Astronoby::Correction::LightTimeDelay)
        .to receive(:compute).and_return(barycentric.position)

      astrometric = barycentric.to_astrometric(ephem: ephem)

      expect(astrometric.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(95),
            Astronoby::Distance.from_kilometers(195),
            Astronoby::Distance.from_kilometers(295)
          ]
        )
    end

    it "uses the light-time delay correction" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: double(x: 100, y: 200, z: 300),
        velocity: double(x: 4, y: 5, z: 6)
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      barycentric = Astronoby::Jupiter.barycentric(
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
        instant: instant
      )
      allow(Astronoby::Earth).to receive(:barycentric).and_return(earth_double)
      allow(Astronoby::Correction::LightTimeDelay)
        .to receive(:compute).and_return(
          Astronoby::Vector[
            Astronoby::Distance.from_km(50),
            Astronoby::Distance.from_km(100),
            Astronoby::Distance.from_km(150)
          ]
        )

      astrometric = barycentric.to_astrometric(ephem: ephem)

      expect(astrometric.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(45),
            Astronoby::Distance.from_kilometers(95),
            Astronoby::Distance.from_kilometers(145)
          ]
        )
    end
  end
end
