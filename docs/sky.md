# Sky

`Astronoby::Sky` is an entry point that holds the ephemeris, so that it is given once instead of to every call. It gives the Solar System bodies and deep-sky objects of that ephemeris, and the bodies taken from it at the same instant share their common work.

## Load a sky

```rb
sky = Astronoby::Sky.load("tmp/de440s.bsp")
```

A sky can read several SPK kernels as one. Each date is read from the first kernel that covers it, so a short excerpt given first is completed by a longer kernel given after it.

```rb
sky = Astronoby::Sky.load("tmp/de440s.bsp", "tmp/extra.bsp")
```

Kernels of different types (JPL DE and IMCCE INPOP) cannot be combined, as they do not split the bodies into the same segments.

The lunar orientation kernel used for the Moon's libration and axis can be loaded with the sky:

```rb
sky = Astronoby::Sky.load(
  "tmp/de440.bsp",
  orientation: "tmp/moon_pa_de440_200625.bpc"
)
```

`Sky.new` takes kernels and an orientation that are already loaded:

```rb
ephem = Astronoby::Ephem.load("tmp/de440s.bsp")
sky = Astronoby::Sky.new(ephem)
```

Loading a kernel reads its segments into memory on first use, so load a sky once and share it. `sky.close` closes its kernels once you are done with it.

## Solar System bodies

`sky.sun`, `sky.mercury`, `sky.venus`, `sky.earth`, `sky.moon`, `sky.mars`, `sky.jupiter`, `sky.saturn`, `sky.uranus` and `sky.neptune` return a `Sky::Target`. A target has no instant: `at` gives the body at an instant.

```rb
instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1, 21))
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.836614),
  longitude: Astronoby::Angle.from_degrees(2.336675),
  elevation: Astronoby::Distance.from_meters(65)
)

saturn = sky.saturn.at(instant)

saturn.observed_by(observer).horizontal.altitude.str(:dms)
# => "+31° 31′ 1.4719″"

sky.mars.at(instant).elongation.str(:dms)
# => "+27° 31′ 17.13″"
```

`sky.planets` returns the targets from Mercury to Neptune, without Earth:

```rb
sky.planets.map do |planet|
  planet.at(instant).observed_by(observer).horizontal.altitude.degrees.round
end
# => [-31, -32, -26, -13, 32, 14, 33]
```

You can learn more about what a body gives on the [Solar System Bodies page].

## Deep-sky objects

`sky[object]` returns a target for a deep-sky object. Its positions are corrected for parallax, aberration and light deflection with Earth and the Sun read from the sky's ephemeris.

```rb
vega = Astronoby::DeepSkyObject.new(
  equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
    right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
    declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
    epoch: Astronoby::JulianDate::J2000
  ),
  parallax: Astronoby::Angle.from_degree_arcseconds(0.13023)
)

sky[vega].at(instant).observed_by(observer).horizontal.altitude.str(:dms)
# => "+54° 6′ 32.7372″"
```

You can learn more about deep-sky objects on the [Deep-sky Bodies page].

## Local sky

`sky.over(observer)` gives the sky as seen by an observer, with passes, risings, transits, settings, altitude crossings and twilights. You can learn more on the [Local sky page].

## Events of a body

Targets give the events seen from the centre of the Earth, as `Astronoby::Events::Series` objects read with `on(date)`, `between(start, finish)` or `from(start)`, as on the [Local sky page]. Each event carries an unrounded `instant`.

```rb
sky.mars.oppositions
  .between(Time.utc(2025, 1, 1), Time.utc(2026, 1, 1))
  .map { |opposition| opposition.instant.to_time.round }
# => [2025-01-16 02:38:35 UTC]

elongation = sky.venus.greatest_elongations
  .from(Astronoby::Instant.from_time(Time.utc(2025, 1, 1)))
  .first
elongation.angle.degrees.round(2)
# => 47.17

sky.moon.eclipses
  .between(Time.utc(2025, 1, 1), Time.utc(2026, 1, 1))
  .map(&:kind)
# => [:total, :total]
```

- `oppositions` for Mars to Neptune, as `Astronoby::Opposition`
- `conjunctions` for the planets, as `Astronoby::Conjunction`
- `greatest_elongations` for Mercury and Venus, as `Astronoby::GreatestElongation`
- `eclipses` for the Moon, as `Astronoby::LunarEclipse`
- `phases` for the Moon, as `Astronoby::MoonPhase`

Other targets raise `Astronoby::UnsupportedEventError`. You can learn more about these events on the [Planetary phenomena page] and the [Lunar eclipses page].

Moon phases are found where the difference between the Moon's and the Sun's apparent ecliptic longitudes reaches 0°, 90°, 180° and 270°:

```rb
sky.moon.phases
  .between(Time.utc(2025, 1, 1), Time.utc(2025, 2, 1))
  .map { |phase| [phase.phase, phase.time] }
# => [
#   [:first_quarter, 2025-01-06 23:56:18 UTC],
#   [:full_moon, 2025-01-13 22:26:55 UTC],
#   [:last_quarter, 2025-01-21 20:30:47 UTC],
#   [:new_moon, 2025-01-29 12:35:59 UTC]
# ]
```

## Seasons

`sky.seasons` gives the equinoxes and solstices, when the Sun's apparent ecliptic longitude reaches 0°, 90°, 180° and 270°, as `Astronoby::SeasonStart` objects with a `kind`, `equinox?` and `solstice?`. `in(year)` returns the four of a year:

```rb
year = sky.seasons.in(2025)

year.june_solstice.instant.to_time.round
# => 2025-06-21 02:42:16 UTC
```

`sky.seasons` is also read with `on(date)`, `between(start, finish)` and `from(start)`:

```rb
sky.seasons
  .between(Time.utc(2025, 5, 1), Time.utc(2025, 10, 1))
  .map(&:kind)
# => [:june_solstice, :september_equinox]
```

## Bodies at the same instant

Every Solar System body taken from a sky at a given instant shares Earth's and the Sun's positions, the precession and nutation matrices, and the other bodies at that instant. `sky.mars.at(instant).elongation` reuses the Sun that `sky.sun.at(instant)` returns instead of computing it again, and asking twice for the same body at the same instant returns the same object.

Only the last instant asked for is kept, for each fiber, so nothing is shared between threads or fibers and no lock is taken. To share the work between several bodies, ask for all of them at one instant before moving to the next.

[Solar System Bodies page]: solar_system_bodies.md
[Deep-sky Bodies page]: deep_sky_bodies.md
[Local sky page]: local_sky.md
[Planetary phenomena page]: planetary_phenomena.md
[Lunar eclipses page]: lunar_eclipses.md
