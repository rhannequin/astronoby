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

### Added comparison methods to `Angle` (#21)

With the inclusion of `Comparable`, comparison methods such as `#==`, `#<`,
`#>`, `#<=`, `#>=`, `#!=`, `#<=>` have been added to `Angle`.