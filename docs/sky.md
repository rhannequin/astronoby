# Sky

`Astronoby::Sky` is an entry point that holds the ephemeris, so that it is given once instead of to every call. It gives the Solar System bodies and deep-sky objects of that ephemeris, and the bodies taken from it at the same instant share their common work.

The rest of the documentation still uses `ephem:` arguments, which keep working.

## Load a sky

```rb
sky = Astronoby::Sky.load("tmp/de440s.bsp")
```

A sky can read several SPK kernels as one. When two kernels have a segment for the same bodies, the first one given wins.

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

Loading a kernel reads its segments into memory on first use, so load a sky once and share it.

## Solar System bodies

`sky.sun`, `sky.mercury`, `sky.venus`, `sky.earth`, `sky.moon`, `sky.mars`, `sky.jupiter`, `sky.saturn`, `sky.uranus` and `sky.neptune` return a `Sky::Target`. A target has no instant: `at` gives the body at an instant, the same object as `Astronoby::Saturn.new(ephem:, instant:)`.

```rb
instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1, 21))
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.83661378408946),
  longitude: Astronoby::Angle.from_degrees(2.3366748126024466),
  elevation: Astronoby::Distance.from_meters(65)
)

saturn = sky.saturn.at(instant)

saturn.observed_by(observer).horizontal.altitude.str(:dms)
# => "+31° 31′ 1.4722″"

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
# => "+54° 6′ 32.7376″"
```

You can learn more about deep-sky objects on the [Deep-sky Bodies page].

## Bodies at the same instant

Every body taken from a sky at a given instant shares Earth's and the Sun's positions, the precession and nutation matrices, and the other bodies at that instant. `sky.mars.at(instant).elongation` reuses the Sun that `sky.sun.at(instant)` returns instead of computing it again, and asking twice for the same body at the same instant returns the same object.

The last few instants are kept for each fiber, so nothing is shared between threads or fibers and no lock is taken.

[Solar System Bodies page]: solar_system_bodies.md
[Deep-sky Bodies page]: deep_sky_bodies.md
