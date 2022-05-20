# frozen_string_literal: true

RSpec.describe Astronoby::Dms do
  let(:instance) { described_class.new(10, 11, 12.5) }

  describe "#format" do
    subject { instance.format }

    it "formats properly" do
      expect(subject).to eq("10° 11′ 12.5″")
    end
  end
end
