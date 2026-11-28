# frozen_string_literal: true

RSpec.describe Astronoby::LocalSky do
  include TestEphemHelper

  def paris
    Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(48.836614),
      longitude: Astronoby::Angle.from_degrees(2.336675)
    )
  end

  def observer_at(latitude, longitude)
    Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(latitude),
      longitude: Astronoby::Angle.from_degrees(longitude)
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
        [Time.utc(2025, 10, 1, 16, 3, 58), Time.utc(2025, 10, 1, 22, 41, 9)]
      )
      # IMCCE, upper limb at 5° apparent with Bennett's refraction:
      #   2025-10-01T16:03:58.78Z, 2025-10-01T22:41:08.38Z
      # Skyfield: 2025-10-01T16:03:58.78Z, 2025-10-01T22:41:08.38Z
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

    it "ends a pass and starts the next one around a short dip below the horizon" do
      sky = Astronoby::Sky.new(test_ephem_inpop_2000_2050)
      local_sky = sky.over(observer_at(64, -99))

      passes = local_sky
        .passes(sky.moon)
        .between(Time.utc(2026, 1, 3), Time.utc(2026, 1, 5))

      expect(passes[0].setting.to_time)
        .to be_within(0.01).of(Time.utc(2026, 1, 3, 18, 52, 25.27))
      expect(passes[1].rising.to_time)
        .to be_within(0.01).of(Time.utc(2026, 1, 3, 19, 28, 36.41))
      # IMCCE, upper limb at -34′: 2026-01-03T18:52:25.38Z,
      #   2026-01-03T19:28:36.46Z
      # Skyfield: 2026-01-03T18:52:25.37Z, 2026-01-03T19:28:36.47Z
    end

    it "has a rising and no setting when the body stays up after rising" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(observer_at(68, 15))

      pass = local_sky
        .passes(sky.moon)
        .between(Time.utc(2025, 1, 9), Time.utc(2025, 1, 10))
        .first

      expect(pass.rising.to_time)
        .to be_within(0.01).of(Time.utc(2025, 1, 9, 7, 51, 51.91))
      expect(pass.setting).to be_nil
      # IMCCE, upper limb at -34′: 2025-01-09T07:51:52.12Z
      # Skyfield: 2025-01-09T07:51:52.11Z, no setting before 2025-01-10T12:00Z
    end

    it "has a rising and no setting on the first day of the midnight sun" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(observer_at(78.2, 15.6))

      pass = local_sky.passes(sky.sun).on(Date.new(2025, 4, 18)).first

      expect(pass.rising.to_time)
        .to be_within(0.01).of(Time.utc(2025, 4, 17, 23, 32, 28.87))
      expect(pass.setting).to be_nil
      # IMCCE, centre at -50′: 2025-04-17T23:32:28.87Z
      # Skyfield: 2025-04-17T23:32:28.86Z, no setting after it
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

    it "finds both events of a short dip below the horizon" do
      sky = Astronoby::Sky.new(test_ephem_inpop_2000_2050)
      local_sky = sky.over(observer_at(64, -99))
      start_time = Time.utc(2026, 1, 3)
      end_time = Time.utc(2026, 1, 4)

      settings = local_sky.settings(sky.moon).between(start_time, end_time)
      risings = local_sky.risings(sky.moon).between(start_time, end_time)

      expect(settings.map(&:to_time)).to match([
        be_within(0.01).of(Time.utc(2026, 1, 3, 18, 52, 25.27))
      ])
      expect(risings.map(&:to_time)).to match([
        be_within(0.01).of(Time.utc(2026, 1, 3, 19, 28, 36.41))
      ])
      # IMCCE, upper limb at -34′: 2026-01-03T18:52:25.38Z,
      #   2026-01-03T19:28:36.46Z
      # Skyfield: 2026-01-03T18:52:25.37Z, 2026-01-03T19:28:36.47Z
    end

    it "finds nothing at a culmination below the horizon" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(observer_at(68, 15))
      start_time = Time.utc(2025, 2, 19)
      end_time = Time.utc(2025, 2, 21, 12)

      risings = local_sky.risings(sky.moon).between(start_time, end_time)
      settings = local_sky.settings(sky.moon).between(start_time, end_time)

      expect(risings.map(&:to_time)).to match([
        be_within(0.01).of(Time.utc(2025, 2, 19, 1, 36, 0.77))
      ])
      expect(settings.map(&:to_time)).to match([
        be_within(0.01).of(Time.utc(2025, 2, 19, 5, 30, 48.58))
      ])
      # IMCCE, upper limb at -34′: 2025-02-19T01:36:00.66Z,
      #   2025-02-19T05:30:48.70Z
      # Skyfield: 2025-02-19T01:36:00.65Z, 2025-02-19T05:30:48.70Z, and
      #   nothing else until 2025-02-21T12:00Z
    end

    it "finds no setting during the midnight sun" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(observer_at(78.2, 15.6))

      settings = local_sky.settings(sky.sun).on(Date.new(2025, 4, 18))

      expect(settings).to be_empty
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

    it "finds a rising or setting whose transit is outside the ephemeris" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(observer_at(-33.9, 151.2))
      first, last = sky.ephem.coverage

      settings = local_sky.settings(sky.sun).between(
        Astronoby::Instant.from_terrestrial_time(first),
        Astronoby::Instant.from_terrestrial_time(first + 0.5)
      )
      risings = local_sky.risings(sky.sun).between(
        Astronoby::Instant.from_terrestrial_time(last - 0.5),
        Astronoby::Instant.from_terrestrial_time(last)
      )

      expect(settings.map(&:to_time)).to match([
        be_within(0.01).of(Time.utc(2025, 1, 1, 9, 9, 33.06))
      ])
      expect(risings.map(&:to_time)).to match([
        be_within(0.01).of(Time.utc(2026, 1, 3, 18, 49, 46.24))
      ])
      # IMCCE, centre at -50′: 2025-01-01T09:09:33.07Z,
      #   2026-01-03T18:49:46.24Z
      # Skyfield: 2025-01-01T09:09:33.06Z, 2026-01-03T18:49:46.24Z
    end

    it "searches risings, settings, transits and passes up to the end" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)
      _, last = sky.ephem.coverage

      (0..12).each do |step|
        end_instant = Astronoby::Instant.from_terrestrial_time(last - step * 0.07)
        start_instant = Astronoby::Instant.from_terrestrial_time(
          end_instant.tt - 1.3
        )

        [:risings, :settings, :transits, :passes].each do |series|
          expect { local_sky.public_send(series, sky.moon).between(start_instant, end_instant) }
            .not_to raise_error
        end
      end
    end

    it "raises when the ephemeris starts after the search" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)
      first, _ = sky.ephem.coverage
      start = Astronoby::Instant.from_terrestrial_time(first - 3)

      [:risings, :settings, :transits, :passes].each do |series|
        expect { local_sky.public_send(series, sky.sun).from(start).first(1) }
          .to raise_error(::Ephem::OutOfRangeError)
      end
    end
  end

  describe "#culminations" do
    it "returns the upper and lower culminations with their altitude" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      culminations = local_sky.culminations(sky.sun).on(Date.new(2025, 10, 1))

      expect(culminations.map(&:kind))
        .to eq([:upper_culmination, :lower_culmination])
      expect(culminations[0].instant.to_time)
        .to be_within(0.01).of(Time.utc(2025, 10, 1, 11, 40, 14.83))
      expect(culminations[1].instant.to_time)
        .to be_within(0.01).of(Time.utc(2025, 10, 1, 23, 40, 5.22))
      expect(culminations.map { _1.altitude.str(:dms, precision: 3) })
        .to eq(["+37° 46′ 5.691″", "-44° 45′ 6.789″"])
      # IMCCE, true altitude at these instants: +37° 46′ 5.6912″,
      #   -44° 45′ 6.7886″
      # Skyfield: 2025-10-01T11:40:14.85Z +37° 46′ 5.6908″,
      #           2025-10-01T23:40:05.20Z -44° 45′ 6.7886″
    end

    it "follows a limb and applies refraction when asked" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      centre = local_sky.culminations(sky.moon).on(Date.new(2025, 10, 1))
      limb = local_sky
        .culminations(sky.moon.upper_limb, refraction: true)
        .on(Date.new(2025, 10, 1))

      expect(limb.map(&:refracted?)).to all(be(true))
      expect(limb.map(&:instant)).to eq(centre.map(&:instant))
      expect(limb.last.altitude.degrees)
        .to be > centre.last.altitude.degrees + 0.25
    end

    it "finds a retrograde planet culminating just before the end" do
      sky = Astronoby::Sky.new(test_ephem)
      local_sky = sky.over(paris)

      culminations = local_sky
        .culminations(sky.mars)
        .between(Time.utc(2025, 1, 14), Time.utc(2025, 1, 15, 0, 10, 15))

      expect(culminations.last.kind).to eq(:upper_culmination)
      expect(culminations.last.instant.to_time)
        .to be_within(0.01).of(Time.utc(2025, 1, 15, 0, 10, 8.75))
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
