# Altitude crossings

`Astronoby::AltitudeCrossingCalculator` finds when a body reaches any altitude above the observer's horizon, positive or negative, with instants that are not rounded. [Twilight times](twilight_times.md) are built on it.

## Initialization

It takes as key arguments:

- `body`: the body to track, for example `Astronoby::Sun`
- `observer` (`Astronoby::Observer`): location on Earth of the observer
- `ephem`: ephemeris to provide the initial raw data
- `refraction` (optional, `false` by default): whether atmospheric refraction is applied to the altitude, `false` being the twilight convention
- `reference` (optional, `:center` by default): which point of the body reaches the altitude, `:center`, `:upper_limb` or `:lower_limb`. The limbs use the body's true semi-diameter and need a solar system body.

```rb
calculator = Astronoby::AltitudeCrossingCalculator.new(
  body: Astronoby::Sun,
  observer: observer,
  ephem: ephem
)
```

## `#crossings_between`

It returns the `Astronoby::AltitudeCrossing` objects in a time range, sorted by time.

```rb
crossings = calculator.crossings_between(
  Time.utc(2026, 10, 23),
  Time.utc(2026, 10, 24),
  altitude: Astronoby::Angle.from_degrees(-17.5)
)

crossing = crossings.first

crossing.instant    # => Astronoby::Instant, unrounded
crossing.direction  # => :rising or :setting
crossing.grazing?   # => true when the body only just reaches the altitude
```

A crossing is `:rising` when the altitude increases through the target. It is `grazing?` when the target is within 0.05° of the body's highest or lowest altitude, where the instant is sensitive to small errors.

## `#multiple_crossings_between`

It does the same for several altitudes at once and returns one array of crossings per altitude, in the order given. The culminations and the computed positions are shared between the altitudes, which makes it much cheaper than one call per altitude.

```rb
civil, nautical = calculator.multiple_crossings_between(
  start_time,
  end_time,
  altitudes: [Astronoby::Angle.from_degrees(-6), Astronoby::Angle.from_degrees(-12)]
)
```

## `#crossing_on`

It returns the first crossing of a given direction on a local day, or `nil`.

```rb
calculator.crossing_on(
  Date.new(2026, 10, 23),
  altitude: Astronoby::Angle.from_degrees(-17.5),
  direction: :setting,
  utc_offset: "+02:00"
)
```

## `#extremes_between`

It returns the upper and lower culminations in a time range, as `Astronoby::AltitudeExtreme` objects with `#kind`, `#instant` and `#altitude`. They are useful to explain why a crossing is absent: the body never got as high as, or as low as, the target.

```rb
calculator.extremes_between(start_time, end_time)
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

## See also

- [Twilight Times](twilight_times.md)
- [Rise, Transit and Set Times](rise_transit_set_times.md) 