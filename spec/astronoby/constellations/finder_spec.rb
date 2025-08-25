# frozen_string_literal: true

RSpec.describe Astronoby::Constellations::Finder do
  describe ".find" do
    it "returns the right constellation for a given equatorial coordinates" do
      stars = [
        # Andromeda (And)
        [[0, 8, 23.26], [29, 5, 25.6], "And"],      # Alpheratz
        [[1, 9, 43.92], [35, 37, 14.0], "And"],     # Mirach

        # Antlia (Ant)
        [[10, 27, 9.37], [-31, 4, 4.1], "Ant"],     # Alpha Antliae
        [[9, 29, 14.54], [-35, 57, 2.9], "Ant"],    # Epsilon Antliae

        # Apus (Aps)
        [[14, 47, 51.58], [-79, 2, 40.9], "Aps"],   # Alpha Apodis
        [[16, 33, 35.21], [-78, 53, 49.0], "Aps"],  # Gamma Apodis

        # Aquarius (Aqr)
        [[22, 5, 47.02], [-0, 19, 11.4], "Aqr"],    # Sadalmelik
        [[21, 31, 33.52], [-5, 34, 16.2], "Aqr"],   # Sadalsuud

        # Aquila (Aql)
        [[19, 50, 47.00], [8, 52, 5.96], "Aql"],    # Altair
        [[19, 46, 15.61], [10, 36, 47.6], "Aql"],   # Tarazed

        # Ara (Ara)
        [[17, 31, 50.49], [-49, 52, 34.3], "Ara"],  # Alpha Arae
        [[17, 25, 17.96], [-55, 31, 45.6], "Ara"],  # Beta Arae

        # Aries (Ari)
        [[2, 7, 10.41], [23, 27, 44.7], "Ari"],     # Hamal
        [[1, 54, 38.43], [20, 48, 29.0], "Ari"],    # Sheratan

        # Auriga (Aur)
        [[5, 16, 41.36], [45, 59, 52.8], "Aur"],    # Capella
        [[5, 59, 31.72], [44, 56, 50.7], "Aur"],    # Menkalinan

        # Boötes (Boo)
        [[14, 15, 39.67], [19, 10, 56.7], "Boo"],   # Arcturus
        [[14, 44, 59.31], [27, 4, 27.0], "Boo"],    # Izar

        # Canis Major (CMa)
        [[6, 45, 8.92], [-16, 42, 58.0], "CMa"],    # Sirius
        [[6, 58, 37.55], [-28, 58, 19.5], "CMa"],   # Adhara

        # Canis Minor (CMi)
        [[7, 39, 18.12], [5, 13, 29.96], "CMi"],    # Procyon
        [[7, 27, 9.00], [8, 17, 21.9], "CMi"],      # Gomeisa

        # Canes Venatici (CVn)
        [[12, 56, 1.67], [38, 19, 6.2], "CVn"],     # Cor Caroli
        [[12, 45, 7.63], [45, 26, 24.9], "CVn"],    # La Superba

        # Caelum (Cae)
        [[4, 40, 33.68], [-41, 51, 48.6], "Cae"],   # Alpha Caeli
        [[4, 42, 3.17], [-37, 8, 40.7], "Cae"],     # Beta Caeli

        # Camelopardalis (Cam)
        [[5, 3, 25.21], [60, 26, 31.9], "Cam"],     # Beta Camelopardalis
        [[3, 35, 15.83], [59, 56, 7.6], "Cam"],     # CS Camelopardalis

        # Capricornus (Cap)
        [[21, 47, 2.49], [-16, 7, 38.0], "Cap"],    # Deneb Algedi
        [[20, 21, 0.70], [-14, 46, 52.7], "Cap"],   # Dabih

        # Carina (Car)
        [[6, 23, 57.11], [-52, 41, 44.4], "Car"],   # Canopus
        [[9, 13, 12.05], [-69, 43, 1.9], "Car"],    # Miaplacidus

        # Cassiopeia (Cas)
        [[0, 40, 30.44], [56, 32, 14.4], "Cas"],    # Schedar
        [[0, 9, 10.69], [59, 8, 59.2], "Cas"],      # Caph

        # Centaurus (Cen)
        [[14, 39, 36.49], [-60, 50, 2.3], "Cen"],   # Alpha Centauri
        [[14, 3, 49.41], [-60, 22, 22.7], "Cen"],   # Hadar

        # Cepheus (Cep)
        [[21, 18, 34.77], [62, 35, 8.1], "Cep"],    # Alderamin
        [[21, 28, 39.58], [70, 33, 38.5], "Cep"],   # Alfirk

        # Cetus (Cet)
        [[0, 43, 35.37], [-17, 59, 11.8], "Cet"],   # Diphda (Beta Ceti)
        [[3, 2, 16.77], [4, 5, 23.0], "Cet"],       # Menkar

        # Chamaeleon (Cha)
        [[8, 19, 46.49], [-76, 55, 11.8], "Cha"],   # Alpha Chamaeleontis
        [[12, 18, 21.02], [-79, 17, 59.6], "Cha"],  # Beta Chamaeleontis

        # Circinus (Cir)
        [[14, 42, 30.43], [-64, 58, 30.7], "Cir"],  # Alpha Circini
        [[15, 17, 31.06], [-58, 48, 4.5], "Cir"],   # Beta Circini

        # Cancer (Cnc)
        [[8, 58, 29.21], [11, 51, 27.9], "Cnc"],    # Acubens
        [[8, 43, 17.23], [21, 28, 7.7], "Cnc"],     # Asellus Borealis

        # Columba (Col)
        [[5, 39, 38.96], [-34, 4, 27.0], "Col"],    # Phact
        [[5, 50, 57.38], [-35, 46, 8.6], "Col"],    # Wazn

        # Coma Berenices (Com)
        [[13, 9, 59.31], [17, 31, 44.6], "Com"],    # Diadem
        [[13, 11, 52.41], [27, 52, 41.5], "Com"],   # Beta Comae Berenices

        # Corona Australis (CrA)
        [[19, 9, 28.25], [-37, 54, 15.7], "CrA"],   # Alpha Coronae Australis
        [[19, 1, 44.05], [-37, 1, 2.7], "CrA"],     # Beta Coronae Australis

        # Corona Borealis (CrB)
        [[15, 34, 41.25], [26, 42, 52.7], "CrB"],   # Alphecca
        [[15, 27, 49.83], [29, 6, 19.7], "CrB"],    # Nusakan

        # Crater (Crt)
        [[10, 59, 46.41], [-18, 17, 57.8], "Crt"],  # Alkes
        [[11, 11, 39.64], [-22, 49, 32.1], "Crt"],  # Beta Crateris

        # Crux (Cru)
        [[12, 26, 35.89], [-63, 5, 56.7], "Cru"],   # Acrux
        [[12, 47, 43.27], [-59, 41, 19.5], "Cru"],  # Mimosa

        # Corvus (Crv)
        [[12, 8, 24.81], [-24, 43, 44.4], "Crv"],   # Alchiba
        [[12, 15, 48.53], [-17, 32, 30.9], "Crv"],  # Gienah

        # Cygnus (Cyg)
        [[20, 41, 25.915], [45, 16, 49.22], "Cyg"], # Deneb
        [[20, 22, 13.73], [40, 15, 24.1], "Cyg"],   # Sadr

        # Delphinus (Del)
        [[20, 37, 33.02], [14, 35, 42.7], "Del"],   # Rotanev
        [[20, 41, 43.56], [15, 54, 43.7], "Del"],   # Sualocin

        # Dorado (Dor)
        [[4, 34, 0.00], [-55, 2, 42.4], "Dor"],     # Alpha Doradus
        [[5, 33, 37.52], [-62, 29, 23.2], "Dor"],   # Beta Doradus

        # Draco (Dra)
        [[17, 56, 36.36], [51, 29, 20.0], "Dra"],   # Eltanin
        [[14, 4, 23.34], [64, 22, 33.1], "Dra"],    # Thuban

        # Equuleus (Equ)
        [[21, 15, 49.33], [5, 14, 52.9], "Equ"],    # Kitalpha
        [[21, 14, 17.25], [6, 48, 40.2], "Equ"],    # Beta Equulei

        # Eridanus (Eri)
        [[1, 37, 42.85], [-57, 14, 12.3], "Eri"],   # Achernar
        [[5, 7, 50.91], [-5, 5, 11.2], "Eri"],      # Cursa

        # Fornax (For)
        [[3, 12, 4.41], [-28, 59, 16.1], "For"],    # Alpha Fornacis
        [[2, 49, 3.98], [-32, 24, 21.2], "For"],    # Beta Fornacis

        # Gemini (Gem)
        [[7, 34, 36.00], [31, 53, 17.8], "Gem"],    # Castor
        [[7, 45, 18.95], [28, 1, 34.3], "Gem"],     # Pollux

        # Grus (Gru)
        [[22, 8, 13.93], [-46, 57, 39.8], "Gru"],   # Alnair
        [[22, 42, 40.05], [-46, 53, 4.3], "Gru"],   # Beta Gruis

        # Hercules (Her)
        [[17, 14, 38.86], [14, 23, 25.1], "Her"],   # Rasalgethi
        [[16, 30, 13.23], [21, 29, 22.6], "Her"],   # Kornephoros

        # Horologium (Hor)
        [[4, 14, 0.44], [-42, 17, 38.1], "Hor"],    # Alpha Horologii
        [[2, 59, 51.04], [-64, 4, 14.3], "Hor"],    # Beta Horologii

        # Hydra (Hya)
        [[9, 27, 35.24], [-8, 39, 30.9], "Hya"],    # Alphard
        [[13, 18, 55.36], [-23, 10, 18.3], "Hya"],  # Gamma Hydrae

        # Hydrus (Hyi)
        [[1, 58, 45.79], [-61, 34, 11.7], "Hyi"],   # Alpha Hydri
        [[0, 25, 45.08], [-77, 15, 15.3], "Hyi"],   # Beta Hydri

        # Indus (Ind)
        [[20, 37, 34.02], [-47, 17, 29.0], "Ind"],  # Alpha Indi
        [[20, 54, 48.62], [-58, 27, 15.4], "Ind"],  # Beta Indi

        # Leo Minor (LMi)
        [[10, 53, 18.63], [34, 12, 55.8], "LMi"],   # Praecipua (46 LMi)
        [[10, 27, 53.10], [36, 42, 25.8], "LMi"],   # Beta Leonis Minoris

        # Lacerta (Lac)
        [[22, 31, 17.31], [50, 16, 56.6], "Lac"],   # Alpha Lacertae
        [[22, 23, 33.68], [52, 13, 44.5], "Lac"],   # Beta Lacertae

        # Leo (Leo)
        [[10, 8, 22.31], [11, 58, 1.9], "Leo"],     # Regulus
        [[11, 49, 3.58], [14, 34, 19.4], "Leo"],    # Denebola

        # Lepus (Lep)
        [[5, 32, 43.82], [-17, 49, 20.3], "Lep"],   # Arneb
        [[5, 28, 14.91], [-20, 45, 33.4], "Lep"],   # Nihal

        # Libra (Lib)
        [[14, 50, 52.72], [-16, 2, 30.0], "Lib"],   # Zubenelgenubi
        [[15, 17, 0.79], [-9, 22, 58.0], "Lib"],    # Zubeneschamali

        # Lupus (Lup)
        [[14, 41, 55.77], [-47, 23, 17.5], "Lup"],  # Alpha Lupi
        [[14, 58, 31.89], [-43, 8, 2.1], "Lup"],    # Beta Lupi

        # Lynx (Lyn)
        [[9, 21, 2.64], [34, 25, 33.2], "Lyn"],     # Alpha Lyncis
        [[9, 18, 43.06], [36, 47, 41.5], "Lyn"],    # 38 Lyncis

        # Lyra (Lyr)
        [[18, 36, 56.34], [38, 47, 1.3], "Lyr"],    # Vega
        [[18, 50, 5.01], [33, 21, 45.7], "Lyr"],    # Sheliak

        # Mensa (Men)
        [[6, 10, 14.21], [-74, 45, 11.0], "Men"],   # Alpha Mensae
        [[5, 18, 30.54], [-71, 18, 51.5], "Men"],   # Beta Mensae

        # Microscopium (Mic)
        [[20, 50, 0.94], [-33, 46, 46.7], "Mic"],   # Alpha Microscopii
        [[20, 47, 43.92], [-32, 15, 26.4], "Mic"],  # Gamma Microscopii

        # Monoceros (Mon)
        [[7, 41, 14.66], [-9, 33, 5.0], "Mon"],     # Alpha Monocerotis
        [[6, 28, 49.26], [-7, 1, 58.7], "Mon"],     # Beta Monocerotis

        # Musca (Mus)
        [[12, 37, 11.13], [-69, 8, 8.2], "Mus"],    # Alpha Muscae
        [[12, 46, 16.95], [-68, 6, 29.4], "Mus"],   # Beta Muscae

        # Norma (Nor)
        [[16, 19, 50.48], [-50, 9, 20.0], "Nor"],   # Gamma2 Normae
        [[16, 0, 24.46], [-44, 4, 29.5], "Nor"],    # Beta Normae

        # Octans (Oct)
        [[21, 41, 28.64], [-77, 23, 23.7], "Oct"],  # Nu Octantis
        [[21, 57, 24.49], [-81, 22, 55.8], "Oct"],  # Beta Octantis

        # Ophiuchus (Oph)
        [[17, 34, 56.13], [12, 33, 36.1], "Oph"],   # Rasalhague
        [[17, 43, 28.22], [4, 34, 2.3], "Oph"],     # Cebalrai

        # Orion (Ori)
        [[5, 14, 32.27], [-8, 12, 5.9], "Ori"],     # Rigel
        [[5, 55, 10.31], [7, 24, 25.4], "Ori"],     # Betelgeuse

        # Pavo (Pav)
        [[20, 25, 38.87], [-56, 44, 6.3], "Pav"],   # Peacock
        [[20, 44, 58.51], [-66, 12, 11.3], "Pav"],  # Beta Pavonis

        # Pegasus (Peg)
        [[23, 4, 45.66], [15, 12, 19.0], "Peg"],    # Markab
        [[21, 44, 11.15], [9, 52, 30.0], "Peg"],    # Enif

        # Perseus (Per)
        [[3, 24, 19.39], [49, 51, 40.2], "Per"],    # Mirfak
        [[3, 8, 10.13], [40, 57, 20.3], "Per"],     # Algol

        # Phoenix (Phe)
        [[0, 26, 17.06], [-42, 18, 21.0], "Phe"],   # Ankaa
        [[1, 6, 5.07], [-46, 43, 4.9], "Phe"],      # Beta Phoenicis

        # Pictor (Pic)
        [[6, 48, 33.10], [-61, 56, 31.2], "Pic"],   # Alpha Pictoris
        [[5, 47, 17.09], [-51, 3, 59.4], "Pic"],    # Beta Pictoris

        # Piscis Austrinus (PsA)
        [[22, 57, 39.05], [-29, 37, 20.1], "PsA"],  # Fomalhaut
        [[22, 39, 30.74], [-28, 16, 5.1], "PsA"],   # Epsilon PsA

        # Pisces (Psc)
        [[1, 31, 29.00], [15, 20, 45.1], "Psc"],    # Eta Piscium
        [[2, 2, 5.12], [2, 45, 49.5], "Psc"],       # Alrescha
        # Test star near 24h RA (tests boundary fix)
        [[23, 59, 59.99], [-2, 0, 0.0], "Psc"],

        # Puppis (Pup)
        [[8, 3, 35.05], [-40, 0, 11.4], "Pup"],     # Naos (ζ Pup)
        [[7, 17, 8.54], [-37, 5, 50.0], "Pup"],     # Pi Puppis

        # Pyxis (Pyx)
        [[8, 43, 35.54], [-33, 11, 11.1], "Pyx"],   # Alpha Pyxidis
        [[8, 47, 42.10], [-35, 12, 37.7], "Pyx"],   # Beta Pyxidis

        # Reticulum (Ret)
        [[4, 14, 25.55], [-62, 28, 26.1], "Ret"],   # Alpha Reticuli
        [[3, 58, 47.70], [-64, 48, 24.9], "Ret"],   # Beta Reticuli

        # Sculptor (Scl)
        [[0, 58, 36.43], [-29, 21, 26.7], "Scl"],   # Alpha Sculptoris
        [[23, 48, 53.32], [-37, 49, 5.8], "Scl"],   # Beta Sculptoris

        # Scorpius (Sco)
        [[16, 29, 24.46], [-26, 25, 55.2], "Sco"],  # Antares
        [[17, 33, 36.52], [-37, 6, 13.8], "Sco"],   # Shaula

        # Scutum (Sct)
        [[18, 35, 12.44], [-8, 14, 39.7], "Sct"],   # Alpha Scuti
        [[18, 47, 10.49], [-4, 44, 52.4], "Sct"],   # Beta Scuti

        # Serpens (Ser)
        [[15, 44, 16.07], [6, 25, 32.7], "Ser"],    # Unukalhai
        [[18, 56, 13.28], [4, 12, 13.2], "Ser"],    # Alya

        # Sextans (Sex)
        [[10, 17, 37.85], [-0, 22, 18.1], "Sex"],   # Alpha Sextantis
        [[10, 30, 16.10], [0, 38, 12.8], "Sex"],    # Beta Sextantis

        # Sagitta (Sge)
        [[19, 40, 5.58], [18, 0, 50.2], "Sge"],     # Sham
        [[19, 41, 2.88], [17, 27, 34.8], "Sge"],    # Beta Sagittae

        # Sagittarius (Sgr)
        [[18, 24, 10.29], [-34, 23, 4.6], "Sgr"],   # Kaus Australis
        [[18, 55, 15.92], [-26, 17, 48.5], "Sgr"],  # Nunki

        # Taurus (Tau)
        [[4, 35, 55.24], [16, 30, 33.5], "Tau"],    # Aldebaran
        [[5, 26, 17.51], [28, 36, 26.7], "Tau"],    # Elnath

        # Telescopium (Tel)
        [[18, 26, 58.39], [-45, 58, 5.9], "Tel"],   # Alpha Telescopii
        [[18, 28, 49.75], [-49, 4, 13.7], "Tel"],   # Zeta Telescopii

        # Triangulum Australe (TrA)
        [[16, 48, 39.98], [-69, 1, 39.7], "TrA"],   # Atria
        [[15, 55, 8.78], [-63, 25, 49.5], "TrA"],   # Beta Trianguli Australis

        # Triangulum (Tri)
        [[1, 53, 4.89], [29, 34, 43.0], "Tri"],     # Mothallah (α Tri)
        [[2, 9, 32.48], [34, 59, 14.3], "Tri"],     # Beta Trianguli

        # Tucana (Tuc)
        [[22, 18, 30.13], [-60, 15, 34.2], "Tuc"],  # Alpha Tucanae
        [[0, 31, 32.68], [-62, 57, 28.0], "Tuc"],   # Beta Tucanae

        # Ursa Major (UMa)
        [[11, 3, 43.67], [61, 45, 3.7], "UMa"],     # Dubhe
        [[11, 1, 50.50], [56, 22, 56.7], "UMa"],    # Merak

        # Ursa Minor (UMi)
        [[2, 31, 49.09], [89, 15, 50.8], "UMi"],    # Polaris
        [[14, 50, 42.32], [74, 9, 19.8], "UMi"],    # Kochab

        # Vela (Vel)
        [[8, 9, 31.85], [-47, 20, 11.0], "Vel"],    # Suhail (γ Vel)
        [[9, 22, 6.78], [-54, 59, 41.6], "Vel"],    # Markeb (κ Vel)

        # Virgo (Vir)
        [[13, 25, 11.58], [-11, 9, 41.2], "Vir"],   # Spica
        [[13, 2, 10.60], [10, 57, 32.9], "Vir"],    # Vindemiatrix

        # Volans (Vol)
        [[8, 22, 47.86], [-66, 8, 47.7], "Vol"],    # Beta Volantis
        [[8, 7, 55.58], [-70, 29, 55.1], "Vol"],    # Gamma Volantis

        # Vulpecula (Vul)
        [[19, 28, 42.43], [24, 39, 54.3], "Vul"],   # Anser
        [[19, 55, 24.46], [27, 58, 13.5], "Vul"]    # Beta Vulpeculae
      ]

      stars.each do |ra_hms, dec_dms, abbreviation|
        # The IAU constellation boundaries are defined for the epoch B1875.
        # We need to convert the right ascension and declination to B1875
        # equatorial coordinates before searching for the constellation.
        equatorial_coordinates =
          Astronoby::Precession.for_equatorial_coordinates(
            coordinates: Astronoby::Coordinates::Equatorial.new(
              right_ascension: Astronoby::Angle.from_hms(*ra_hms),
              declination: Astronoby::Angle.from_dms(*dec_dms)
            ),
            epoch: Astronoby::JulianDate::B1875
          )

        constellation = described_class.find(equatorial_coordinates)

        expect(constellation).to be_a(Astronoby::Constellation)
        expect(constellation.abbreviation).to eq(abbreviation)
      end
    end
  end
end
