# Reference Frames

A given body at a given time can be perceived at different positions, depending
on the reference frame and the corrections applied.

Astronoby provides five reference frames for celestial bodies, forming a
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

A separate **TEME** (True Equator, Mean Equinox) frame is also available for
satellite tracking. See [TEME](#teme) below.

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

The combined N \* PB matrix rotates the aberration-corrected GCRS position into
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

## TEME

The **TEME (True Equator, Mean Equinox)** frame is the output frame of the
SGP4/SDP4 satellite orbit propagators. Unlike the five frames above, TEME is
not part of the celestial body chain — it is constructed directly from SGP4
output and provides its own conversion methods.

TEME shares the true equator with the apparent frame but uses the mean equinox
(tracked by GMST) instead of the true equinox (tracked by GAST). The
difference between the two is the equation of the equinoxes.

### Conversions

`Astronoby::Teme` provides three conversion methods:

- `#to_ecef` - ECEF position and velocity, using R₃(GMST) and the ω×r
  velocity correction. The returned `EcefCoordinates` object also provides
  a `#geodetic` method to convert to WGS-84 geodetic coordinates
  (`Astronoby::Coordinates::Geodetic`)
- `#to_gcrs` - GCRS position and velocity (returns an `Astronoby::Astrometric`
  frame), using the transposed precession and nutation matrices
- `#observed_by(observer)` - topocentric position as seen from a specific
  observer (returns an `Astronoby::Topocentric` frame)

```rb
instant = Astronoby::Instant.from_time(Time.utc(2025, 6, 15, 12))

# Construct from SGP4 output
teme = Astronoby::Teme.new(
  position: Astronoby::Distance.vector_from_meters(
    [4_154_639.35, 768_141.62, -5_327_440.29]
  ),
  velocity: Astronoby::Velocity.vector_from_mps(
    [-1152.15, 7561.14, 192.76]
  ),
  instant: instant
)

# Convert to ECEF
ecef = teme.to_ecef
ecef.position[0].km
# => 1196.49...

# Convert ECEF to geodetic (WGS-84)
geodetic = ecef.geodetic
geodetic.latitude.str(:dms)
# => "+10° 29′ 51.7526″"

# Convert to GCRS
gcrs = teme.to_gcrs
gcrs.equatorial.right_ascension.str(:hms, precision: 0)
# => "0h 40m 42s"

# Observe from a location
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.8566),
  longitude: Astronoby::Angle.from_degrees(2.3522)
)
topocentric = teme.observed_by(observer)
topocentric.horizontal.azimuth.str(:dms, precision: 0)
# => "+223° 53′ 41″"
```

## Earth rotation

`Astronoby::EarthRotation` provides standalone Earth rotation matrices:

- `EarthRotation.matrix_for(instant)` — R₃(GAST), the apparent rotation
  matrix (used for observer placement in the true-equinox frame)
- `EarthRotation.mean_matrix_for(instant)` — R₃(GMST), the mean rotation
  matrix (used for TEME ↔ ECEF conversions)

Both return 3×3 orthogonal rotation matrices that transform ECEF coordinates
into the corresponding celestial frame.

## Standard reference systems

The table below maps Astronoby's reference frames to standard IAU/IERS
reference systems and lists the corrections applied at each step.

| Astronoby frame | Standard system | Origin                  | Axes                                | Corrections applied                                                     |
| --------------- | --------------- | ----------------------- | ----------------------------------- | ----------------------------------------------------------------------- |
| Geometric       | BCRS            | Solar System barycentre | ICRS                                | None (raw ephemeris)                                                    |
| Astrometric     | GCRS            | Earth centre            | ICRS                                | Light-time, origin shift                                                |
| Mean of date    | —               | Earth centre            | Mean equator & equinox of date      | IAU 2006 precession (Fukushima-Williams, incl. frame bias)              |
| Apparent        | —               | Earth centre            | True equator & equinox of date      | Aberration, precession, IAU 2000B nutation                              |
| Topocentric     | —               | Observer                | True equator & equinox of date      | GAST earth rotation, IERS polar motion, observer position (WGS-84/ITRS) |
| TEME            | —               | Earth centre            | True equator & mean equinox of date | SGP4/SDP4 output frame; converts to ECEF, GCRS, or topocentric          |

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
