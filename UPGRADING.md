# Upgrading

Astronoby is still in development phase and no major version has been
released yet. Please consider the public API as unstable and expect breaking
changes to it as long as a major version has not been released.

If you are already using Astronoby and wish to follow the changes to its
public API, please read the upgrading notes for each release.

## Upgrading from 0.1.0 to 0.2.0

### `Observer` class added (#29)

The `Observer` class aims to represent an observer's location and local
parameters such as the temperature and astmospheric pressure.

### `Refraction` constructor changed (#29)

`Refraction.new` now takes the following arguments:

* `coordinates` (`Coordinates::Horizontal`)
* `observer` (`Observer`)

### `Refraction::for_horizontal_coordinates` removed (#29)

Please now use `Refraction.correct_horizontal_coordinates`.

### `Refraction::angle` added (#29)

This returns a refraction angle (`Angle`) based on an observer (`Observer`)
and the horizontal coordinates (`Coordinates::Horizontal`) of a body in the sky.

### `apparent` argument added to `Body::rising_time` (#29)

With a default value of `true`, this new argument will make consider a
default vertical refraction angle or not.

### `apparent` argument added to `Body::setting_time` (#29)

With a default value of `true`, this new argument will make consider a
default vertical refraction angle or not.

### `Sun#distance` method added (#30)

Returns the approximate Earth-Sun distance in meters (`Numeric`).

### `Sun#angular_size` method added (#30)

Returns the apparent Sun's angular size (`Angle`).

### `Sun#true_anomaly` method added (#32)

Returns the apparent Sun's true anomaly (`Angle`).

### `Sun#longitude_at_perigee` method added (#32)

Returns the apparent Sun's longitude (`Angle`) at its perigee.

### Added comparison methods to `Angle` (#21)

With the inclusion of `Comparable`, comparison methods such as `#==`, `#<`,
`#>`, `#<=`, `#>=`, `#!=`, `#<=>` have been added to `Angle`.

### `GeocentricParallax` class added

Calculates the equatorial horizontal parallax for an observed body. The
class provided two class methods:
- `::angle` which returns the parallax angle
- `::for_equatorial_coordinates` which correct equatorial coordinates with
  the parallax correction

### `EquinoxSolstice` class added

This class exposes `::march_equinox`, `::june_solstice`,
`::september_equinox` and `::december_soltice` that all require a year
(`Integer`) as parameter and return a date-time (`Time`) computed for the event.

### `Util::Time` class dropped

Time-related utility functions have been deleted, in favor of new classes
(see below).

### `GreenwichSiderealTime` class added

Enables to instantiate a GST from UTC, or convert a GST to UTC.

### `LocalSiderealTime` class added

Enables to instantiate a LST from GST, or convert a LST to GST.
