# Deep-sky Bodies

Deep-sky objects represent celestial object that are not part of the Solar
System, like stars, nebulae, clusters, galaxies. They are not affected by any
body of the Solar System.

Because we know billions of there objects, it is impossible for Astronoby to
store a comprehensive catalogue. Therefore, it is up to the developer to build
the object they need, based on equatorial coordinates from official catalogues
at J2000 epoch. The [SIMBAD Astronomical Database] is an example of database
where such coordinates can be found.

Astronoby makes the difference between the body and the position.
`Astronoby::DeepSkyObject` represent the body in itself, defined by fixed
coordinates. It can also be support proper motion parameters, also given from
official catalogues, which provides a bit more precision.

```rb
vega_j2000 = Astronoby::Coordinates::Equatorial.new(
  right_ascension: Astronoby::Angle.from_hms(18, 36, 56.33635),
  declination: Astronoby::Angle.from_dms(38, 47, 1.2802),
  epoch: Astronoby::JulianDate::J2000
)

vega = Astronoby::DeepSkyObject.new(equatorial_coordinates: vega_j2000)

vega_with_proper_motion = Astronoby::DeepSkyObject.new(
  equatorial_coordinates: vega_j2000,
  proper_motion_ra: Astronoby::AngularVelocity
    .from_milliarcseconds_per_year(200.94),
  proper_motion_dec: Astronoby::AngularVelocity
    .from_milliarcseconds_per_year(286.23),
  parallax: Astronoby::Angle.from_degree_arcseconds(130.23 / 1000.0),
  radial_velocity: Astronoby::Velocity.from_kilometers_per_second(-13.5)
)
```

From a `DeepSkyObject` instance, it is possible to instantiate the position
of the body at a given instant. If given the optional `ephem` parameter,
precision will increase as some astronomical corrections will be
applied.

A `DeepSkyPosition` object exposes `astrometric`, `apparent` and `topocentric`
reference frames.

```rb
time = Time.utc(2025, 10, 1)
instant = Astronoby::Instant.from_time(time)

ephem = Astronoby::Ephem.load("inpop19a.bsp")

vega
  .at(instant)
  .apparent
  .equatorial
  .right_ascension
  .str(:hms)
# => "18h 37m 48.2804s"

vega_with_proper_motion
  .at(instant, ephem: ephem)
  .apparent
  .equatorial
  .right_ascension
  .str(:hms)
# => "18h 37m 48.706s"
```

You can learn more about [ephemerides] and [reference frames].

A deep-sky body object can also be used in calculators.

```rb
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(51.5072),
  longitude: Astronoby::Angle.from_degrees(-0.1276)
)
date = Date.new(2025, 10, 1)

body = Astronoby::DeepSkyObject.new(
  equatorial_coordinates: Astronoby::Coordinates::Equatorial.new(
    right_ascension: Astronoby::Angle.from_hms(6, 45, 8.917),
    declination: Astronoby::Angle.from_dms(-16, 42, 58.02)
  )
)

calculator = Astronoby::RiseTransitSetCalculator.new(
  body: body,
  observer: observer,
  ephem: ephem
)

event = calculator.event_on(date)

event.rising_time
# => 2025-10-01 01:31:25 UTC
```

[ephemerides]: ephem.md
[reference frames]: reference_frames.md
[SIMBAD Astronomical Database]: https://simbad.u-strasbg.fr/simbad/
