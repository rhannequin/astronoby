# frozen_string_literal: true

RSpec.describe "Deprecated entry points", :deprecations do
  include TestEphemHelper

  def instant
    Astronoby::Instant.from_time(Time.utc(2025, 10, 1))
  end

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

  def deprecation(subject, replacement)
    /\A#{Regexp.escape(__FILE__)}:\d+: warning: #{Regexp.escape(subject)} is deprecated and will be removed in Astronoby 0\.14\.0, use Astronoby::Sky instead: #{Regexp.escape(replacement)}\n\z/
  end

  it "warns on a body built at an instant" do
    ephem = test_ephem

    expect { Astronoby::Mars.at(instant, ephem: ephem) }.to output(
      deprecation("Astronoby::Mars.at(instant, ephem:)", "sky.mars.at(instant)")
    ).to_stderr
  end

  it "warns on a body built with new" do
    ephem = test_ephem

    expect { Astronoby::Moon.new(ephem: ephem, instant: instant) }.to output(
      deprecation(
        "Astronoby::Moon.new(ephem:, instant:)",
        "sky.moon.at(instant)"
      )
    ).to_stderr
  end

  it "warns on a deep-sky object observed with an ephemeris only" do
    ephem = test_ephem

    expect { vega.at(instant) }.not_to output.to_stderr
    expect { vega.at(instant, ephem: ephem) }.to output(
      deprecation(
        "Astronoby::DeepSkyObject#at(instant, ephem:)",
        "sky[deep_sky_object].at(instant)"
      )
    ).to_stderr
  end

  it "warns once on rise, transit and set events" do
    ephem = test_ephem

    expect {
      Astronoby::Mars.rise_transit_set_events(
        observer: paris,
        ephem: ephem,
        date: Date.new(2025, 10, 1)
      )
    }.to output(
      deprecation(
        "Astronoby::Mars.rise_transit_set_events",
        "sky.over(observer).passes(sky.mars)"
      )
    ).to_stderr
  end

  it "warns on conjunctions, oppositions and greatest elongations" do
    ephem = test_ephem
    start_time = Time.utc(2025, 1, 1)
    end_time = Time.utc(2025, 2, 1)

    expect {
      Astronoby::Mars.conjunction_events(
        ephem: ephem,
        start_time: start_time,
        end_time: end_time
      )
    }.to output(
      deprecation("Astronoby::Mars.conjunction_events", "sky.mars.conjunctions")
    ).to_stderr
    expect {
      Astronoby::Mars.opposition_events(
        ephem: ephem,
        start_time: start_time,
        end_time: end_time
      )
    }.to output(
      deprecation("Astronoby::Mars.opposition_events", "sky.mars.oppositions")
    ).to_stderr
    expect {
      Astronoby::Venus.greatest_elongation_events(
        ephem: ephem,
        start_time: start_time,
        end_time: end_time
      )
    }.to output(
      deprecation(
        "Astronoby::Venus.greatest_elongation_events",
        "sky.venus.greatest_elongations"
      )
    ).to_stderr
  end

  it "does not warn before raising for an unsupported event" do
    ephem = test_ephem

    expect {
      expect {
        Astronoby::Moon.conjunction_events(
          ephem: ephem,
          start_time: Time.utc(2025, 1, 1),
          end_time: Time.utc(2025, 2, 1)
        )
      }.to raise_error(Astronoby::UnsupportedEventError)
    }.not_to output.to_stderr
  end

  it "warns on the Moon's apsides and eclipses" do
    ephem = test_ephem
    start_time = Time.utc(2025, 1, 1)
    end_time = Time.utc(2025, 2, 1)

    expect {
      Astronoby::Moon.apoapsis_events(
        ephem: ephem,
        start_time: start_time,
        end_time: end_time
      )
    }.to output(
      deprecation("Astronoby::Moon.apoapsis_events", "sky.moon.apogees")
    ).to_stderr
    expect {
      Astronoby::Moon.periapsis_events(
        ephem: ephem,
        start_time: start_time,
        end_time: end_time
      )
    }.to output(
      deprecation("Astronoby::Moon.periapsis_events", "sky.moon.perigees")
    ).to_stderr
    expect {
      Astronoby::Moon.eclipse_events(
        ephem: ephem,
        start_time: start_time,
        end_time: end_time
      )
    }.to output(
      deprecation("Astronoby::Moon.eclipse_events", "sky.moon.eclipses")
    ).to_stderr
  end

  it "warns once on twilight events" do
    ephem = test_ephem

    expect {
      Astronoby::Sun.twilight_events(
        observer: paris,
        ephem: ephem,
        date: Date.new(2025, 10, 1)
      )
    }.to output(
      deprecation(
        "Astronoby::Sun.twilight_events",
        "sky.over(observer).twilights"
      )
    ).to_stderr
  end

  it "warns once on equinoxes and solstices" do
    ephem = test_ephem

    expect { Astronoby::Sun.june_solstice(2025, ephem: ephem) }.to output(
      deprecation(
        "Astronoby::Sun.june_solstice",
        "sky.seasons.in(year).june_solstice"
      )
    ).to_stderr
    expect { Astronoby::EquinoxSolstice.march_equinox(2025, ephem) }.to output(
      deprecation(
        "Astronoby::EquinoxSolstice.march_equinox",
        "sky.seasons.in(year).march_equinox"
      )
    ).to_stderr
  end

  it "warns on the rise, transit and set calculator's methods" do
    calculator = Astronoby::RiseTransitSetCalculator.new(
      body: Astronoby::Sun,
      observer: paris,
      ephem: test_ephem
    )

    expect { calculator.event_on(Date.new(2025, 10, 1)) }.to output(
      deprecation(
        "Astronoby::RiseTransitSetCalculator#event_on",
        "sky.over(observer).passes(target)"
      )
    ).to_stderr
    expect { calculator.events_on(Date.new(2025, 10, 1)) }.to output(
      deprecation(
        "Astronoby::RiseTransitSetCalculator#events_on",
        "sky.over(observer).passes(target)"
      )
    ).to_stderr
    expect {
      calculator.events_between(Time.utc(2025, 10, 1), Time.utc(2025, 10, 2))
    }.to output(
      deprecation(
        "Astronoby::RiseTransitSetCalculator#events_between",
        "sky.over(observer).passes(target)"
      )
    ).to_stderr
  end

  it "warns on the twilight calculator" do
    ephem = test_ephem

    expect {
      Astronoby::TwilightCalculator.new(observer: paris, ephem: ephem)
    }.to output(
      deprecation(
        "Astronoby::TwilightCalculator",
        "sky.over(observer).twilights"
      )
    ).to_stderr
  end

  it "warns on the altitude crossing calculator's methods" do
    calculator = Astronoby::AltitudeCrossingCalculator.new(
      body: Astronoby::Sun,
      observer: paris,
      ephem: test_ephem
    )
    start_time = Time.utc(2025, 10, 1)
    end_time = Time.utc(2025, 10, 2)
    altitude = Astronoby::Angle.from_degrees(-6)

    expect {
      calculator.crossings_between(start_time, end_time, altitude: altitude)
    }.to output(
      deprecation(
        "Astronoby::AltitudeCrossingCalculator#crossings_between",
        "sky.over(observer).crossings"
      )
    ).to_stderr
    expect {
      calculator.multiple_crossings_between(
        start_time,
        end_time,
        altitudes: [altitude]
      )
    }.to output(
      deprecation(
        "Astronoby::AltitudeCrossingCalculator#multiple_crossings_between",
        "sky.over(observer).crossings"
      )
    ).to_stderr
    expect {
      calculator.crossing_on(
        Date.new(2025, 10, 1),
        altitude: altitude,
        direction: :setting
      )
    }.to output(
      deprecation(
        "Astronoby::AltitudeCrossingCalculator#crossing_on",
        "sky.over(observer).crossings"
      )
    ).to_stderr
    expect { calculator.extremes_between(start_time, end_time) }.to output(
      deprecation(
        "Astronoby::AltitudeCrossingCalculator#extremes_between",
        "sky.over(observer).culminations"
      )
    ).to_stderr
  end

  it "does not warn through the sky" do
    sky = Astronoby::Sky.new(test_ephem)
    local_sky = sky.over(paris)
    date = Date.new(2025, 10, 1)
    start_time = Time.utc(2025, 1, 1)
    end_time = Time.utc(2025, 3, 1)

    expect {
      sky.mars.at(instant).apparent
      sky[vega].at(instant).apparent
      local_sky.passes(sky.moon).on(date)
      local_sky.risings(sky[vega]).on(date)
      local_sky.crossings(sky.sun, Astronoby::Altitude.true(degrees: -6)).on(date)
      local_sky.culminations(sky.sun).on(date)
      local_sky.twilights.on(date)
      sky.mars.conjunctions.between(start_time, end_time)
      sky.venus.greatest_elongations.between(start_time, end_time)
      sky.moon.eclipses.between(start_time, end_time)
      sky.moon.phases.between(start_time, end_time)
      sky.moon.apogees.between(start_time, end_time)
      sky.seasons.in(2025)
    }.not_to output.to_stderr
  end
end
