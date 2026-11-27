# frozen_string_literal: true

RSpec.describe Astronoby::Deflection do
  include TestEphemHelper

  describe "#corrected_position" do
    it "returns the corrected position for Mars on 2025-04-01" do
      time = Time.utc(2025, 4, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      mars = Astronoby::Mars.new(instant: instant, ephem: ephem)
      mars_astrometric_position = mars.astrometric.position
      earth = Astronoby::Earth.geometric(ephem: ephem, instant: instant)
      sun = Astronoby::Sun.geometric(ephem: ephem, instant: instant)
      deflection = described_class.new(
        target_astrometric_position: mars_astrometric_position,
        observer_position: earth.position,
        sun_position: sun.position
      )

      corrected_position = deflection.corrected_position

      expect(corrected_position.to_a.map(&:km).map(&:round))
        .to eq([-67178486, 140336315, 69466874])
      # Skyfield: -67178487 140336316 69466874
    end

    it "returns the corrected position for Neptune on 2025-08-01" do
      time = Time.utc(2025, 8, 1)
      instant = Astronoby::Instant.from_time(time)
      ephem = test_ephem
      neptune = Astronoby::Neptune.new(instant: instant, ephem: ephem)
      neptune_astrometric_position = neptune.astrometric.position
      earth = Astronoby::Earth.geometric(ephem: ephem, instant: instant)
      sun = Astronoby::Sun.geometric(ephem: ephem, instant: instant)
      deflection = described_class.new(
        target_astrometric_position: neptune_astrometric_position,
        observer_position: earth.position,
        sun_position: sun.position
      )

      corrected_position = deflection.corrected_position

      expect(corrected_position.to_a.map(&:km).map(&:round))
        .to eq([4375229342, 154618258, -45364787])
      # Skyfield: 4375229340 154618257 -45364788
    end

    it "returns the position unchanged for a target at the observer" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 4, 1))
      ephem = test_ephem
      earth = Astronoby::Earth.geometric(ephem: ephem, instant: instant)
      sun = Astronoby::Sun.geometric(ephem: ephem, instant: instant)
      position = Astronoby::Distance.vector_from_meters([0.0, 0.0, 0.0])
      deflection = described_class.new(
        target_astrometric_position: position,
        observer_position: earth.position,
        sun_position: sun.position
      )

      corrected_position = deflection.corrected_position

      expect(corrected_position).to eq(position)
    end

    it "returns the position unchanged for a target in line with the Sun" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 4, 1))
      ephem = test_ephem
      earth = Astronoby::Earth.geometric(ephem: ephem, instant: instant)
      sun = Astronoby::Sun.geometric(ephem: ephem, instant: instant)
      position = Astronoby::Distance.vector_from_meters(
        (sun.position.map(&:m) - earth.position.map(&:m)) * 2.5
      )
      deflection = described_class.new(
        target_astrometric_position: position,
        observer_position: earth.position,
        sun_position: sun.position
      )

      corrected_position = deflection.corrected_position

      expect(corrected_position).to eq(position)
    end

    it "fades the deflection of a target hidden behind the solar disk" do
      instant = Astronoby::Instant.from_time(Time.utc(2025, 4, 1))
      ephem = test_ephem
      earth = Astronoby::Earth.geometric(ephem: ephem, instant: instant)
      sun = Astronoby::Sun.geometric(ephem: ephem, instant: instant)
      to_sun = sun.position.map(&:m) - earth.position.map(&:m)
      to_sun_unit = to_sun / to_sun.norm
      offset = ::Vector[0.0, 0.0, 1.0].cross_product(to_sun_unit)
      separation = Astronoby::Angle.from_degree_arcseconds(100)
      direction = to_sun_unit * separation.cos +
        offset / offset.norm * separation.sin
      position = Astronoby::Distance.vector_from_meters(
        direction * to_sun.norm * 2.5
      )
      deflection = described_class.new(
        target_astrometric_position: position,
        observer_position: earth.position,
        sun_position: sun.position
      )

      corrected_position = deflection.corrected_position.map(&:m)
      shift = Astronoby::Angle.acos(
        corrected_position.inner_product(direction) / corrected_position.norm
      )

      expect(shift.degree_milliarcseconds).to be_within(1).of(109)
      # Without fading: 10 254 mas
    end
  end
end
