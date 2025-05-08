# Upgrading

Astronoby is still in development phase and no major version has been
released yet. Please consider the public API as unstable and expect breaking
changes to it as long as a major version has not been released.

If you are already using Astronoby and wish to follow the changes to its
public API, please read the upgrading notes for each release.

## Upgrading from 0.6.0 to 0.7.0

## Signature change for `Sun` and `Moon`

Both classes are now initialized with the key arguments `ephem` and `instant`.
`ephem` comes from `Ephem.load` which provides the raw geometric data for Solar
System bodies. `instant` is an instance of `Instant`, the new concept for
representing an instant in time.

```rb
Ephem::IO::Download.call(name: "de421.bsp", target: "tmp/de421.bsp")
ephem = Astronoby::Ephem.load("tmp/de421.bsp")

time = Time.utc(2025, 6, 19, 12, 0, 0)
instant = Astronoby::Instant.from_time(time)

sun = Astronoby::Sun.new(instant: instant, ephem: ephem)
```

Learn more on [ephem].

[ephem]: https://github.com/rhannequin/astronoby/wiki/Ephem

## Drop of methods for `Sun`

`Sun` doesn't expose the following class and instance methods anymore:
* `::equation_of_time` (replaced with `#equation_of_time`)
* `#epoch` (replaced with `#instant`)
* `#true_ecliptic_coordinates` (replaced with `#ecliptic` on reference frames)
* `#apparent_ecliptic_coordinates` (replaced with `#ecliptic` on reference frames)
* `#horizontal_coordinates` (replaced with `#horizontal` on the Topocentric reference frame)
* `#observation_events`
* `#twilight_events`
* `#earth_distance` (replaced with `#distance` on referential frames)
* `#angular_size` (replaced with `#angular_diameter` on referential frames)
* `#true_anomaly`
* `#mean_anomaly`
* `#longitude_at_perigee`
* `#orbital_eccentricity`

Learn more on [reference frames].

[reference frames]: https://github.com/rhannequin/astronoby/wiki/Reference-Frames

## Drop of instance methods for `Moon`

`Moon` doesn't expose the following nstance methods anymore:
* `#apparent_ecliptic_coordinates` (replaced with `#ecliptic` on reference frames)
* `#apparent_equatorial_coordinates` (replaced with `#equatorial` on reference frames)
* `#horizontal_coordinates` (replaced with the Apparent and Topocentric reference frames)
* `#distance` (replaced with `#distance` on referential frames)
* `#mean_longitude`
* `#mean_elongation`
* `#mean_anomaly`
* `#argument_of_latitude`
* `#phase_angle`
* `#observation_events`

## Signature change for `Aberration`

`Aberration` is now initialized with the key arguments `astrometric_position`
and `observer_velocity`. `astrometric_position` is a position vector
(`Astronoby::Vector<Astronoby::Distance>`) available from any referential frame
with the `#position` method.`observer_velocity` is a velocity vector
(`Astronoby::Vector<Astronoby::Distance>`) available from any referential frame
with the `#velocity` method.

`observer_velocity` is meant to be a geometric velocity, while
`astrometric_position` is meant to be an astrometric position.

```rb
time = Time.utc(2025, 4, 1)
instant = Astronoby::Instant.from_time(time)
ephem = Astronoby::Ephem.load("de421.bsp")
earth = Astronoby::Earth.new(instant: instant, ephem: ephem)
mars = Astronoby::Mars.new(instant: instant, ephem: ephem)
earth_geometric_velocity = earth.geometric.velocity
mars_astrometric_position = mars.astrometric.position

aberration = Astronoby::Aberration.new(
  astrometric_position: mars_astrometric_position,
  observer_velocity: earth_geometric_velocity
)
```

## Signature change for `Angle#to_dms` and `Angle#to_hms`

`Angle#to_dms` and `Angle#to_hms` don't have arguments anymore. The angle value
is now taken from the object itself. This was a misbehavior in the previous
implementation.

```rb
angle = Astronoby::Angle.from_degrees(45.0)
dms = angle.to_dms

dms.format
# => "+45° 0′ 0.0″"
```

## Signature change for `EquinoxSolstice`

`EquinoxSolstice.new` now takes an additional argument expected to be an ephem
(`Astronoby::Ephem`).

## Signature change for `Nutation`

The expected `epoch` (`Astronoby::Epoch`) argument has been replaced by an
`instant` (`Astronoby::Instant`) key argument.

## Drop of `Nutation::for_ecliptic_longitude` and `Nutation::for_obliquity_of_the_ecliptic`

`Nutation::for_ecliptic_longitude` and `Nutation::for_obliquity_of_the_ecliptic`
methods have been removed. The `Nutation` class now exposes the
`#nutation_in_longitude` and `#nutation_in_obliquity` instance methods which 
both return an angle (`Astronoby::Angle`).

## Signature change for `Precession`

The expected `coordinates` and `epoch` (`Astronoby::Epoch`) key arguments have
been replaced by an `instant` (`Astronoby::Instant`) key argument.

## Drop of `Precession#for_equatorial_coordinates` and `Precession#precess`

`Precession#for_equatorial_coordinates` and `Precession#precess` methods have
been refactoed into class methods.

## Drop of `Coordinates::Horizontal#to_equatorial`

`Coordinates::Horizontal#to_equatorial` has been removed as equatorial
coordinates are now available from the reference frames.

## Drop of instance methods for `Coordinates::Ecliptic`

`Coordinates::Ecliptic#to_true_equatorial` and
`Coordinates::Ecliptic#to_apparent_equatorial` have been removed as
equatorial coordinates are now available from the reference frames.

## Drop of `Coordinates::Equatorial#to_epoch`

`Coordinates::Equatorial#to_epoch` has been removed.

## Drop of `Events::ObservationEvents`

`Events::ObservationEvents` has been removed. The rising, transit and setting 
times can now be calculated using `RiseTransitSetCalculator`.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48),
  longitude: Astronoby::Angle.from_degrees(2)
)
date = Date.new(2025, 4, 24)

calculator = Astronoby::RiseTransitSetCalculator.new(
  body: Astronoby::Sun,
  observer: observer,
  ephem: ephem
)

event = calculator.event_on(date)

event.rising_time
# => 2025-04-24 04:45:42 UTC

event.transit_time
# => 2025-04-24 11:50:04 UTC

event.setting_time
# => 2025-04-24 18:55:24 UTC
```

## Drop of `RiseTransitSetIteration`

`RiseTransitSetIteration` has been removed as it was only used by
`Events::ObservationEvents`.

## Drop of `Events::TwilightEvents`

`Events::TwilightEvents` has been removed. The twilight times can now be
calculated using `TwilightCalculator`.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48),
  longitude: Astronoby::Angle.from_degrees(2)
)
date = Date.new(2025, 4, 24)

calculator = Astronoby::TwilightCalculator.new(
  observer: observer,
  ephem: ephem
)

event = calculator.event_on(date)
# Returns a Astronoby::TwilightEvent object

event.morning_astronomical_twilight_time
# => 2025-04-24 02:43:38 UTC

event.morning_nautical_twilight_time
# => 2025-04-24 03:30:45 UTC

event.morning_civil_twilight_time
# => 2025-04-24 04:12:38 UTC

event.evening_civil_twilight_time
# => 2025-04-24 19:27:34 UTC

event.evening_nautical_twilight_time
# => 2025-04-24 20:09:27 UTC

event.evening_astronomical_twilight_time
# => 2025-04-24 20:56:34 UTC
```

## Drop of `EphemerideLunaireParisienne`

`EphemerideLunaireParisienne` has been removed.

## Drop of `Util::Astrodynamics`

`Util::Astrodynamics` has been removed.

## Drop of `Util::Maths.interpolate` and `Util::Maths.normalize_angles_for_interpolation`

`Util::Maths.interpolate` and `Util::Maths.normalize_angles_for_interpolation`
have been removed.

## Drop of `Constants::SECONDS_PER_DEGREE`

`Constants::SECONDS_PER_DEGREE` has been removed.

## Upgrading from 0.5.0 to 0.6.0

No breaking changes.

## Upgrading from 0.4.0 to 0.5.0

### `Sun#horizontal_coordinates` method signature changed ([#69])

`Astronoby::Sun#horizontal_coordinates` expects an `observer`
(`Astronoby::Observer`) key argument instead of `latitude` and `longitude`
angles.

[#69]: https://github.com/rhannequin/astronoby/pull/69

### `Sun#distance` now returns an `Astronoby::Distance` ([#78])

[#78]: https://github.com/rhannequin/astronoby/pull/78

### `Coordinates::Equatorial#to_horizontal` method signature changed ([#69])

`Astronoby::Coordinates::Equatorial#to_horizontal` expects an `observer`
(`Astronoby::Observer`) key argument instead of `latitude` and `longitude`
angles.

### `Coordinates::Horizontal` constructor and attributes changed ([#69])

`Astronoby::Coordinates::Horizontal::new` now expects an `observer`
(`Astronoby::Observer`) key argument instead of `latitude` and `longitude`,
and therefore now exposes `#observer` instead of `#latitude` and `#longitude`.

### `GeocentricParallax#angle` method signature changed ([#78])

`Astronoby::GeocentricParallax#angle`'s key argument `distance` is now
expected to be an instance of `Astronoby::Distance` instead of a `Numeric`.

### `GeocentricParallax#for_equatorial_coordinates` method signature changed ([#69])

`Astronoby::GeocentricParallax#for_equatorial_coordinates` expects an
`observer` (`Astronoby::Observer`) key argument instead of `latitude`,
`longitude` and `elevation`.

### `Observer` constructor changed ([#78])

`Astronoby::Observer::new`'s key argument `distance` is now expected to be
an instance of `Astronoby::Distance` instead of a `Numeric`.

### `Refraction` methods signatures changed ([#69])

`Astronoby::Refraction`'s constructor doesn't accept the `observer` key
argument anymore. Therefore, the methods `::angle` and
`::correct_horizontal_coordinates` neither.

## Upgrading from 0.3.0 to 0.4.0

### `Body` class removed ([#50])

The different behaviors from `Body` have been moved to other classes like
`Events::ObservationEvents`.

[#50]: https://github.com/rhannequin/astronoby/pull/50

### Rising and setting times and azimuths removed from `Sun` ([#60])

`#rising_time`, `#rising_azimuth`, `#setting_time` and `#setting_azimuth`
have been removed from `Astronoby::Sun` and moved to
`Astronoby::Events::ObservationEvents`.

[#60]: https://github.com/rhannequin/astronoby/pull/60

### `Sun` constructor changed ([#64])

The `Sun` constructor now doesn't accept the `epoch` key argument anymore,
but only a new `time` key argument.

[#64]: https://github.com/rhannequin/astronoby/pull/64

## Upgrading from 0.2.0 to 0.3.0

### `Sun#ecliptic_coordinates` method removed (#41)

Removed in favor of `#true_ecliptic_coordinates` and
`#apparent_ecliptic_coordinates`.

### `Coordinates::Ecliptic#to_horizontal` method removed (#41)

Removed in favor of `#to_true_horizontal` and
`#to_apparent_horizontal`.

### `Sun#true_ecliptic_coordinates` method added (#41)

Returns the true ecliptic coordinates for the date's epoch.

### `Sun#apparent_ecliptic_coordinates` method added (#41)

Returns the apparent ecliptic coordinates for the date's epoch, including
corrections for the nutation and aberration.

### `Coordinates::Ecliptic#to_true_horizontal` method added (#41)

Returns the true equatorial coordinates for ths date's epoch.

### `Coordinates::Ecliptic#to_apparent_horizontal` method added (#41)

Returns the apparent equatorial coordinates for the date's epoch, including
corrections for the obliquity.

### `Angle::as_radians` renamed into `Angle::from_radians` (#43)

Behaviour not changed.

### `Angle::as_degrees` renamed into `Angle::from_degrees` (#43)

Behaviour not changed.

### `Angle::as_hours` renamed into `Angle::from_hours` (#43)

Behaviour not changed.

### `Angle::as_dms` renamed into `Angle::from_dms` (#43)

Behaviour not changed.

### `Angle::as_hms` renamed into `Angle::from_hms` (#43)

Behaviour not changed.

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

### `Sun::equation_of_time` method added (#40)

Returns the equation of time for a given date.

### `Sun#distance` method added (#30)

Returns the approximate Earth-Sun distance in meters (`Numeric`).

### `Sun#angular_size` method added (#30)

Returns the apparent Sun's angular size (`Angle`).

### `Sun#true_anomaly` method added (#32)

Returns the apparent Sun's true anomaly (`Angle`).

### `Sun#longitude_at_perigee` method added (#32)

Returns the apparent Sun's longitude (`Angle`) at its perigee.

### `Sun#rising_time` method added (#35)

Returns the UTC `Time` of the sunrise.`

### `Sun#rising_azimuth` method added (#39)

Returns the Sun's azimuth (`Angle`) at sunrise.

### `Sun#setting_time` method added (#35)

Returns the UTC `Time` of the sunset.

### `Sun#setting_azimuth` method added (#39)

Returns the Sun's azimuth (`Angle`) at sunset.

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
