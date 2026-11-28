# frozen_string_literal: true

RSpec.describe Astronoby::Ephem do
  include TestEphemHelper

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

    it "raises Ephem's error if the download fails" do
      allow(::Ephem::Download)
        .to receive(:call)
        .and_raise(::Ephem::DownloadError, "404 Not Found")

      expect {
        described_class.download(name: "de440t.bsp", target: "tmp/de440t.bsp")
      }.to raise_error(::Ephem::DownloadError, "404 Not Found")
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

  describe "#[]" do
    it "finds a segment in any of the kernels" do
      sun_only = test_ephem_sun
      planets = test_ephem
      ephem = described_class.new(sun_only, planets)

      expect(ephem[0, 4]).to be(planets[0, 4])
    end

    it "reads a date covered by several kernels from the first one" do
      sun_only = test_ephem_sun
      planets = test_ephem
      ephem = described_class.new(sun_only, planets)
      tdb = Astronoby::Instant.from_time(Time.utc(2025, 6, 1)).tt
      allow(sun_only[0, 10]).to receive(:compute).and_call_original
      allow(planets[0, 10]).to receive(:compute).and_call_original

      ephem[0, 10].position_at(tdb)

      expect(sun_only[0, 10]).to have_received(:compute)
      expect(planets[0, 10]).not_to have_received(:compute)
    end

    it "reads a date the first kernel does not cover from the next one" do
      planets = test_ephem
      sun_only = test_ephem_sun
      ephem = described_class.new(planets, sun_only)
      tdb = Astronoby::Instant.from_time(Time.utc(2028, 1, 1)).tt
      allow(sun_only[0, 10]).to receive(:compute).and_call_original

      ephem[0, 10].position_at(tdb)

      expect(sun_only[0, 10]).to have_received(:compute)
    end

    it "raises KeyError when no kernel has the segment" do
      ephem = described_class.new(test_ephem_sun)

      expect { ephem[0, 4] }.to raise_error(
        KeyError,
        "No kernel has a segment for center: 0, target: 4"
      )
    end
  end

  describe "#type" do
    it "returns the kernels' type" do
      ephem = described_class.new(test_ephem_sun, test_ephem)

      expect(ephem.type).to eq(::Ephem::SPK::JPL_DE)
    end
  end

  describe "#initialize" do
    it "raises without kernels" do
      expect { described_class.new }
        .to raise_error(ArgumentError, "At least one kernel is required")
    end

    it "raises with kernels of different types" do
      expect { described_class.new(test_ephem, test_ephem_inpop) }
        .to raise_error(
          ArgumentError,
          "Kernels of different types cannot be combined: JPL DE, IMCCE INPOP"
        )
    end

    it "raises when no kernel is of a supported type" do
      untyped = double(type: nil, segments: [])

      expect { described_class.new(untyped) }.to raise_error(
        Astronoby::EphemerisError,
        "No kernel is of a supported type. Accepted: IMCCE INPOP, JPL DE"
      )
    end
  end

  describe "#coverage" do
    it "returns the dates every pair covers, after the light time" do
      ephem = described_class.new(test_ephem)

      first, last = ephem.coverage

      expect(first).to eq(2460676.75)
      expect(last).to eq(2461044.5)
    end

    it "ignores the pairs no body reads" do
      kernel = kernel_with(segment(0, 10, 0.0, 300.0), segment(4, 499, 0.0, 100.0))
      ephem = described_class.new(kernel)

      expect(ephem.coverage).to eq([0.25, 300.0])
    end

    it "joins the kernels that cover a pair one after the other" do
      ephem = described_class.new(
        kernel_with(segment(0, 10, 0.0, 100.0)),
        kernel_with(segment(0, 10, 100.0, 300.0))
      )

      expect(ephem.coverage).to eq([0.25, 300.0])
    end

    it "keeps the longest span when the kernels leave a gap" do
      ephem = described_class.new(
        kernel_with(segment(0, 10, 0.0, 100.0)),
        kernel_with(segment(0, 10, 200.0, 500.0))
      )

      expect(ephem.coverage).to eq([200.25, 500.0])
    end

    it "keeps the dates every pair read covers" do
      ephem = described_class.new(
        kernel_with(segment(0, 10, 0.0, 300.0), segment(0, 4, 50.0, 200.0))
      )

      expect(ephem.coverage).to eq([50.25, 200.0])
    end
  end

  describe "#close" do
    it "closes every kernel" do
      first = double(type: ::Ephem::SPK::JPL_DE, segments: [], close: nil)
      second = double(type: ::Ephem::SPK::JPL_DE, segments: [], close: nil)
      ephem = described_class.new(first, second)

      ephem.close

      expect(first).to have_received(:close)
      expect(second).to have_received(:close)
    end
  end

  describe "#inspect" do
    it "shows the type and the number of kernels" do
      ephem = described_class.new(test_ephem_sun, test_ephem)

      expect(ephem.inspect).to eq("#<Astronoby::Ephem JPL DE, 2 kernels>")
    end
  end

  def kernel_with(*segments)
    double(type: ::Ephem::SPK::JPL_DE, segments: segments)
  end

  def segment(center, target, start_jd, end_jd)
    double(center: center, target: target, start_jd: start_jd, end_jd: end_jd)
  end
end
