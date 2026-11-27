# Local sky

`sky.over(observer)` returns an `Astronoby::LocalSky`: the sky as seen by one observer, with everything that depends on where they stand. You can learn how to load a sky on the [Sky page] and how to define an observer on the [Observer page].

```rb
sky = Astronoby::Sky.load("tmp/de440s.bsp")
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.836614),
  longitude: Astronoby::Angle.from_degrees(2.336675)
)
local_sky = sky.over(observer)
```

## Event series

Each method of the local sky returns an `Astronoby::Events::Series`, which searches nothing until it is read with one of these:

- `on(date, utc_offset: 0)` returns the events of a civil day, from midnight to the next midnight in the given offset.
- `between(start, finish)` returns the events between two instants (or `Time` objects), both ends included.
- `from(start)` returns a lazy enumerator that searches one day at a time, as events are asked for.

```rb
local_sky.risings(sky.moon)
  .from(Astronoby::Instant.from_time(Time.utc(2025, 10, 1)))
  .first(3)
  .map { |instant| instant.to_time.round }
# => [2025-10-01 15:17:42 UTC, 2025-10-02 15:43:31 UTC, 2025-10-03 16:04:03 UTC]
```

`from` stops at the end of the ephemeris or after a year, whichever comes first, and right away when a fixed star never reaches the altitude. It raises `Ephem::OutOfRangeError` when the ephemeris does not cover its start.

Events come sorted by time, and their instants are not rounded.

## Passes

A pass is one passage of a target across the observer's meridian, with the rising before it and the setting after it. `passes` returns `Astronoby::Pass` objects, dated by their transit, so a pass is complete even when the target sets after midnight:

```rb
pass = local_sky.passes(sky.saturn).on(Date.new(2025, 10, 1)).first

pass.rising.to_time.round
# => 2025-10-01 17:14:45 UTC

pass.transit.to_time.round
# => 2025-10-01 23:02:27 UTC

pass.setting.to_time.round
# => 2025-10-02 04:50:04 UTC
```

`rising` and `setting` are `nil` when the target does not cross the horizon, for a circumpolar star for example.

Risings and settings follow each body's standard horizon, as on the [Rise, transit and setting times page]: the upper limb of the Sun and the Moon, refraction included.

## Risings, transits and settings

`risings`, `transits` and `settings` return the instants of one kind of event:

```rb
local_sky.settings(sky.sun)
  .on(Date.new(2025, 10, 1), utc_offset: "+02:00")
  .map { |instant| instant.to_time.round }
# => [2025-10-01 17:29:15 UTC]
```

Each of them runs its own search. When you need the three, `passes` finds them in one search.

## Crossings

`crossings` returns when a target crosses any altitude, as `Astronoby::AltitudeCrossing` objects. The altitude is either apparent, refraction included, or true:

```rb
Astronoby::Altitude.apparent(degrees: 5)
Astronoby::Altitude.true(degrees: -18)
```

The target's centre crosses the altitude, unless one of its limbs is given:

```rb
crossings = local_sky
  .crossings(sky.moon.upper_limb, Astronoby::Altitude.apparent(degrees: 5))
  .on(Date.new(2025, 10, 1))

crossings.map { |crossing| [crossing.direction, crossing.instant.to_time.round] }
# => [[:rising, 2025-10-01 16:03:59 UTC], [:setting, 2025-10-01 22:41:08 UTC]]
```

You can learn more about crossings, and about grazing ones, on the [Altitude crossings page].

## Twilights

`twilights` returns the civil, nautical and astronomical dawns and dusks, as `Astronoby::TwilightCrossing` objects: the Sun's centre crossing 6°, 12° and 18° below the horizon.

```rb
local_sky.twilights.on(Date.new(2025, 10, 1)).select(&:dusk?).map do |twilight|
  [twilight.kind, twilight.instant.to_time.round]
end
# => [
#   [:civil, 2025-10-01 18:00:38 UTC],
#   [:nautical, 2025-10-01 18:37:12 UTC],
#   [:astronomical, 2025-10-01 19:14:28 UTC]
# ]
```

## Targets

Every method accepts a target of the sky (`sky.saturn`, `sky[vega]`) or a deep-sky object directly. `crossings` also accepts a point of a Solar System body: `sky.moon.center`, `sky.moon.upper_limb` or `sky.moon.lower_limb`.

[Sky page]: sky.md
[Observer page]: observer.md
[Rise, transit and setting times page]: rise_transit_set_times.md
[Altitude crossings page]: altitude_crossings.md
