# Reference Frames

A given body at a given time can be perceived at different positions, depending
on the reference frame and the corrections applied.

Astronoby provides five reference frames for each celestial body:

* Geometric
* Astrometric
* Mean of date
* Apparent
* Topocentric

All reference frames provide this common interface:

* `#position`: Vector of position as x,y,z `Astronoby::Distance` objects
* `#velocity`: Vector of velocity as x,y,z `Astronoby::Velocity` objects
* `#distance`: Distance from the centre (`Astronoby::Distance`)
* `#equatorial`: Equatorial coordinates (`Astronoby::Coordinates::Equatorial`)
* `#ecliptic`: Ecliptic coordinates (`Astronoby::Coordinates::Ecliptic`)

## Geometric

Also called "mean J2000", this reference frame is related to the mean ecliptic
or terrestrial equator and the mean equinox of the reference date (J2000). It is
the strict position computed from the ephemeris file in a reference frame
centered on the Solar System barycentre, with no corrections applied.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(1962, 7, 24)
instant = Astronoby::Instant.from_time(time)

moon = Astronoby::Moon.new(ephem: ephem, instant: instant)
geometric = moon.geometric
# => #<Astronoby::Geometric:0x000000011e7ffd40

geometric.distance.au
# => 1.0095091198501744

geometric.equatorial.right_ascension.str(:hms, precision: 0)
# => "20h 13m 52s"
```

## Astrometric

Also called "astrometric J2000", this reference frame is related to the ecliptic
or the mean terrestrial equator and the mean equinox of the reference date
(J2000). It applies light-time correction between the celestial body and the
observer. The frame is centred on the Earth's centre, as are all the following
reference frames.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(1962, 7, 24)
instant = Astronoby::Instant.from_time(time)

moon = Astronoby::Moon.new(ephem: ephem, instant: instant)
astrometric = moon.astrometric

astrometric.distance.km.round
# => 371187

astrometric.equatorial.right_ascension.str(:hms, precision: 0)
# => "1h 54m 27s"
```

## Mean of date

This reference frame is related to the ecliptic or the mean equator and the mean
equinox of the date. It provides the geometric position corrected for the
precessional motion of the Earth's rotation axis (precession and nutation).


```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(1962, 7, 24)
instant = Astronoby::Instant.from_time(time)

moon = Astronoby::Moon.new(ephem: ephem, instant: instant)
mean_of_date = moon.mean_of_date

mean_of_date.equatorial.right_ascension.str(:hms, precision: 0)
# => "1h 52m 29s"
```

## Apparent

This reference frame is related to the true ecliptic or equator and the true
equinox of the date. It is the actual position in the sky of a celestial object
as seen from the centre of the Earth. It applies several corrections to the
astrometric position:the deflection of light, the aberration, the precession and
the nutation.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(1962, 7, 24)
instant = Astronoby::Instant.from_time(time)

moon = Astronoby::Moon.new(ephem: ephem, instant: instant)
apparent = moon.apparent

apparent.equatorial.right_ascension.str(:hms, precision: 0)
# => "1h 52m 28s"
```

## Topocentric

This reference frame is the final transformation of a position. It provides the
apparent position of a celestial body as seen from a location on Earth. It can
only be produced given an observer (`Astronoby::Observer`). It provides another
set of coordinates: horizontal (`Astronoby::Coordinates::Horizontal`).

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(1962, 7, 24)
instant = Astronoby::Instant.from_time(time)
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.838),
  longitude: Astronoby::Angle.from_degrees(2.4843)
)

moon = Astronoby::Moon.new(ephem: ephem, instant: instant)
topocentric = moon.observed_by(observer)

topocentric.horizontal.azimuth.str(:dms, precision: 0)
# => "+90° 14′ 19″"
```

You can learn more about observers on the [Observer page].

[Observer page]: observer.md
