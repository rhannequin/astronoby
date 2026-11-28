# Quick Start

## Download an ephemeris

You only need to run this once, it will download and store an ephemeris on your
file system.

```rb
Ephem::IO::Download.call(name: "de421.bsp", target: "tmp/de421.bsp")
```

Ephemerides can be large files, but Astronoby provides a tool to drastically
reduce the size to your needs. You can learn more about ephemerides on the
[Ephem page].

## Load a sky

```rb
sky = Astronoby::Sky.load("tmp/de421.bsp")
```

A sky holds the ephemeris, so that it is given once instead of to every call,
and bodies taken from it at the same instant share their common work. You can
learn more on the [Sky page].

## Define a time and create an `Instant` object from it

```rb
time = Time.utc(2025, 6, 19, 12, 0, 0)
instant = Astronoby::Instant.from_time(time)
```

You can learn more about time scales on the [Instant page].

## Get a Solar System body at an instant

```rb
jupiter = sky.jupiter.at(instant)
```

You can learn more about planets and bodies on the [Solar System Bodies page].

## Define an observer from geographic coordinates

```rb
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.83661378408946),
  longitude: Astronoby::Angle.from_degrees(2.3366748126024466),
  elevation: Astronoby::Distance.from_meters(65)
)
```

You can learn more about angles on the [Angles page], and about observers on the
[Observer page].

## Compute the topocentric position of the body as seen from the observer

```rb
topocentric = jupiter.observed_by(observer)
```

You can learn more about reference frames and positions on the
[Reference Frames page].

## Get the horizontal coordinates from the position

```rb
topocentric.horizontal.azimuth.str(:dms)
# => "+175° 34′ 32.4967″"

topocentric.horizontal.altitude.str(:dms)
# => "+64° 22′ 58.1962″"
```

You can learn more about coordinates on the [Coordinates page].

## Get the rising, transit and setting times of a day

```rb
local_sky = sky.over(observer)

pass = local_sky.passes(sky.jupiter).on(Date.new(2025, 5, 1)).first

pass.rising.to_time.round
# => 2025-05-01 06:35:35 UTC

pass.transit.to_time.round
# => 2025-05-01 14:34:34 UTC

pass.setting.to_time.round
# => 2025-05-01 22:33:37 UTC
```

You can learn more about what an observer sees on the [Local sky page], and
about how these times are computed on the
[Rise, transit and setting times page].

## Get the twilight times of the day

```rb
local_sky
  .twilights
  .on(Date.new(2025, 5, 1))
  .map { |twilight| [twilight.kind, twilight.instant.to_time.round] }
# => [
#   [:astronomical, 2025-05-01 02:17:02 UTC],
#   [:nautical, 2025-05-01 03:09:39 UTC],
#   [:civil, 2025-05-01 03:54:36 UTC],
#   [:civil, 2025-05-01 19:41:58 UTC],
#   [:nautical, 2025-05-01 20:27:15 UTC],
#   [:astronomical, 2025-05-01 21:20:32 UTC]
# ]
```

You can learn more about twilights on the [Twilight times page].

## Find when a body reaches any altitude

```rb
crossing = local_sky
  .crossings(sky.sun, Astronoby::Altitude.true(degrees: 30))
  .on(Date.new(2025, 5, 1))
  .first

crossing.direction
# => :rising

crossing.instant.to_time.round
# => 2025-05-01 07:41:37 UTC
```

You can learn more about crossings on the [Altitude crossings page].

## Moon phases

You can either get the major Moon phases between two dates, or get information
about the Moon's phase at an instant.

```rb
sky
  .moon
  .phases
  .between(Time.utc(2024, 5, 1), Time.utc(2024, 6, 1))
  .map { |phase| [phase.phase, phase.time] }
# => [
#   [:last_quarter, 2024-05-01 11:27:16 UTC],
#   [:new_moon, 2024-05-08 03:21:56 UTC],
#   [:first_quarter, 2024-05-15 11:48:00 UTC],
#   [:full_moon, 2024-05-23 13:53:09 UTC],
#   [:last_quarter, 2024-05-30 17:12:40 UTC]
# ]
```

```rb
instant = Astronoby::Instant.from_time(Time.utc(2025, 5, 15))
moon = sky.moon.at(instant)

moon.illuminated_fraction.round(2)
# => 0.95

moon.current_phase_fraction.round(2)
# => 0.59
```

You can learn more about phases on the [Moon phases page].

## Lunar observation

```rb
instant = Astronoby::Instant.from_time(Time.utc(2025, 3, 1))
moon = sky.moon.at(instant)

moon.libration.longitude.str(:dms)
# => "-2° 5′ 4.4195″"

moon.libration.latitude.str(:dms)
# => "+0° 28′ 45.9577″"

moon.position_angle_of_axis.str(:dms)
# => "-21° 48′ 46.6579″"

moon.bright_limb_position_angle.str(:dms)
# => "+248° 1′ 57.9314″"
```

You can learn more about libration, axis and limb angles on the
[Lunar observation page].

## Lunar eclipses

```rb
sky
  .moon
  .eclipses
  .between(Time.utc(2025, 1, 1), Time.utc(2026, 1, 1))
  .map { |eclipse| [eclipse.instant.to_time.round, eclipse.kind] }
# => [[2025-03-14 06:58:47 UTC, :total], [2025-09-07 18:11:49 UTC, :total]]
```

You can learn more about umbral and penumbral magnitudes, phases and contact
times on the [Lunar eclipses page].

## Equinox and solstice times

```rb
year = sky.seasons.in(2025)

year.march_equinox.instant.to_time.round
# => 2025-03-20 09:01:29 UTC

year.june_solstice.instant.to_time.round
# => 2025-06-21 02:42:16 UTC

year.september_equinox.instant.to_time.round
# => 2025-09-22 18:19:20 UTC

year.december_solstice.instant.to_time.round
# => 2025-12-21 15:03:05 UTC
```

You can learn more about equinoxes and solstices on the
[Equinoxes and solstices times page].

## Planetary phenomena

```rb
sky
  .mars
  .oppositions
  .between(Time.utc(2025, 1, 1), Time.utc(2026, 1, 1))
  .first
  .instant
  .to_time
  .round
# => 2025-01-16 02:38:35 UTC

sky
  .venus
  .greatest_elongations
  .between(Time.utc(2025, 1, 1), Time.utc(2026, 1, 1))
  .first
  .angle
  .degrees
  .round(1)
# => 47.2
```

You can learn more about conjunctions, oppositions and greatest elongations on
the [Planetary phenomena page].

## Deep-sky objects

Any deep-sky object can be observed, given its equatorial coordinates from a
catalogue at the J2000 epoch.

```rb
instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1))

vega_j2000 = Astronoby::Coordinates::Equatorial.new(
  right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
  declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
  epoch: Astronoby::JulianDate::J2000
)

vega = Astronoby::DeepSkyObject.new(equatorial_coordinates: vega_j2000)

sky[vega].at(instant).apparent.equatorial.right_ascension.str(:hms)
# => "18h 37m 48.2676s"
```

You can learn more about deep-sky objects, and about converting many points to
horizontal coordinates at once with `HorizontalTransformation`, on the
[Deep-sky Bodies page].

## See also

- [Glossary](glossary.md) - for astronomical and technical terms
- [IERS Data](iers.md) - for Delta T and GMST data management
- [Refraction](refraction.md) - for apparent altitudes and atmospheric conditions
- [Configuration](configuration.md) - for performance tuning
- [Performance Benchmarks](../benchmarks/README.md) - for testing improvements

[Ephem page]: ephem.md
[Sky page]: sky.md
[Instant page]: instant.md
[Solar System Bodies page]: solar_system_bodies.md
[Observer page]: observer.md
[Reference Frames page]: reference_frames.md
[Angles page]: angles.md
[Coordinates page]: coordinates.md
[Local sky page]: local_sky.md
[Rise, transit and setting times page]: rise_transit_set_times.md
[Twilight times page]: twilight_times.md
[Altitude crossings page]: altitude_crossings.md
[Moon phases page]: moon_phases.md
[Lunar observation page]: lunar_observation.md
[Lunar eclipses page]: lunar_eclipses.md
[Equinoxes and solstices times page]: equinoxes_solstices_times.md
[Planetary phenomena page]: planetary_phenomena.md
[Deep-sky Bodies page]: deep_sky_bodies.md
