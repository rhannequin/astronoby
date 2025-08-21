# Twilight times

In astronomy, twilight is a period of time when the Sun is already set but
some of its light still illuminates the atmosphere, making the sky brighter than
during full night.

We usually define 4 moments when talking about twilight:
* sunrise/sunset: right when the Sun goes above the horizon or right after it
  goes below the horizon. The Sun's horizon angle is 0°.
* civil twilight: when the horizon angle is between 0° and -6°. Usually, during
  this time, artificial light is not needed yet.
* nautical twilight: when the horizon angle is between -6° and -12°. When the
  nautical twilight starts, the difference between the horizon at sea and the
  sky cannot be seen clearly anymore.
* astronomical twilight: when the horizon angle is between -12° and -18°. Some
  stars can be seen during this time.

These moments change every day and depend on the observer's location. They can
be computed using `Astronoby::TwilightCalculator`.

## Initialization

Once instantiated, the calculator doesn't do anything yet, it waits for your
instruction.

It takes as key arguments:
* `observer` (`Astronoby::Observer`): location on Earth of the observer
* `ephem`: ephemeris to provide the initial raw data

You can learn more about ephemerides on the [Ephem page].

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")

observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(41.0082),
  longitude: Astronoby::Angle.from_degrees(28.9784),
  elevation: Astronoby::Distance.from_meters(40)
)

calculator = Astronoby::TwilightCalculator.new(
  observer: observer,
  ephem: ephem
)
```

You can learn more about observers on the [Observer page].

## `events_between`

This is the main method of the calculator. It provides all the twilight times
that will happen between two dates.

It returns a `Astronoby::TwilightEvents` object which exposes the 6 following
instance methods:
* `#morning_astronomical_twilight_times`: when the rising Sun reaches 18° below
  the horizon
* `#morning_nautical_twilight_times`: when the rising Sun reaches 12° below the
  horizon
* `#morning_civil_twilight_times`: when the rising Sun reaches 6° below the
  horizon
* `#evening_civil_twilight_times`: when the setting Sun reaches 6° below the
  horizon
* `#evening_nautical_twilight_times`: when the setting Sun reaches 12° below the
  horizon
* `#evening_astronomical_twilight_times`: when the setting Sun reaches 18° below
  the horizon

```rb
events = calculator.events_between(
  Time.utc(2025, 8, 1),
  Time.utc(2025, 8, 8)
)

events.morning_civil_twilight_times
# =>
# [2025-08-01 02:29:17 UTC,
#  2025-08-02 02:30:21 UTC,
#  2025-08-03 02:31:26 UTC,
#  2025-08-04 02:32:30 UTC,
#  2025-08-05 02:33:35 UTC,
#  2025-08-06 02:34:40 UTC,
#  2025-08-07 02:35:45 UTC]
```

## `#event_on`

The calculator exposes the instance method `#event_on` to compute the twilight
times for a given `date` (`Date`) parameter.

It returns a `Astronoby::TwilightEvent` object which exposes the 6 following
instance methods: `#morning_astronomical_twilight_time`,
`#morning_nautical_twilight_time`, `#morning_civil_twilight_time`,
`#evening_civil_twilight_time`, `#evening_nautical_twilight_time` and
`#evening_astronomical_twilight_time`.

```rb
event = calculator.event_on(Date.new(2025, 5, 1))

event.morning_astronomical_twilight_time
# => 2025-05-01 01:17:18 UTC

event.morning_nautical_twilight_time
# => 2025-05-01 01:56:48 UTC

event.evening_civil_twilight_time
# => 2025-05-01 17:29:41 UTC

event.evening_nautical_twilight_time
# => 2025-05-01 18:06:08 UTC

event.evening_astronomical_twilight_time
# => 2025-05-01 18:45:38 UTC
```

[Ephem page]: ephem.md
[Observer page]: observer.md

## See also
- [Rise, Transit and Set Times](rise_transit_set_times.md) - for sun and moon events
- [Observer](observer.md) - for location setup
- [Ephemerides](ephem.md) - for data sources
- [Moon Phases](moon_phases.md) - for lunar events
