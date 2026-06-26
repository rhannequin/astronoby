# Lunar Eclipses

Astronoby computes lunar eclipses: the passages of the Moon through Earth's shadow. A lunar eclipse is a geocentric event, the same for every observer who can see the Moon, so no observer is involved. The geometry is built from the apparent geocentric positions of the Sun and Moon, which matches the standard reduction used by [NASA's Five Millennium Canon of Lunar Eclipses] and by IMCCE.

There are three kinds of lunar eclipses. A penumbral eclipse is when the Moon only enters Earth's penumbra, the outer, partial shadow. A partial eclipse is when part of the Moon enters the umbra, the inner, total shadow. A total eclipse is when the whole Moon enters the umbra.

## Finding eclipses

`Astronoby::Moon.eclipse_events` takes an ephemeris and a time range, and returns the lunar eclipses whose greatest instant falls in that range, sorted by time.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")

eclipses = Astronoby::Moon.eclipse_events(
  ephem: ephem,
  start_time: Time.utc(2025, 1, 1),
  end_time: Time.utc(2026, 1, 1)
)

eclipses.map { |eclipse| [eclipse.instant.to_time, eclipse.kind] }
# => [[2025-03-14 06:58:47 UTC, :total], [2025-09-07 18:11:49 UTC, :total]]
```

## An eclipse

Each eclipse is an `Astronoby::LunarEclipse`. Its `#instant` (also available as `#greatest_eclipse`) is the moment of greatest eclipse, when the Moon's centre is least distant from the axis of Earth's shadow.

```rb
eclipse = eclipses.first

eclipse.kind                 # => :total
eclipse.total?               # => true
eclipse.instant.to_time      # => 2025-03-14 06:58:47 UTC
eclipse.greatest_eclipse     # => same as #instant
```

The umbral and penumbral magnitudes are the fractions of the Moon's diameter immersed in the umbra and the penumbra at greatest eclipse. The umbral magnitude is negative for a penumbral eclipse (the Moon misses the umbra), between 0 and 1 for a partial eclipse, and 1 or more for a total eclipse.

```rb
eclipse.umbral_magnitude     # => 1.179
eclipse.penumbral_magnitude  # => 2.26
```

`#gamma` is the least distance of the Moon's centre from the axis of Earth's shadow at greatest eclipse, in Earth radii, positive when the Moon passes north of the axis and negative when it passes south. It is the standard, dimensionless eclipse parameter used by IMCCE and NASA. The same quantity is also available as a `Astronoby::Distance` through `#shadow_axis_distance`.

```rb
eclipse.gamma                       # => 0.348
eclipse.shadow_axis_distance.km     # => 2222.37
```

## Phases

An eclipse exposes its phases as `Astronoby::EclipsePhase` objects, each with a `#starting_instant`, an `#ending_instant`, and a `#duration` in seconds. The penumbral phase is always present. The partial phase is present for partial and total eclipses, and the total phase (totality) only for total eclipses. A phase that does not occur is `nil`.

```rb
eclipse.penumbral.starting_instant.to_time # => 2025-03-14 03:57:29 UTC (P1)
eclipse.partial.starting_instant.to_time   # => 2025-03-14 05:09:37 UTC (U1)
eclipse.total.starting_instant.to_time     # => 2025-03-14 06:26:01 UTC (U2)
eclipse.total.ending_instant.to_time       # => 2025-03-14 07:31:32 UTC (U3)
eclipse.partial.ending_instant.to_time     # => 2025-03-14 08:47:55 UTC (U4)
eclipse.penumbral.ending_instant.to_time   # => 2025-03-14 10:00:08 UTC (P4)

eclipse.total.duration # => 3931 (seconds of totality)
```

For a penumbral eclipse, `#partial` and `#total` are `nil`. For a partial eclipse, `#total` is `nil`.

```rb
penumbral_eclipse = Astronoby::Moon.eclipse_events(
  ephem: ephem,
  start_time: Time.utc(2024, 3, 1),
  end_time: Time.utc(2024, 4, 1)
).first

penumbral_eclipse.kind    # => :penumbral
penumbral_eclipse.partial # => nil
penumbral_eclipse.total   # => nil
```

## Precision

Earth's shadow is enlarged by its atmosphere. Astronoby enlarges Earth's radius by 1/99 before building the shadow cones, a factor calibrated against IMCCE. Validated across the 2023 to 2025 eclipses, the eclipse kind, greatest eclipse instant, magnitudes, and contact times all match IMCCE to within a second or two.

## See also

- [Moon Phases](moon_phases.md) - for lunar phases
- [Lunar Observation](lunar_observation.md) - for libration, axis and limb angles
- [Planetary Phenomena](planetary_phenomena.md) - for conjunctions, oppositions and elongations
- [Solar System Bodies](solar_system_bodies.md) - for moon object details
- [Ephemerides](ephem.md) - for data sources

[NASA's Five Millennium Canon of Lunar Eclipses]: https://eclipse.gsfc.nasa.gov/SEpubs/5MCLE.html
[IMCCE]: https://www.imcce.fr/
