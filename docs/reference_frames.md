# Reference Frames

A given body at a given time can be perceived at different positions, depending
on the reference frame and the corrections applied.

Astronoby provides five reference frames for each celestial body, forming a
transformation chain:

```
Geometric (BCRS)
  → Astrometric (GCRS)
    → Mean of date
      → Apparent
        → Topocentric
```

Each step applies physical corrections to move closer to what an observer
actually sees. The standard reference systems used follow the IAU/IERS
conventions (see [Standard reference systems](#standard-reference-systems)
below).

All reference frames provide this common interface:

- `#position`: Vector of position as x,y,z `Astronoby::Distance` objects
- `#velocity`: Vector of velocity as x,y,z `Astronoby::Velocity` objects
- `#distance`: Distance from the centre (`Astronoby::Distance`)
- `#equatorial`: Equatorial coordinates (`Astronoby::Coordinates::Equatorial`)
- `#ecliptic`: Ecliptic coordinates (`Astronoby::Coordinates::Ecliptic`)

## Geometric

The geometric frame corresponds to the **Barycentric Celestial Reference System
(BCRS)**, centered on the Solar System barycentre, with axes aligned to the
**International Celestial Reference System (ICRS)**. It is the raw position
read from the ephemeris file, with no corrections applied.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(1962, 7, 24)
instant = Astronoby::Instant.from_time(time)

moon = Astronoby::Moon.new(ephem: ephem, instant: instant)
geometric = moon.geometric
# => #<Astronoby::Geometric:0x000000011e7ffd40

geometric.distance.au
# => 1.0095091267969827

geometric.equatorial.right_ascension.str(:hms, precision: 0)
# => "20h 13m 52s"
```

## Astrometric

The astrometric frame corresponds to the **Geocentric Celestial Reference System
(GCRS)**, centered on the Earth's centre, with axes still aligned to the ICRS.
It is obtained by subtracting the Earth's barycentric position from the target's
light-time-corrected barycentric position. All subsequent frames are also
Earth-centered.

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

This frame is referred to the **mean equator and mean equinox of the date**. It
is obtained by applying the precession-bias matrix to the geocentric ICRS
position, rotating it from the ICRS axes to the mean pole and equinox at the
given instant.

Astronoby uses the **IAU 2006 precession** model in its Fukushima-Williams
four-angle parameterization, which includes the ICRS-to-J2000 frame bias.

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

This frame is referred to the **true equator and true equinox of the date**. It
represents the position of a celestial object as seen from the centre of the
Earth. The following corrections are applied to the astrometric position:

- **Aberration**: relativistic stellar aberration due to Earth's velocity
  (Explanatory Supplement, Ch. 7.2.3)
- **Precession**: IAU 2006 Fukushima-Williams precession-bias matrix
- **Nutation**: IAU 2000B 77-term nutation model

The combined N * PB matrix rotates the aberration-corrected GCRS position into
the true equator and equinox frame of the date.

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

This is the final frame in the chain, providing the position of a celestial body
as seen from a specific location on Earth's surface. It can only be produced
given an observer (`Astronoby::Observer`). It provides an additional set of
coordinates: horizontal (`Astronoby::Coordinates::Horizontal`).

To go from the apparent frame (true equator and equinox) to the topocentric
frame, the observer's position must be transformed from the **International
Terrestrial Reference System (ITRS)** into the same true-equinox frame. This is
done by applying the **IERS polar motion matrix** (W) followed by the Earth
rotation via **Greenwich Apparent Sidereal Time (GAST)**.

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
# => "+90° 14′ 24″"
```

You can learn more about observers on the [Observer page].

## Standard reference systems

The table below maps Astronoby's reference frames to standard IAU/IERS
reference systems and lists the corrections applied at each step.

| Astronoby frame | Standard system | Origin | Axes | Corrections applied |
|-----------------|-----------------|--------|------|---------------------|
| Geometric | BCRS | Solar System barycentre | ICRS | None (raw ephemeris) |
| Astrometric | GCRS | Earth centre | ICRS | Light-time, origin shift |
| Mean of date | — | Earth centre | Mean equator & equinox of date | IAU 2006 precession (Fukushima-Williams, incl. frame bias) |
| Apparent | — | Earth centre | True equator & equinox of date | Aberration, precession, IAU 2000B nutation |
| Topocentric | — | Observer | True equator & equinox of date | GAST earth rotation, IERS polar motion, observer position (WGS-84/ITRS) |

### Models and references

- **Precession**: IAU 2006 P03, Fukushima-Williams parameterization including
  ICRS frame bias (IERS Conventions 2010, Section 5.6.4; ERFA `eraPfw06` /
  `eraFw2m`)
- **Nutation**: IAU 2000B, 77-term truncation of the IAU 2000A model (IERS
  Conventions 2010, Section 5.5.2)
- **Aberration**: Relativistic stellar aberration (Explanatory Supplement to the
  Astronomical Almanac, Ch. 7.2.3)
- **Earth rotation**: Greenwich Apparent Sidereal Time (GAST) computed as GMST +
  equation of equinoxes (IERS Conventions 2010, Section 5.5.7)
- **Polar motion**: IERS Earth Orientation Parameters via the `iers` gem
- **Observer coordinates**: WGS-84 geodetic to geocentric (ITRS/ECEF) conversion

## See also

- [Coordinates](coordinates.md) - for understanding coordinate systems
- [Observer](observer.md) - for location setup
- [Solar System Bodies](solar_system_bodies.md) - for object positions
- [Ephemerides](ephem.md) - for data sources

[Observer page]: observer.md
