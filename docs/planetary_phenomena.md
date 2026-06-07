# Planetary Phenomena

Astronoby computes the classic planetary phenomena relative to the Sun: conjunctions, oppositions, and greatest elongations. They are all defined in the apparent geocentric ecliptic frame of date.

The available phenomena depend on the planet. Inferior planets (Mercury and Venus) have conjunctions and greatest elongations. Superior planets (Mars to Neptune) have conjunctions and oppositions. Requesting a phenomenon that cannot occur for a given body raises an `Astronoby::UnsupportedEventError`.

Each method takes an ephemeris and a time range, and returns the events found within that range.

## Oppositions

An opposition is the instant when a superior planet and the Sun have opposite apparent ecliptic longitudes (a difference of 180 degrees), so the planet is opposite the Sun in the sky.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")

opposition = Astronoby::Mars.opposition_events(
  ephem: ephem,
  start_time: Time.utc(2025, 1, 1),
  end_time: Time.utc(2026, 1, 1)
).first

opposition.instant.to_time # => 2025-01-16 02:38:35 UTC
opposition.body            # => Astronoby::Mars
```

## Conjunctions

A conjunction is the instant when a planet and the Sun share the same apparent ecliptic longitude. Each conjunction is classified as inferior (the planet passes between the Earth and the Sun) or superior (the planet passes behind the Sun), determined from the apparent distances. Superior planets only ever have superior conjunctions.

```rb
conjunction = Astronoby::Venus.conjunction_events(
  ephem: ephem,
  start_time: Time.utc(2025, 1, 1),
  end_time: Time.utc(2026, 1, 1)
).first

conjunction.instant.to_time # => 2025-03-23 01:07:30 UTC
conjunction.inferior?       # => true
conjunction.superior?       # => false
```

## Greatest elongations

A greatest elongation is the instant when an inferior planet reaches its maximum apparent angular separation from the Sun. It is eastern when the planet is east of the Sun (visible in the evening sky) and western when it is west of the Sun (visible in the morning sky).

```rb
elongation = Astronoby::Mercury.greatest_elongation_events(
  ephem: ephem,
  start_time: Time.utc(2025, 1, 1),
  end_time: Time.utc(2026, 1, 1)
).first

elongation.instant.to_time   # => 2025-03-08 06:09:18 UTC
elongation.angle.degrees     # => 18.25
elongation.eastern?          # => true
elongation.western?          # => false
```

## Elongation of a body

The elongation of any Solar System body, the apparent Sun-Earth-body angle, is also available directly on a body instance, along with the side of the Sun it lies on.

```rb
instant = Astronoby::Instant.from_time(Time.utc(2025, 7, 14))
venus = Astronoby::Venus.new(instant: instant, ephem: ephem)

venus.elongation.degrees # => 41.47
venus.eastern?           # => false
venus.western?           # => true
```

## See also

- [Solar System Bodies](solar_system_bodies.md) - for planets and their properties
- [Equinoxes and Solstices Times](equinoxes_solstices_times.md) - for solar events
- [Moon Phases](moon_phases.md) - for lunar events
- [Reference Frames](reference_frames.md) - for coordinate systems
- [Ephemerides](ephem.md) - for data sources