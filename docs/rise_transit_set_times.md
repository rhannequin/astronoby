# Rise, Transit and Set Times

Astronoby provides a calculator to compute all the times of all the rise, 
transit and set that will happen to a celestial body from an observer on Earth
during a period of time: `Astronoby::RiseTransitSetCalculator`.

## Initialization

Once instantiated, the calculator doesn't do any anything yet, it waits for your
instruction.

It takes as key arguments:
* `body` (`Astronoby::SolarSystemBody`): any supported celestial body, e.g. `Astronoby::Sun`
* `observer` (`Astronoby::Observer`): location on Earth of the observer
* `ephem`: ephemeris to provide the initial raw data

You can learn more about [celestial bodies] and [ephemerides].

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")

observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(41.0082),
  longitude: Astronoby::Angle.from_degrees(28.9784),
  elevation: Astronoby::Distance.from_meters(40)
)

calculator = Astronoby::RiseTransitSetCalculator.new(
  body: Astronoby::Saturn,
  observer: observer,
  ephem: ephem
)
```

You can learn more about observers on the
[Observer page](https://github.com/rhannequin/astronoby/wiki/Observer).

## `#events_between`

This is the main method of the calculator, it provides all the rising, transit
and setting times that will happen between two times. It returns a
`Astronoby::RiseTransitSetEvents` object which exposes the methods
`#rising_times`, `transit_times` and `#setting_times`.

```rb
events = calculator.events_between(
  Time.utc(2025, 5, 1),
  Time.utc(2025, 5, 3)
)

events.rising_times
# => [2025-05-01 01:28:48 UTC, 2025-05-02 01:25:07 UTC]

events.transit_times
# => [2025-05-01 07:21:34 UTC, 2025-05-02 07:18:01 UTC]

events.setting_times
# => [2025-05-01 13:14:24 UTC, 2025-05-02 13:10:59 UTC]
```

## `#events_on`

You can call `#events_on` to compute the event times that will happen during a
civil day. You can provide a UTC offset to specify the boundaries of the civil
day for your location.

This method also returns a `Astronoby::RiseTransitSetEvents` object because some
celestial bodies could occasionally have the same event happen multiple times in
a single day. This is the case for the Moon, for example, which can seem to rise
twice in the same civil day because of its quick motion around the Earth.

```rb
events = calculator.events_on(Date.new(2025, 5, 1))

events.rising_times
# => [2025-05-01 01:28:48 UTC]

events.transit_times
# => [2025-05-01 07:21:34 UTC]

events.setting_times
# => [2025-05-01 13:14:24 UTC]
```

## `#event_on`

For convenience, `Astronoby::RiseTransitSetCalculator.new` also exposes a
`#event_on` method that behaves the same way as `#events_on` but will return the
first time of rising, transit and setting for the civil date, as they only
happen once in most cases. It returns a `Astronoby::RiseTransitSetEvent` which
exposes the instance methods `#rising_time`, `#transit_time` and
`#setting_time`.

```rb
utc_offset = "+03:00"
event = calculator.event_on(
  Date.new(2025, 5, 1),
  utc_offset: utc_offset
)

event.rising_time.localtime(utc_offset)
# => 2025-05-01 04:28:48 +0300

event.transit_time.localtime(utc_offset)
# => 2025-05-01 10:21:34 +0300

event.setting_time.localtime(utc_offset)
# => 2025-05-01 16:14:24 +0300
```

[celestial bodies]: celestial_bodies.md
[ephemerides]: ephem.md
