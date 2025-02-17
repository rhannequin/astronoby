# frozen_string_literal: true

RSpec.describe Astronoby::Planet do
  describe "::geometric" do
    it "returns a Geometric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)

      geometric = build_planet.geometric(instant: instant, ephem: ephem)

      expect(geometric).to be_a(Astronoby::Position::Geometric)
    end

    it "returns a Geometric position with the correct position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Astronoby::Vector[1, 2, 3],
        velocity: Astronoby::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)

      geometric = build_planet.geometric(instant: instant, ephem: ephem)

      expect(geometric.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(1),
            Astronoby::Distance.from_kilometers(2),
            Astronoby::Distance.from_kilometers(3)
          ]
        )
      expect(geometric.velocity)
        .to eq(
          Astronoby::Vector[
            Astronoby::Velocity.from_kilometers_per_day(4),
            Astronoby::Velocity.from_kilometers_per_day(5),
            Astronoby::Velocity.from_kilometers_per_day(6)
          ]
        )
    end

    it "returns a Geometric position with the correct instant" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Astronoby::Vector[1, 2, 3],
        velocity: Astronoby::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)

      geometric = build_planet.geometric(instant: instant, ephem: ephem)

      expect(geometric.instant).to eq(instant)
    end

    context "when the planet has multiple segments" do
      it "returns a Geometric position with the correct position" do
        time = Time.utc(2025, 2, 7, 12)
        instant = Astronoby::Instant.from_time(time)
        state1 = double(
          position: Astronoby::Vector[1, 2, 3],
          velocity: Astronoby::Vector[4, 5, 6]
        )
        state2 = double(
          position: Astronoby::Vector[7, 8, 9],
          velocity: Astronoby::Vector[10, 11, 12]
        )
        segment1 = double(compute_and_differentiate: state1)
        segment2 = double(compute_and_differentiate: state2)
        ephem = double
        allow(ephem).to receive(:[]).with(0).and_return(segment1)
        allow(ephem).to receive(:[]).with(1).and_return(segment2)

        geometric = build_planet_with_multiple_segments.geometric(
          instant: instant,
          ephem: ephem
        )

        expect(geometric.position)
          .to eq(
            Astronoby::Vector[
              Astronoby::Distance.from_kilometers(8),
              Astronoby::Distance.from_kilometers(10),
              Astronoby::Distance.from_kilometers(12)
            ]
          )
        expect(geometric.velocity)
          .to eq(
            Astronoby::Vector[
              Astronoby::Velocity.from_kilometers_per_day(14),
              Astronoby::Velocity.from_kilometers_per_day(16),
              Astronoby::Velocity.from_kilometers_per_day(18)
            ]
          )
      end
    end

    context "when the planet doesn't implement #ephemeris_segments" do
      it "raises NotImplementedError" do
        time = Time.utc(2025, 2, 7, 12)
        instant = Astronoby::Instant.from_time(time)
        ephem = double

        expect do
          build_planet_with_no_segments
            .geometric(instant: instant, ephem: ephem)
        end.to raise_error(NotImplementedError)
      end
    end
  end

  def build_planet
    @planet ||=
      Class.new(described_class) do
        def self.ephemeris_segments
          [0]
        end
      end
  end

  def build_planet_with_multiple_segments
    Class.new(described_class) do
      def self.ephemeris_segments
        [[0], [1]]
      end
    end
  end

  def build_planet_with_no_segments
    Class.new(described_class) do
    end
  end
end
