# Moon Phases

Astronoby lets you compute the current Moon phase, or when the major ones
happen.

## Current Moon phase

`Astronoby::Moon` provides two pieces of information about the current Moon phase: the
illuminated fraction and the phase fraction.

### `#illuminated_fraction`

As mentioned in the name, this method provides the illuminated fraction of the
Moon. It will not give precise information about the "age" of the Moon as the
same illumination happens twice in the same lunar month.

```rb
sky = Astronoby::Sky.load("tmp/inpop19a.bsp")
time = Time.utc(2025, 5, 1)
instant = Astronoby::Instant.from_time(time)

moon = sky.moon.at(instant)

moon.illuminated_fraction.round(2)
# => 0.15
# 15% of the Moon is illuminated as seen from Earth
```

### `#current_phase_fraction`

This method is more convenient for a user interested in how far we are into the
lunar month as it returns a fraction from 0 to 1 between two new Moons.

```rb
time = Time.utc(2025, 5, 1)
instant = Astronoby::Instant.from_time(time)
moon = sky.moon.at(instant)

moon.current_phase_fraction.round(2)
# => 0.11

time = Time.utc(2025, 5, 15)
instant = Astronoby::Instant.from_time(time)
moon = sky.moon.at(instant)

moon.current_phase_fraction.round(2)
# => 0.59
```

## Major Moon phases

`sky.moon.phases` finds the new moons, first quarters, full moons and last
quarters in the ephemeris: when the difference between the Moon's and the
Sun's apparent ecliptic longitudes reaches 0°, 90°, 180° or 270°. It returns
an `Astronoby::Events::Series`, read with `on(date)`, `between(start, finish)`
or `from(start)`, as on the [Local sky page].

Each phase is an `Astronoby::MoonPhase`, which exposes a `phase` (`Symbol`), an
unrounded `instant` and a `time` (`Time`, rounded to the second). Because a
lunar month is around 29 days, some months have the same phase twice.

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

Without an ephemeris, `Astronoby::Events::MoonPhases.phases_for(year:, month:)`
gives the phases of a civil month from the series of Jean Meeus's
_Astronomical Algorithms_.

[Local sky page]: local_sky.md

## See also

- [Twilight Times](twilight_times.md) - for sun-related events
- [Rise, Transit and Set Times](rise_transit_set_times.md) - for moon events
- [Lunar Observation](lunar_observation.md) - for libration, axis and limb angles
- [Lunar Eclipses](lunar_eclipses.md) - for eclipses of the Moon
- [Solar System Bodies](solar_system_bodies.md) - for moon object details
- [Sky](sky.md) - for loading an ephemeris
