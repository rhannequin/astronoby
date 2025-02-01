# frozen_string_literal: true

RSpec.describe Astronoby::Planet do
  describe "#barycentric" do
    it "returns a Barycentric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Ephem::Core::Vector[1, 2, 3],
        velocity: Ephem::Core::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      planet = build_planet.new(instant: instant, ephem: ephem)

      barycentric = planet.barycentric

      expect(barycentric).to be_a(Astronoby::Position::Barycentric)
    end

    it "returns a Barycentric position with the correct position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Astronoby::Vector[1, 2, 3],
        velocity: Astronoby::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      planet = build_planet.new(instant: instant, ephem: ephem)

      barycentric = planet.barycentric

      expect(barycentric.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(1),
            Astronoby::Distance.from_kilometers(2),
            Astronoby::Distance.from_kilometers(3)
          ]
        )
      expect(barycentric.velocity).to eq(Astronoby::Vector[4, 5, 6])
    end

    it "returns a Barycentric position with the correct instant" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Astronoby::Vector[1, 2, 3],
        velocity: Astronoby::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      planet = build_planet.new(instant: instant, ephem: ephem)

      barycentric = planet.barycentric

      expect(barycentric.instant).to eq(instant)
    end

    it "returns a Barycentric position with the correct target_body" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(
        position: Astronoby::Vector[1, 2, 3],
        velocity: Astronoby::Vector[4, 5, 6]
      )
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      planet = build_planet.new(instant: instant, ephem: ephem)

      barycentric = planet.barycentric

      expect(barycentric.target_body).to eq(planet.class)
    end

    context "when the planet has multiple segments" do
      it "returns a Barycentric position with the correct position" do
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
        planet = build_planet_with_multiple_segments
          .new(instant: instant, ephem: ephem)

        barycentric = planet.barycentric

        expect(barycentric.position)
          .to eq(
            Astronoby::Vector[
              Astronoby::Distance.from_kilometers(8),
              Astronoby::Distance.from_kilometers(10),
              Astronoby::Distance.from_kilometers(12)
            ]
          )
        expect(barycentric.velocity).to eq(Astronoby::Vector[14, 16, 18])
      end
    end

    context "when the planet doesn't implement #ephemeris_segments" do
      it "raises NotImplementedError" do
        time = Time.utc(2025, 2, 7, 12)
        instant = Astronoby::Instant.from_time(time)
        ephem = double

        expect do
          build_planet_with_no_segments
            .new(instant: instant, ephem: ephem)
            .barycentric
        end.to raise_error(NotImplementedError)
      end
    end
  end

  def build_planet
    Class.new(described_class) do
      private

      def ephemeris_segments
        [0]
      end
    end
  end

  def build_planet_with_multiple_segments
    Class.new(described_class) do
      private

      def ephemeris_segments
        [[0], [1]]
      end
    end
  end

  def build_planet_with_no_segments
    Class.new(described_class) do
    end
  end
end
