# frozen_string_literal: true

RSpec.describe Astronoby::Ephem do
  describe ".download" do
    it "downloads the ephemeris using Ephem" do
      allow(::Ephem::Download).to receive(:call)

      described_class.download(name: "de440t.bsp", target: "tmp/de440t.bsp")

      expect(::Ephem::Download)
        .to have_received(:call)
        .with(name: "de440t.bsp", target: "tmp/de440t.bsp")
    end

    it "returns true if the download is successful" do
      allow(::Ephem::Download).to receive(:call).and_return(true)

      result = described_class.download(
        name: "de440t.bsp",
        target: "tmp/de440t.bsp"
      )

      expect(result).to eq(true)
    end

    it "returns false if the download is not successful" do
      allow(::Ephem::Download).to receive(:call).and_return(false)

      result = described_class.download(
        name: "de440t.bsp",
        target: "tmp/de440t.bsp"
      )

      expect(result).to eq(false)
    end
  end

  describe ".load" do
    it "loads the ephemeris using Ephem" do
      spk_double = double(type: ::Ephem::SPK::JPL_DE)
      allow(::Ephem::SPK).to receive(:open).and_return(spk_double)

      described_class.load("tmp/de440.bsp")

      expect(::Ephem::SPK).to have_received(:open).with("tmp/de440.bsp")
    end

    context "when the ephemeris type is not supported" do
      it "raises an EphemerisError" do
        spk_double = double(type: "Unsupported Type")
        allow(::Ephem::SPK).to receive(:open).and_return(spk_double)

        expect {
          described_class.load("tmp/de440.bsp")
        }.to raise_error(
          Astronoby::EphemerisError,
          "tmp/de440.bsp is not a valid type. Accepted: IMCCE INPOP, JPL DE"
        )
      end
    end
  end
end
