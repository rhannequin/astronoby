# Planetary Phenomena

Astronoby computes the classic planetary phenomena relative to the Sun: conjunctions, oppositions, and greatest elongations. They are all defined in the apparent geocentric ecliptic frame of date.

The available phenomena depend on the planet. Inferior planets (Mercury and Venus) have conjunctions and greatest elongations. Superior planets (Mars to Neptune) have conjunctions and oppositions. Requesting a phenomenon that cannot occur for a given body raises an `Astronoby::UnsupportedEventError`.

Each of them is a method of a target of the sky, which returns an `Astronoby::Events::Series` read with `on(date)`, `between(start, finish)` or `from(start)`, as on the [Local sky page].

## Oppositions

An opposition is the instant when a superior planet and the Sun have opposite apparent ecliptic longitudes (a difference of 180 degrees), so the planet is opposite the Sun in the sky.

```rb
sky = Astronoby::Sky.load("tmp/inpop19a.bsp")

opposition = sky
  .mars
  .oppositions
  .between(Time.utc(2025, 1, 1), Time.utc(2026, 1, 1))
  .first

opposition.instant.to_time.round # => 2025-01-16 02:38:35 UTC
opposition.body                  # => Astronoby::Mars
```

## Conjunctions

A conjunction is the instant when a planet and the Sun share the same apparent ecliptic longitude. Each conjunction is classified as inferior (the planet passes between the Earth and the Sun) or superior (the planet passes behind the Sun), determined from the apparent distances. Superior planets only ever have superior conjunctions.

```rb
conjunction = sky
  .venus
  .conjunctions
  .between(Time.utc(2025, 1, 1), Time.utc(2026, 1, 1))
  .first

conjunction.instant.to_time.round # => 2025-03-23 01:07:30 UTC
conjunction.inferior?             # => true
conjunction.superior?             # => false
```

## Greatest elongations

A greatest elongation is the instant when an inferior planet reaches its maximum apparent angular separation from the Sun. It is eastern when the planet is east of the Sun (visible in the evening sky) and western when it is west of the Sun (visible in the morning sky).

```rb
elongation = sky
  .mercury
  .greatest_elongations
  .between(Time.utc(2025, 1, 1), Time.utc(2026, 1, 1))
  .first

elongation.instant.to_time.round # => 2025-03-08 06:09:18 UTC
elongation.angle.degrees.round(2) # => 18.25
elongation.eastern?               # => true
elongation.western?               # => false
```

## Elongation of a body

The elongation of any Solar System body, the apparent Sun-Earth-body angle, is also available directly on a body instance, along with the side of the Sun it lies on.

```rb
instant = Astronoby::Instant.from_time(Time.utc(2025, 7, 14))
venus = sky.venus.at(instant)

venus.elongation.degrees.round(2) # => 41.47
venus.eastern?           # => false
venus.western?           # => true
```

[Local sky page]: local_sky.md

## See also

- [Solar System Bodies](solar_system_bodies.md) - for planets and their properties
- [Equinoxes and Solstices Times](equinoxes_solstices_times.md) - for solar events
- [Moon Phases](moon_phases.md) - for lunar events
- [Reference Frames](reference_frames.md) - for coordinate systems
- [Sky](sky.md) - for loading an ephemeris