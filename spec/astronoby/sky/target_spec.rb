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

  describe "#oppositions" do
    it "returns the oppositions of a superior planet" do
      sky = Astronoby::Sky.new(test_ephem)

      oppositions = sky.mars.oppositions.between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(oppositions.map { _1.instant.to_time.round })
        .to eq([Time.utc(2025, 1, 16, 2, 38, 35)])
    end

    it "raises for an inferior planet" do
      sky = Astronoby::Sky.new(test_ephem)

      expect { sky.venus.oppositions }.to raise_error(
        Astronoby::UnsupportedEventError,
        "Astronoby::Venus has no oppositions with the Sun"
      )
    end
  end

  describe "#conjunctions" do
    it "returns the conjunctions of a planet" do
      sky = Astronoby::Sky.new(test_ephem)

      conjunction = sky.mercury.conjunctions
        .from(Astronoby::Instant.from_time(Time.utc(2025, 1, 1)))
        .first

      expect(conjunction).to be_superior
      expect(conjunction.instant.to_time.round)
        .to eq(Time.utc(2025, 2, 9, 12, 8, 6))
    end

    it "raises for the Moon" do
      sky = Astronoby::Sky.new(test_ephem)

      expect { sky.moon.conjunctions }.to raise_error(
        Astronoby::UnsupportedEventError,
        "Astronoby::Moon has no conjunctions with the Sun"
      )
    end
  end

  describe "#greatest_elongations" do
    it "returns the greatest elongations of an inferior planet" do
      sky = Astronoby::Sky.new(test_ephem)

      elongation = sky.venus.greatest_elongations
        .from(Astronoby::Instant.from_time(Time.utc(2025, 1, 1)))
        .first

      expect(elongation).to be_eastern
      expect(elongation.instant.to_time.round)
        .to eq(Time.utc(2025, 1, 10, 5, 1, 32))
      expect(elongation.angle.degrees).to be_within(0.01).of(47.17)
    end

    it "raises for a superior planet" do
      sky = Astronoby::Sky.new(test_ephem)

      expect { sky.mars.greatest_elongations }.to raise_error(
        Astronoby::UnsupportedEventError,
        "Astronoby::Mars has no greatest elongations from the Sun"
      )
    end
  end

  describe "#eclipses" do
    it "returns the lunar eclipses" do
      sky = Astronoby::Sky.new(test_ephem)

      eclipses = sky.moon.eclipses.between(
        Time.utc(2025, 1, 1),
        Time.utc(2026, 1, 1)
      )

      expect(eclipses.map { [_1.kind, _1.instant.to_time.round] }).to eq(
        [
          [:total, Time.utc(2025, 3, 14, 6, 58, 47)],
          [:total, Time.utc(2025, 9, 7, 18, 11, 49)]
        ]
      )
    end

    it "raises for anything but the Moon" do
      sky = Astronoby::Sky.new(test_ephem)

      expect { sky.sun.eclipses }.to raise_error(
        Astronoby::UnsupportedEventError,
        "Only the Moon has eclipses"
      )
    end
  end

  describe "#phases" do
    it "returns the phases of the Moon from the ephemeris" do
      sky = Astronoby::Sky.new(test_ephem)

      phases = sky.moon.phases.between(Time.utc(2025, 1, 1), Time.utc(2025, 2, 1))

      expect(phases.map { [_1.phase, _1.time] }).to eq(
        [
          [:first_quarter, Time.utc(2025, 1, 6, 23, 56, 18)],
          [:full_moon, Time.utc(2025, 1, 13, 22, 26, 55)],
          [:last_quarter, Time.utc(2025, 1, 21, 20, 30, 47)],
          [:new_moon, Time.utc(2025, 1, 29, 12, 35, 59)]
        ]
      )
    end

    it "agrees with the apparent longitudes of the Moon and the Sun" do
      ephem = test_ephem
      sky = Astronoby::Sky.new(ephem)

      full_moon = sky.moon.phases
        .from(Astronoby::Instant.from_time(Time.utc(2025, 1, 10)))
        .first
      moon = Astronoby::Moon.new(ephem: ephem, instant: full_moon.instant)
      sun = Astronoby::Sun.new(ephem: ephem, instant: full_moon.instant)
      difference = moon.apparent.ecliptic.longitude.degrees -
        sun.apparent.ecliptic.longitude.degrees

      expect(full_moon.phase).to eq(:full_moon)
      expect(difference % 360).to be_within(1e-6).of(180)
    end

    it "raises for anything but the Moon" do
      sky = Astronoby::Sky.new(test_ephem)

      expect { sky.mars.phases }.to raise_error(
        Astronoby::UnsupportedEventError,
        "Only the Moon has phases"
      )
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
