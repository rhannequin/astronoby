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
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(2025, 5, 1)
instant = Astronoby::Instant.from_time(time)

moon = Astronoby::Moon.new(ephem: ephem, instant: instant)

moon.illuminated_fraction.round(2)
# => 0.15
# 15% of the Moon is illuminated as seen from Earth
```

### `#current_phase_fraction`

This method is more convenient for a user interested in how far we are into the
lunar month as it returns a fraction from 0 to 1 between two new Moons.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")

time = Time.utc(2025, 5, 1)
instant = Astronoby::Instant.from_time(time)
moon = Astronoby::Moon.new(ephem: ephem, instant: instant)

moon.current_phase_fraction.round(2)
# => 0.11

time = Time.utc(2025, 5, 15)
instant = Astronoby::Instant.from_time(time)
moon = Astronoby::Moon.new(ephem: ephem, instant: instant)

moon.current_phase_fraction.round(2)
# => 0.59
```

## Major Moon phases in the month

If you are interested to know when the major Moon phases will happen during a
civil month, you can use `Astronoby::Events::MoonPhases` and its class method
`::phases_for` with the key arguments `year` and `month`, both `Integer`.

It returns an array of `Astronoby::MoonPhase` objects, which each expose a
`phase` (`Symbol`) and a `time` (`Time`).

Please note that because a lunar month is around 29 days, some months will have
the same phase twice.

```rb
phases = Astronoby::Events::MoonPhases.phases_for(year: 2024, month: 5)

phases.each { puts "#{_1.phase}: #{_1.time}" }
# last_quarter: 2024-05-01 11:27:15 UTC
# new_moon: 2024-05-08 03:21:56 UTC
# first_quarter: 2024-05-15 11:48:02 UTC
# full_moon: 2024-05-23 13:53:12 UTC
# last_quarter: 2024-05-30 17:12:42 UTC
```

## See also

- [Twilight Times](twilight_times.md) - for sun-related events
- [Rise, Transit and Set Times](rise_transit_set_times.md) - for moon events
- [Solar System Bodies](solar_system_bodies.md) - for moon object details
- [Ephemerides](ephem.md) - for data sources
