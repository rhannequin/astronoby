# frozen_string_literal: true

RSpec.describe Astronoby::Mercury do
  describe "#barycentric" do
    it "returns a Barycentric position" do
      time = Time.utc(2025, 2, 7, 12)
      instant = Astronoby::Instant.from_time(time)
      state = double(position: Vector[1, 2, 3], velocity: Vector[4, 5, 6])
      segment = double(compute_and_differentiate: state)
      ephem = double(:[] => segment)
      mercury = described_class.new(instant: instant, ephem: ephem)

      barycentric = mercury.barycentric

      expect(barycentric).to be_a(Astronoby::Position::Barycentric)
      expect(barycentric.position).to eq(Vector[2, 4, 6])
      expect(barycentric.velocity).to eq(Vector[8, 10, 12])
    end
  end
end
