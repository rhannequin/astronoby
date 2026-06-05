# frozen_string_literal: true

RSpec.describe Astronoby::ReferenceFrame do
  include TestEphemHelper

  describe "#separation_from" do
    context "during the 2020 Great Conjunction of Jupiter and Saturn" do
      it "returns the apparent separation" do
        instant = Astronoby::Instant.from_time(Time.utc(2020, 12, 21, 18))
        ephem = test_ephem_inpop_2000_2050
        jupiter = Astronoby::Jupiter.new(instant: instant, ephem: ephem)
        saturn = Astronoby::Saturn.new(instant: instant, ephem: ephem)

        separation = jupiter.apparent.separation_from(saturn.apparent)

        expect(separation.str(:dms)).to eq "+0° 6′ 6.4252″"
        # Skyfield: +0° 6′ 6.4257″
      end

      it "returns the astrometric separation" do
        instant = Astronoby::Instant.from_time(Time.utc(2020, 12, 21, 18))
        ephem = test_ephem_inpop_2000_2050
        jupiter = Astronoby::Jupiter.new(instant: instant, ephem: ephem)
        saturn = Astronoby::Saturn.new(instant: instant, ephem: ephem)

        separation = jupiter.astrometric.separation_from(saturn.astrometric)

        expect(separation.str(:dms)).to eq "+0° 6′ 6.4068″"
        # Skyfield: +0° 6′ 6.4068″
      end
    end

    context "between Mars and Antares" do
      it "returns the astrometric separation across body types" do
        instant = Astronoby::Instant.from_time(Time.utc(2016, 8, 24, 12))
        ephem = test_ephem_inpop_2000_2050
        mars = Astronoby::Mars.new(instant: instant, ephem: ephem)
        antares = Astronoby::DeepSkyObject.new(
          equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
            right_ascension: Astronoby::Angle.from_hms(16, 29, 24.46),
            declination: Astronoby::Angle.from_dms(-26, 25, 55.2)
          )
        ).at(instant, ephem: ephem)

        separation = mars.astrometric.separation_from(antares.astrometric)

        expect(separation.str(:dms)).to eq "+1° 47′ 20.8463″"
        # Skyfield: +1° 47′ 20.8″
      end
    end

    it "is symmetric" do
      instant = Astronoby::Instant.from_time(Time.utc(2020, 12, 21, 18))
      ephem = test_ephem_inpop_2000_2050
      jupiter = Astronoby::Jupiter.new(instant: instant, ephem: ephem)
      saturn = Astronoby::Saturn.new(instant: instant, ephem: ephem)

      forward = jupiter.apparent.separation_from(saturn.apparent)
      backward = saturn.apparent.separation_from(jupiter.apparent)

      expect(forward).to eq(backward)
    end

    context "when the frames are at different stages of the chain" do
      it "raises an error" do
        instant = Astronoby::Instant.from_time(Time.utc(2020, 12, 21, 18))
        ephem = test_ephem_inpop_2000_2050
        jupiter = Astronoby::Jupiter.new(instant: instant, ephem: ephem)
        saturn = Astronoby::Saturn.new(instant: instant, ephem: ephem)

        expect { jupiter.astrometric.separation_from(saturn.apparent) }
          .to raise_error(
            Astronoby::IncompatibleArgumentsError,
            /same stage/
          )
      end
    end

    context "when the frames are at different instants" do
      it "raises an error" do
        ephem = test_ephem_inpop_2000_2050
        jupiter = Astronoby::Jupiter.new(
          instant: Astronoby::Instant.from_time(Time.utc(2020, 12, 21, 18)),
          ephem: ephem
        )
        saturn = Astronoby::Saturn.new(
          instant: Astronoby::Instant.from_time(Time.utc(2020, 12, 22, 18)),
          ephem: ephem
        )

        expect { jupiter.apparent.separation_from(saturn.apparent) }
          .to raise_error(
            Astronoby::IncompatibleArgumentsError,
            /different instants/
          )
      end
    end

    context "when the frames have different centers" do
      it "raises an error" do
        instant = Astronoby::Instant.from_time(Time.utc(2020, 12, 21, 18))
        ephem = test_ephem_inpop_2000_2050
        jupiter = Astronoby::Jupiter.new(instant: instant, ephem: ephem)
        paris = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(48.8566),
          longitude: Astronoby::Angle.from_degrees(2.3522)
        )
        sydney = Astronoby::Observer.new(
          latitude: Astronoby::Angle.from_degrees(-33.8688),
          longitude: Astronoby::Angle.from_degrees(151.2093)
        )

        expect {
          jupiter.observed_by(paris)
            .separation_from(jupiter.observed_by(sydney))
        }.to raise_error(
          Astronoby::IncompatibleArgumentsError,
          /different centers/
        )
      end
    end

    context "when the other object is not a reference frame" do
      it "raises an error" do
        instant = Astronoby::Instant.from_time(Time.utc(2020, 12, 21, 18))
        ephem = test_ephem_inpop_2000_2050
        jupiter = Astronoby::Jupiter.new(instant: instant, ephem: ephem)

        expect { jupiter.apparent.separation_from(Object.new) }
          .to raise_error(Astronoby::IncompatibleArgumentsError)
      end
    end
  end
end
