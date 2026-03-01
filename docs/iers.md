# IERS Data

Astronoby relies on the [`iers`](https://github.com/rhannequin/iers) gem for
access to data published by the [International Earth Rotation and Reference
Systems Service (IERS)][IERS]. This data is used for:

- **Delta T (TT - UT1)**: the difference between Terrestrial Time and Universal
  Time, used when converting between UTC and the internal TT time scale (see
  [Instant](instant.md))
- **Greenwich Mean Sidereal Time (GMST)**: computed via the Earth Rotation Angle
  (ERA) based expression from the [IERS Conventions (2010)]

## Data coverage

The `iers` gem ships with bundled IERS data files that work out of the box
with no network access required. The bundled data covers dates roughly from
1800 to early 2027.

- **Before 1800**: Delta T is not available; Astronoby returns 0.
- **After the end of bundled data**: Astronoby uses the last known Delta T
  value, which remains a reasonable approximation for dates in the near future.

## Updating data

The bundled data can be refreshed to extend coverage into the future:

```rb
IERS::Data.update!
```

This downloads the latest IERS finals data and stores it in the gem's cache
directory. Updated data is used automatically on subsequent calculations.

## See also

- [Instant](instant.md) - for time scales and Delta T
- [Configuration](configuration.md) - for performance settings

[IERS]: https://www.iers.org
[IERS Conventions (2010)]: https://www.iers.org/IERS/EN/Publications/TechnicalNotes/tn36.html
