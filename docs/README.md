# Quick Start

## Download an ephemeris

You only need to run this once, it will download and store an ephemeris on your
file system.

```rb
Ephem::IO::Download.call(name: "de421.bsp", target: "tmp/de421.bsp")
```

Ephemerides can be large files, but Astronoby provides a tool to drastically
reduce the size to your needs. You can learn more about ephemerides on the
[Ephem page](https://github.com/rhannequin/astronoby/wiki/Ephem).

## Load an ephemeris

```rb
ephem = Astronoby::Ephem.load("tmp/de421.bsp")
```

## Define a time and create an `Instant` object from it

```rb
time = Time.utc(2025, 6, 19, 12, 0, 0)
instant = Astronoby::Instant.from_time(time)
```

You can learn more about time scales on the
[Instant page](https://github.com/rhannequin/astronoby/wiki/Instant).

## Instantiate a Solar System body's object

```rb
jupiter = Astronoby::Jupiter.new(instant: instant, ephem: ephem)
```

You can learn more about planets and bodies on the
[Celestial Bodies page](https://github.com/rhannequin/astronoby/wiki/Celestial-Bodies).

## Define an observer from geographic coordinates

```rb
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.83661378408946),
  longitude: Astronoby::Angle.from_degrees(2.3366748126024466),
  elevation: Astronoby::Distance.from_meters(65)
)
```

You can learn more about angles on the [Angles page](angles.md), and about
observers on the
[Observer page](https://github.com/rhannequin/astronoby/wiki/Observer).

## Compute the topocentric position of the body as seen from the observer

```rb
topocentric = jupiter.observed_by(observer)
```

You can learn more about reference frames and positions on the
[Reference Frames page](https://github.com/rhannequin/astronoby/wiki/Reference-Frames).

## Get the horizontal coordinates from the position

```rb
topocentric.horizontal.azimuth.str(:dms)
# => "+175° 34′ 28.2724″"

topocentric.horizontal.altitude.str(:dms)
# => "+64° 22′ 58.1084″"
```

You can learn more about coordinates on the
[Coordinates page](https://github.com/rhannequin/astronoby/wiki/Coordinates).

## Get the rising, transit and setting times between two times

```rb
calculator = Astronoby::RiseTransitSetCalculator.new(
  body: Astronoby::Jupiter,
  observer: observer,
  ephem: ephem
)

events = calculator.events_between(
  Time.utc(2025, 5, 1),
  Time.utc(2025, 5, 3),
)

events.rising_times
# => [2025-05-01 06:35:35 UTC, 2025-05-02 06:32:26 UTC]

events.transit_times
# => [2025-05-01 14:34:34 UTC, 2025-05-02 14:31:31 UTC]

events.setting_times
# => [2025-05-01 22:33:37 UTC, 2025-05-02 22:30:39 UTC]
```

You can learn more about this calculator on the
[Rise, transit and setting times page](https://github.com/rhannequin/astronoby/wiki/Rise,-transit-and-set-times).

## Get the twilight times of the day

```rb
calculator = Astronoby::TwilightCalculator.new(
  observer: observer,
  ephem: ephem
)

event = calculator.event_on(Date.new(2025, 5, 1))

event.morning_astronomical_twilight_time
# => 2025-05-01 02:17:28 UTC

event.morning_nautical_twilight_time
# => 2025-05-01 03:10:17 UTC

event.morning_civil_twilight_time
# => 2025-05-01 03:55:17 UTC

event.evening_civil_twilight_time
# => 2025-05-01 19:40:12 UTC

event.evening_nautical_twilight_time
# => 2025-05-01 20:25:12 UTC

event.evening_astronomical_twilight_time
# => 2025-05-01 21:18:01 UTC
```

You can learn more about this calculator on the
[Twilight times page](https://github.com/rhannequin/astronoby/wiki/Twilight-times).

## Moon phases

You can either get all the major Moon phases that will happen in a month, or get
information about the current Moon phase.

```rb
may_2024_phases = Astronoby::Events::MoonPhases.phases_for(year: 2024, month: 5)

may_2024_phases.each { puts "#{_1.phase}: #{_1.time}" }
# last_quarter: 2024-05-01 11:27:15 UTC
# new_moon: 2024-05-08 03:21:56 UTC
# first_quarter: 2024-05-15 11:48:02 UTC
# full_moon: 2024-05-23 13:53:12 UTC
# last_quarter: 2024-05-30 17:12:43 UTC
```

```rb
time = Time.utc(2025, 5, 15)
instant = Astronoby::Instant.from_time(time)
moon = Astronoby::Moon.new(ephem: ephem, instant: instant)

moon.illuminated_fraction.round(2)
# => 0.15

moon.current_phase_fraction.round(2)
# => 0.11
```

You can learn more about phases on the
[Moon phases page](https://github.com/rhannequin/astronoby/wiki/Moon-phases).

## Equinox and solstice times

```rb

Astronoby::EquinoxSolstice.march_equinox(2025, ephem)
# => 2025-03-20 09:01:29 UTC

Astronoby::EquinoxSolstice.june_solstice(2025, ephem)
# => 2025-06-21 02:42:19 UTC

Astronoby::EquinoxSolstice.september_equinox(2025, ephem)
# => 2025-09-22 18:19:22 UTC

Astronoby::EquinoxSolstice.december_solstice(2025, ephem)
# => 2025-12-21 15:03:03 UTC
```

You can learn more about equinoxes and solstices on the
[Equinoxes and solstices times page].

[Equinoxes and solstices times page]: equinoxes_solstices_times.md
