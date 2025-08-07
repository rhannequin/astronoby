# frozen_string_literal: true

RSpec.describe Astronoby::Constellations::Repository do
  describe ".get" do
    it "returns a constellation object for a valid abbreviation" do
      %w[
        And Ant Aps Aql Aqr Ara Ari Aur Boo CMa CMi CVn Cae Cam Cap Car Cas Cen
        Cep Cet Cha Cir Cnc Col Com CrA CrB Crt Cru Crv Cyg Del Dor Dra Equ Eri
        For Gem Gru Her Hor Hya Hyi Ind LMi Lac Leo Lep Lib Lup Lyn Lyr Men Mic
        Mon Mus Nor Oct Oph Ori Pav Peg Per Phe Pic PsA Psc Pup Pyx Ret Scl Sco
        Sct Ser Sex Sge Sgr Tau Tel TrA Tri Tuc UMa UMi Vel Vir Vol Vul
      ].each do |abbreviation|
        constellation = described_class.get(abbreviation)

        expect(constellation).to be_a(Astronoby::Constellation)
        expect(constellation.abbreviation).to eq(abbreviation)
      end
    end

    it "returns nil for an invalid abbreviation" do
      expect(described_class.get("Xyz")).to be_nil
    end
  end
end
