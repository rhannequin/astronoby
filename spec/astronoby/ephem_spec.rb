# frozen_string_literal: true

RSpec.describe Astronoby::Ephem do
  describe ".download" do
    it "downloads the ephemeris using Ephem" do
      allow(::Ephem::IO::Download).to receive(:call)

      described_class.download(name: "de440t.bsp", target: "tmp/de440t.bsp")

      expect(::Ephem::IO::Download)
        .to have_received(:call)
        .with(name: "de440t.bsp", target: "tmp/de440t.bsp")
    end

    it "returns true if the download is successful" do
      allow(::Ephem::IO::Download)
        .to receive(:call).and_return(double(success?: true))

      result = described_class.download(
        name: "de440t.bsp",
        target: "tmp/de440t.bsp"
      )

      expect(result).to eq(true)
    end

    it "returns false if the download is not successful" do
      allow(::Ephem::IO::Download)
        .to receive(:call).and_return(double(success?: false))

      result = described_class.download(
        name: "de440t.bsp",
        target: "tmp/de440t.bsp"
      )

      expect(result).to eq(false)
    end
  end

  describe ".load" do
    it "loads the ephemeris using Ephem" do
      allow(::Ephem::SPK).to receive(:open)

      described_class.load("tmp/de440.bsp")

      expect(::Ephem::SPK).to have_received(:open).with("tmp/de440.bsp")
    end
  end
end
