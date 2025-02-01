# frozen_string_literal: true

RSpec.describe Astronoby::Venus do
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
      venus = described_class.new(instant: instant, ephem: ephem)

      barycentric = venus.barycentric

      expect(barycentric).to be_a(Astronoby::Position::Barycentric)
      expect(barycentric.position)
        .to eq(
          Astronoby::Vector[
            Astronoby::Distance.from_kilometers(2),
            Astronoby::Distance.from_kilometers(4),
            Astronoby::Distance.from_kilometers(6)
          ]
        )
      expect(barycentric.velocity).to eq(Astronoby::Vector[8, 10, 12])
    end
  end
end
