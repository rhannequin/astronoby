# Rise, Transit and Set Times

A local sky (`Astronoby::LocalSky`) gives the rise, transit and set times of a
celestial body as observed from a place on Earth. You can learn more about it
on the [Local sky page], and about observers on the [Observer page].

```rb
sky = Astronoby::Sky.load("tmp/inpop19a.bsp")

observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(41.0082),
  longitude: Astronoby::Angle.from_degrees(28.9784),
  elevation: Astronoby::Distance.from_meters(40)
)

local_sky = sky.over(observer)
```

## Passes

`passes` returns each passage of a body across the observer's meridian as an
`Astronoby::Pass`, with the rising before the transit and the setting after it.
A pass is dated by its transit, so it is complete even when the body sets after
midnight.

```rb
passes = local_sky
  .passes(sky.saturn)
  .between(Time.utc(2025, 5, 1), Time.utc(2025, 5, 3))

passes.map { |pass| pass.rising.to_time.round }
# => [2025-05-01 01:28:48 UTC, 2025-05-02 01:25:07 UTC]

passes.map { |pass| pass.transit.to_time.round }
# => [2025-05-01 07:21:34 UTC, 2025-05-02 07:18:01 UTC]

passes.map { |pass| pass.setting.to_time.round }
# => [2025-05-01 13:14:24 UTC, 2025-05-02 13:10:58 UTC]
```

`rising` and `setting` are `nil` when the body does not cross the horizon, for
a circumpolar star for example.

## A civil day

`on` returns the passes whose transit falls on a civil day. You can provide a
UTC offset to set the boundaries of the day for your location.

```rb
utc_offset = "+03:00"
pass = local_sky
  .passes(sky.saturn)
  .on(Date.new(2025, 5, 1), utc_offset: utc_offset)
  .first

pass.rising.to_time.round.localtime(utc_offset)
# => 2025-05-01 04:28:48 +0300

pass.transit.to_time.round.localtime(utc_offset)
# => 2025-05-01 10:21:34 +0300

pass.setting.to_time.round.localtime(utc_offset)
# => 2025-05-01 16:14:24 +0300
```

## Risings, transits and settings

`risings`, `transits` and `settings` return the instants of one kind of event,
whichever pass they belong to. Some bodies can have the same event twice in a
civil day: the Moon, for example, can seem to rise twice because of its quick
motion around the Earth.

```rb
local_sky
  .risings(sky.moon)
  .on(Date.new(2025, 5, 1))
  .map { |instant| instant.to_time.round }
# => [2025-05-01 05:29:19 UTC]
```

Each of them runs its own search. When you need the three, `passes` finds them
in one search.

## Horizon

Risings and settings are the instants when a body crosses the standard horizon:
34′ below the true horizon for refraction, and for the Sun and the Moon, their
upper limb rather than their centre. To use another altitude or another point
of the disk, use `crossings`, described on the [Altitude crossings page].

Instants are not rounded: `instant.to_time.round` gives the time to the second.

[Local sky page]: local_sky.md
[Observer page]: observer.md
[Altitude crossings page]: altitude_crossings.md

## See also

- [Local sky](local_sky.md) - for everything an observer sees
- [Twilight Times](twilight_times.md) - for sun-related events
- [Solar System Bodies](solar_system_bodies.md) - for object information
- [Observer](observer.md) - for location setup
