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
used in most calculations instead of `Time`. Terrestrial Time runs 32.184
seconds ahead of International Atomic Time, which is itself ahead of UTC by the
leap seconds, so TT - UTC is 32.184 s plus the leap seconds, which Astronoby
reads from [IERS data](iers.md). Before 1961, when UTC did not run yet, a time
is read as UT1, and [Delta T (TT - UT1)][Delta T] is used instead.

`Astronoby::Instant` is a value object that stores an instant in time on Earth
in [Terrestrial Time], an astronomical time standard defined by the
International Astronomical Union, as a [Julian Date].

From this instant in <abbr title="Terrestrial Time">TT</abbr>, other time
standards can be expressed, such as the
<abbr title="International Atomic Time">TAI</abbr> or the
<abbr title="Barycentric Dynamical Time">TDB</abbr>. Those two are computed by
the [horologium] gem, which owns the time scales that convert by definition or
by model. UT1 is not one of them: it follows the actual rotation of the Earth,
so it stays in Astronoby, backed by [IERS data](iers.md).

## Initialization

An `Astronoby::Instant` object can be instantiated from:

- Terrestrial time (`Numeric`): `.from_terrestrial_time`
- Ruby `Time` object: `.from_time`
- UTC Julian date (`Numeric`): `.from_utc_julian_date`

```rb
Astronoby::Instant.from_terrestrial_time(2460796)
# => Represents UTC time 2025-04-30 11:58:50.816

Astronoby::Instant.from_time(Time.utc(2025, 5, 1))
# => Represents terrestrial time Julian Date 2460796.500800741

Astronoby::Instant.from_utc_julian_date(2460796)
# => Represents UTC time 2025-04-30 12:00:00
# => Represents terrestrial time Julian Date 2460796.000800741
```

## Time standards

From the same instant, it is possible to extract different time standards.

- Gregorian `Date`

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.to_date
# => #<Date: 2025-04-30 ((2460796j,0s,0n),+0s,2299161j)>
```

- UTC `DateTime`

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.to_datetime
# => #<DateTime: 2025-04-30T11:58:50+00:00 ((2460796j,43130s,816000000n),+0s,2299161j)>
```

- UTC `Time`

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.to_time
# => 2025-04-30 11:58:50.816 UTC
```

- Greenwich Sidereal Time

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.gmst
# => 2.5596987535483593
```

- International Atomic Time

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.tai.to_f
# => 2460795.9996275
```

- UTC offset (TT - UTC in days, as a `Rational`)

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.utc_offset.to_f
# => 0.0008007407407407408
```

- Barycentric Dynamical Time

```rb
instant = Astronoby::Instant.from_terrestrial_time(2460796)

instant.tdb.to_f
# => 2460796.000000017
```

`tai` and `tdb` are read as a `Rational`. A Julian Date is around 2.46
million, so a single `Float` rounds to about 47 microseconds of the day, which
is more than the whole TDB - TT correction. Call `to_f` when a `Float` is what
you want.

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

[horologium]: https://github.com/rhannequin/horologium
[Gregorian calendar]: https://en.wikipedia.org/wiki/Gregorian_calendar
[Terrestrial Time]: https://en.wikipedia.org/wiki/Terrestrial_Time
[Julian Date]: https://en.wikipedia.org/wiki/Julian_day
[Delta T]: https://en.wikipedia.org/wiki/ΔT_(timekeeping)

## See also

- [Ephemerides](ephem.md) - for time-based calculations
- [Solar System Bodies](solar_system_bodies.md) - for object positions
- [Reference Frames](reference_frames.md) - for coordinate systems
- [Configuration](configuration.md) - for performance settings
