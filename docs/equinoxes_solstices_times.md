# Equinoxes and Solstice Times

The equinox and solstice are two precise events that each happen twice a year.

The equinox is the time when the Sun appears directly above the equator, the
solstice is the time when the Sun reaches its most northerly or southerly
excursion relative to the celestial equator on the celestial sphere.

`sky.seasons` finds these four events in the ephemeris, when the Sun's
apparent ecliptic longitude reaches 0°, 90°, 180° and 270°. `in(year)` returns
an `Astronoby::Seasons::Year` with the four of a year, each an
`Astronoby::SeasonStart` with a `kind`, an unrounded `instant`, `equinox?` and
`solstice?`.

```rb
sky = Astronoby::Sky.load("tmp/inpop19a.bsp")
year = sky.seasons.in(2025)

year.march_equinox.instant.to_time.round
# => 2025-03-20 09:01:29 UTC

year.june_solstice.instant.to_time.round
# => 2025-06-21 02:42:16 UTC

year.september_equinox.instant.to_time.round
# => 2025-09-22 18:19:21 UTC

year.december_solstice.instant.to_time.round
# => 2025-12-21 15:03:05 UTC
```

`sky.seasons` is also read with `on(date)`, `between(start, finish)` and
`from(start)`, as on the [Local sky page]:

```rb
sky
  .seasons
  .between(Time.utc(2025, 5, 1), Time.utc(2025, 10, 1))
  .map(&:kind)
# => [:june_solstice, :september_equinox]
```

[Local sky page]: local_sky.md

## See also

- [Twilight Times](twilight_times.md) - for seasonal sun events
- [Moon Phases](moon_phases.md) - for lunar events
- [Sky](sky.md) - for loading an ephemeris
- [Instant](instant.md) - for time handling
