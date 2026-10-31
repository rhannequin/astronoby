# frozen_string_literal: true

RSpec.describe Astronoby::Constellations::Data do
  describe ".read_file" do
    it "reads the data files whatever the default external encoding" do
      default_external = Encoding.default_external
      Encoding.default_external = Encoding::US_ASCII

      lines = described_class.read_file("constellation_names.dat")

      expect(lines).to all(be_valid_encoding)
      expect(lines.join).to include("Cassiopeia")
    ensure
      Encoding.default_external = default_external
    end
  end
end
