# Altitude crossings

A local sky (`Astronoby::LocalSky`) finds when a body reaches any altitude above the observer's horizon, positive or negative, with instants that are not rounded. [Twilight times](twilight_times.md) are built on the same search. You can learn more about local skies on the [Local sky page].

```rb
sky = Astronoby::Sky.load("tmp/de440s.bsp")
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.8566),
  longitude: Astronoby::Angle.from_degrees(2.3522)
)
local_sky = sky.over(observer)
```

## Crossings

`crossings` takes a target and an altitude, and returns `Astronoby::AltitudeCrossing` objects sorted by time.

The altitude is either apparent, with atmospheric refraction applied, or true, without it, the twilight convention:

```rb
Astronoby::Altitude.apparent(degrees: 5)
Astronoby::Altitude.true(degrees: -17.5)
```

```rb
crossings = local_sky
  .crossings(sky.sun, Astronoby::Altitude.true(degrees: -17.5))
  .on(Date.new(2026, 10, 23), utc_offset: "+02:00")

crossing = crossings.first

crossing.instant    # => Astronoby::Instant, unrounded
crossing.direction  # => :rising or :setting
crossing.grazing?   # => true when the body only just reaches the altitude
```

A crossing is `:rising` when the altitude increases through the target. It is `grazing?` when the target is within 0.05° of the body's highest or lowest altitude, where the instant is sensitive to small errors.

The centre of the body reaches the altitude, unless one of its limbs is given. The limbs use the body's semi-diameter as seen by the observer and need a Solar System body:

```rb
local_sky.crossings(sky.moon.upper_limb, Astronoby::Altitude.apparent(degrees: 0))
local_sky.crossings(sky.sun.lower_limb, Astronoby::Altitude.apparent(degrees: 10))
```

## Culminations

`culminations` returns the upper and lower culminations of a target, as `Astronoby::AltitudeExtreme` objects with `#kind`, `#instant` and `#altitude`. They are useful to explain why a crossing is absent: the body never got as high as, or as low as, the target. The altitude is the true one, unless refraction is asked for. Refraction is held at its value at -1° below that altitude, so a refracted altitude far below the horizon has no physical meaning.

```rb
culminations = local_sky
  .culminations(sky.sun, refraction: true)
  .on(Date.new(2026, 10, 23))

culminations.map(&:kind)
# => [:upper_culmination, :lower_culmination]
```

## Accuracy

The altitude at the returned instant is within 10⁻⁵° of the target, and crossings agree with independent tools. The Sun's centre, without refraction, was compared on 2026-10-23 in Paris, 2026-03-20 in Makkah and 2026-12-21 at 60° N 10° E and 75° N 10° E, at -6°, -12° and -18° (22 crossings, observer at sea level):

| Tool | Resolution | Largest difference with Astronoby |
| --- | --- | --- |
| [IMCCE OPALE](https://opale.imcce.fr) | 1 s | 0.6 s |
| [JPL Horizons](https://ssd.jpl.nasa.gov/horizons/) | 1 min table, interpolated | 0.10 s |
| [Skyfield](https://rhodesmills.github.io/skyfield/) on the same DE440s excerpt | 1 ms | 0.19 s |
| [USNO](https://aa.usno.navy.mil/data/api) | 1 min, civil twilight only | within its rounding |

The Skyfield differences are a time-scale effect rather than a geometric one: they are 0.00 s in March, 0.14 s in October and 0.18 s in December, which is the difference between Skyfield's built-in ΔT prediction and the IERS value Astronoby uses on those days. The remaining differences with Horizons and IMCCE come from the ephemerides (DE441 and INPOP19A against DE440s). The comparison also includes the polar night at 75° N, where the Sun does not rise but reaches -12° and -18°, and where the Sun never reaches -6°, as every tool agrees.

[Local sky page]: local_sky.md

## See also

- [Local sky](local_sky.md)
- [Twilight Times](twilight_times.md)
- [Rise, Transit and Set Times](rise_transit_set_times.md) 