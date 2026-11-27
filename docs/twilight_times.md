# Twilight times

In astronomy, twilight is a period of time when the Sun is already set but
some of its light still illuminates the atmosphere, making the sky brighter than
during full night.

We usually define 4 moments when talking about twilight:

- sunrise/sunset: right when the Sun goes above the horizon or right after it
  goes below the horizon. The Sun's horizon angle is 0°.
- civil twilight: when the horizon angle is between 0° and -6°. Usually, during
  this time, artificial light is not needed yet.
- nautical twilight: when the horizon angle is between -6° and -12°. When the
  nautical twilight starts, the difference between the horizon at sea and the
  sky cannot be seen clearly anymore.
- astronomical twilight: when the horizon angle is between -12° and -18°. Some
  stars can be seen during this time.

These moments change every day and depend on the observer's location. A local
sky (`Astronoby::LocalSky`) gives them with `twilights`. You can learn more
about it on the [Local sky page], and about observers on the [Observer page].

```rb
sky = Astronoby::Sky.load("tmp/inpop19a.bsp")

observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(41.0082),
  longitude: Astronoby::Angle.from_degrees(28.9784),
  elevation: Astronoby::Distance.from_meters(40)
)

local_sky = sky.over(observer)
```

## Twilight crossings

`twilights` returns `Astronoby::TwilightCrossing` objects, sorted by time: the
Sun's centre crossing 6°, 12° and 18° below the horizon. Each has a `kind`
(`:civil`, `:nautical` or `:astronomical`), an `instant`, and `dawn?` or
`dusk?` for the rising or the setting Sun.

```rb
twilights = local_sky.twilights.on(Date.new(2025, 5, 1))

twilights.map { |twilight| [twilight.kind, twilight.dawn?] }
# => [
#   [:astronomical, true],
#   [:nautical, true],
#   [:civil, true],
#   [:civil, false],
#   [:nautical, false],
#   [:astronomical, false]
# ]

twilights.select(&:dusk?).map { |twilight| twilight.instant.to_time.round }
# => [2025-05-01 17:30:50 UTC, 2025-05-01 18:07:27 UTC, 2025-05-01 18:47:10 UTC]
```

`between` returns the twilights between two times:

```rb
local_sky
  .twilights
  .between(Time.utc(2025, 8, 1), Time.utc(2025, 8, 4))
  .select { |twilight| twilight.kind == :civil && twilight.dawn? }
  .map { |twilight| twilight.instant.to_time.round }
# => [2025-08-01 02:29:11 UTC, 2025-08-02 02:30:15 UTC, 2025-08-03 02:31:20 UTC]
```

## Accuracy and polar regions

Each twilight is the moment the Sun's centre, without refraction, reaches the
matching altitude, found by the same search as altitude crossings. Instants are
not rounded. Twilight that exists is returned even when the Sun does not rise
or set that day, as in a polar night. Use `crossings`, described on the
[Altitude crossings page], for other altitudes.

[Local sky page]: local_sky.md
[Observer page]: observer.md
[Altitude crossings page]: altitude_crossings.md

## See also

- [Local sky](local_sky.md) - for everything an observer sees
- [Altitude Crossings](altitude_crossings.md) - for any altitude
- [Rise, Transit and Set Times](rise_transit_set_times.md) - for sun and moon events
- [Observer](observer.md) - for location setup
- [Moon Phases](moon_phases.md) - for lunar events
