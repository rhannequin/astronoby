# `Instant`

Time in astronomy is usually a slightly different concept than in everyday
life. Today, the vast majority of people use the [Gregorian calendar] and a time
based on <abbr title="Coordinated Universal Time">UTC</abbr>. This timescale is
convenient for matching what we experience on Earth, but it is not static, it
includes leap days, leap seconds.

Also, most of us live in areas where the local legal time is not UTC, so we
have to deal with time zones that are arbitrary and constantly changing.

Astronomical calculations need a stable, uniform and linear time scale, free
from the irregularities in the rotation of Earth and the irregularly fluctuating
mean solar time.

Astronoby handles this situation by implementing an `Astronoby::Instant` class,
used in most calculations instead of `Time`.

`Astronoby::Instant` is a value object that stores an instant in time on Earth
in [Terrestrial Time], an astronomical time standard defined by the
International Astronomical Union, as a [Julian Date].

From this instant in <abbr title="Terrestrial Time">TT</abbr>, other time
standards can be expressed, such as the
<abbr title="International Atomic Time">TAI</abbr> or the
<abbr title="Barycentric Dynamic Time">TDB</abbr>.

## Initialization

An `Astronoby::Instant` object can be instantiated from:
* Terrestrial time (`Numeric`): `.from_terrestrial_time`
* Ruby `Time` object: `.from_time`
* UTC Julian date (`Numeric`): `.from_utc_julian_date`

```rb
Astronoby::Instant.from_terrestrial_time(2460796)
# => Represents UTC time 2025-04-30 11:58:51

Astronoby::Instant.from_time(Time.utc(2025, 5, 1))
# => Represents terrestrial time Julian Date 2460796.500798611

Astronoby::Instant.from_utc_julian_date(2460796)
# => Represents UTC time 2025-04-30 12:00:00
# => Represents terrestrial time Julian Date 2460796.000798611
```

## Time standards

From the same instant, it is possible to extract different time standards.

* Gregorian `Date`

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.to_date
# => #<Date: 2025-04-30 ((2460796j,0s,0n),+0s,2299161j)>
```

* UTC `DateTime`

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.to_datetime
# => #<DateTime: 2025-04-30T11:58:51+00:00 ((2460796j,43131s,12159n),+0s,2299161j)>
```

* UTC `Time`

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.to_datetime
# => 2025-04-30 11:58:51.000012159 UTC
```

* Greenwich Sidereal Time

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.gmst
# => 2.5597425440141457
```

* International Atomic Time

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.tai.to_f
# => 2460795.9996275003
```

* UTC offset (difference with UTC in days)

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.utc_offset.to_f
# => 0.0007986109703819444
```

* Barycentric Dynamic Time

```rb
# This is not handled for now, and returns TT

instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.tdb
# => 2460796
```

## Value Equality

As a value object, it is possible to compare different instants.

```rb
instant1 = Astronoby::Instant.from_terrestrial_time(2460796)
instant2 = Astronoby::Instant.from_terrestrial_time(2460797)

instant1.diff(instant2)
# => -1

instant1 < instant2
# => true
```

[Gregorian calendar]: https://en.wikipedia.org/wiki/Gregorian_calendar
[Terrestrial Time]: https://en.wikipedia.org/wiki/Terrestrial_Time
[Julian Date]: https://en.wikipedia.org/wiki/Julian_day

## See also
- [Ephemerides](ephem.md) - for time-based calculations
- [Solar System Bodies](solar_system_bodies.md) - for object positions
- [Reference Frames](reference_frames.md) - for coordinate systems
- [Configuration](configuration.md) - for performance settings
