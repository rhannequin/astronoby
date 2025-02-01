# frozen_string_literal: true

RSpec.describe Astronoby::Jupiter do
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
      jupiter = described_class.new(instant: instant, ephem: ephem)

      barycentric = jupiter.barycentric

      expect(barycentric).to be_a(Astronoby::Position::Barycentric)
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
  end
end
