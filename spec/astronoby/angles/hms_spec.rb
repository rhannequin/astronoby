# frozen_string_literal: true

RSpec.describe Astronoby::Hms do
  describe "#format" do
    it "formats properly" do
      expect(described_class.new(10, 11, 12.5).format).to eq("10h 11m 12.5s")
    end
  end
end
