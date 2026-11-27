# frozen_string_literal: true

RSpec.describe Astronoby::Sky::Target do
  include TestEphemHelper

  describe "#at" do
    it "returns the body at the instant" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      ephem = test_ephem
      sky = Astronoby::Sky.new(ephem)

      mars = sky.mars.at(instant)

      expect(mars).to be_a(Astronoby::Mars)
      expect(mars.instant).to eq(instant)
      expect(mars.apparent.position.map(&:m).to_a).to eq(
        Astronoby::Mars.new(ephem: ephem, instant: instant)
          .apparent.position.map(&:m).to_a
      )
    end

    it "gives the Moon the sky's orientation kernel" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      orientation = test_orientation
      sky = Astronoby::Sky.new(test_ephem, orientation: orientation)

      moon = sky.moon.at(instant)

      expect(moon.orientation).to be(orientation)
    end

    it "returns the deep-sky object's position seen from the sky's Earth" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
      ephem = test_ephem
      sky = Astronoby::Sky.new(ephem)
      vega = Astronoby::DeepSkyObject.new(
        equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
          declination: Astronoby::Angle.from_dms(38, 47, 1.2802)
        ),
        parallax: Astronoby::Angle.from_degree_arcseconds(0.13023)
      )

      position = sky[vega].at(instant)

      expect(position).to be_a(Astronoby::DeepSkyObjectPosition)
      expect(position.apparent.position.map(&:m).to_a).to eq(
        vega.at(instant, ephem: ephem).apparent.position.map(&:m).to_a
      )
    end
  end

  describe "#center, #upper_limb and #lower_limb" do
    it "return the point of the target" do
      sky = Astronoby::Sky.new(test_ephem)

      points = [sky.moon.center, sky.moon.upper_limb, sky.moon.lower_limb]

      expect(points.map(&:target)).to all(be(sky.moon))
      expect(points.map(&:reference))
        .to eq([:center, :upper_limb, :lower_limb])
    end

    it "raises for the limb of a deep-sky object" do
      sky = Astronoby::Sky.new(test_ephem)
      vega = Astronoby::DeepSkyObject.new(
        equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
          declination: Astronoby::Angle.from_dms(38, 47, 1.2802)
        )
      )

      expect { sky[vega].upper_limb }
        .to raise_error(ArgumentError, "A deep-sky object has no limb")
    end
  end

  describe "#inspect" do
    it "names the body" do
      sky = Astronoby::Sky.new(test_ephem)

      expect(sky.saturn.inspect)
        .to eq("#<Astronoby::Sky::Target Astronoby::Saturn>")
    end

    it "shows a deep-sky object's coordinates" do
      sky = Astronoby::Sky.new(test_ephem)
      vega = Astronoby::DeepSkyObject.new(
        equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
          declination: Astronoby::Angle.from_dms(38, 47, 1.2802)
        )
      )

      expect(sky[vega].inspect).to eq(
        "#<Astronoby::Sky::Target 18h 36m 56.3363s +38° 47′ 1.2801″>"
      )
    end
  end
end
