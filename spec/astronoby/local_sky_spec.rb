# frozen_string_literal: true

RSpec.describe Astronoby::LocalSky do
  include TestEphemHelper

  def paris
    Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(48.836614),
      longitude: Astronoby::Angle.from_degrees(2.336675)
    )
  end

  def vega
    Astronoby::DeepSkyObject.new(
      equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
        right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
        declination: Astronoby::Angle.from_dms(38, 47, 1.2802)
      )
    )
  end

  describe "#crossings" do
    it "returns when the target crosses the altitude" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      crossings = local_sky
        .crossings(sky.sun, Astronoby::Altitude.true(degrees: 30))
        .on(Date.new(2025, 10, 1))

      expect(crossings.map(&:direction)).to eq([:rising, :setting])
      expect(crossings.map { _1.instant.to_time.round }).to eq(
        [Time.utc(2025, 10, 1, 9, 23, 53), Time.utc(2025, 10, 1, 13, 55, 59)]
      )
    end

    it "applies refraction to an apparent altitude and follows a limb" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      crossings = local_sky
        .crossings(sky.moon.upper_limb, Astronoby::Altitude.apparent(degrees: 5))
        .on(Date.new(2025, 10, 1))

      expect(crossings.map { _1.instant.to_time.round }).to eq(
        [Time.utc(2025, 10, 1, 16, 3, 59), Time.utc(2025, 10, 1, 22, 41, 8)]
      )
    end

    it "finds nothing for an altitude a fixed star never reaches" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      crossings = local_sky
        .crossings(vega, Astronoby::Altitude.true(degrees: 85))
        .from(Astronoby::Instant.from_time(Time.utc(2025, 10, 1)))

      expect(crossings.first).to be_nil
    end
  end

  describe "#passes" do
    it "returns the rising, transit and setting of each pass" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      pass = local_sky.passes(sky.moon).on(Date.new(2025, 10, 1)).first

      expect(pass.rising.to_time.round).to eq(Time.utc(2025, 10, 1, 15, 17, 42))
      expect(pass.transit.to_time.round).to eq(Time.utc(2025, 10, 1, 19, 18, 41))
      expect(pass.setting.to_time.round).to eq(Time.utc(2025, 10, 1, 23, 27, 31))
    end

    it "completes a pass that sets after midnight" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      pass = local_sky.passes(sky.saturn).on(Date.new(2025, 10, 1)).first

      expect(pass.transit.to_time.to_date).to eq(Date.new(2025, 10, 1))
      expect(pass.setting.to_time.to_date).to eq(Date.new(2025, 10, 2))
    end

    it "has no rising or setting for a circumpolar star" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)
      polaris = Astronoby::DeepSkyObject.new(
        equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(2, 31, 49),
          declination: Astronoby::Angle.from_dms(89, 15, 51)
        )
      )

      pass = local_sky.passes(polaris).on(Date.new(2025, 10, 1)).first

      expect(pass.rising).to be_nil
      expect(pass.setting).to be_nil
    end

    it "raises for a limb" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      expect { local_sky.passes(sky.sun.upper_limb) }.to raise_error(
        ArgumentError,
        "Risings, transits and settings follow each body's standard " \
        "horizon; use crossings for a limb"
      )
    end
  end

  describe "#risings, #transits and #settings" do
    it "return the instants of each event" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)
      date = Date.new(2025, 10, 1)

      risings = local_sky.risings(sky.sun).on(date)
      transits = local_sky.transits(sky.sun).on(date)
      settings = local_sky.settings(sky.sun).on(date)

      expect(risings.map { _1.to_time.round })
        .to eq([Time.utc(2025, 10, 1, 5, 50, 23)])
      expect(transits.map { _1.to_time.round })
        .to eq([Time.utc(2025, 10, 1, 11, 40, 15)])
      expect(settings.map { _1.to_time.round })
        .to eq([Time.utc(2025, 10, 1, 17, 29, 15)])
    end

    it "accepts a deep-sky object" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      risings = local_sky.risings(vega).on(Date.new(2025, 10, 1))

      expect(risings.map { _1.to_time.round })
        .to eq([Time.utc(2025, 10, 1, 7, 7, 41)])
    end

    it "finds no risings for a star that never sets" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)
      polaris = Astronoby::DeepSkyObject.new(
        equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
          right_ascension: Astronoby::Angle.from_hms(2, 31, 49),
          declination: Astronoby::Angle.from_dms(89, 15, 51)
        )
      )

      risings = local_sky
        .risings(polaris)
        .from(Astronoby::Instant.from_time(Time.utc(2025, 10, 1)))

      expect(risings.first).to be_nil
    end
  end

  describe "near the ends of the ephemeris" do
    it "finds the twilights of the first and last covered days" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)
      first, last = sky.ephem.coverage

      from_start = local_sky.twilights.from(
        Astronoby::Instant.from_terrestrial_time(first)
      ).first(6)
      to_end = local_sky.twilights.from(
        Astronoby::Instant.from_terrestrial_time(last - 1)
      ).to_a

      expect(from_start.size).to eq(6)
      expect(to_end.size).to eq(6)
    end
  end

  describe "#twilights" do
    it "returns the dawns and dusks of each twilight, sorted by time" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      twilights = local_sky.twilights.on(Date.new(2025, 10, 1))

      expect(twilights.map { [_1.kind, _1.dawn?] }).to eq(
        [
          [:astronomical, true],
          [:nautical, true],
          [:civil, true],
          [:civil, false],
          [:nautical, false],
          [:astronomical, false]
        ]
      )
      expect(twilights.first.instant.to_time.round)
        .to eq(Time.utc(2025, 10, 1, 4, 4, 50))
      expect(twilights[3].instant.to_time.round)
        .to eq(Time.utc(2025, 10, 1, 18, 0, 38))
    end
  end

  it "raises for something it cannot observe" do
    sky = Astronoby::Sky.new(test_ephem)
    local_sky = sky.over(paris)

    expect { local_sky.risings(Astronoby::Mars) }.to raise_error(
      ArgumentError,
      "Expected a target of the sky or a deep-sky object, got Astronoby::Mars"
    )
  end

  describe "#inspect" do
    it "shows the observer's coordinates" do
      sky = Astronoby::Sky.new(test_ephem)

      expect(sky.over(paris).inspect)
        .to eq("#<Astronoby::LocalSky +48° 50′ 11.8103″ +2° 20′ 12.03″>")
    end
  end
end
