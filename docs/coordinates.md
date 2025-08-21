# Coordinates

Astronoby provides three different types of coordinates:

* Equatorial
* Ecliptic
* Horizontal

Equatorial and ecliptic coordinates are available for each [reference frame],
while horizontal coordinates are only available for a topocentric position.

## Equatorial

In Astronoby, equatorial coordinates are geocentric spherical coordinates. As
per [Wikipedia]'s definition:

> defined by an origin at the centre of Earth, fundamental plane consisting of
> the projection of Earth's equator onto the celestial sphere (forming the
> celestial equator, a primary direction towards the March equinox, and a
> right-handed convention.

They have two main angular attributes:

### Right ascension

Angle measured East from the Vernal Equinox, the point where the Sun crosses the
celestial equator in March as it passes from the southern to the northern half
of the sky. By convention, right ascension is usually displayed in hours.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(1962, 7, 24)
instant = Astronoby::Instant.from_time(time)

saturn = Astronoby::Saturn.new(ephem: ephem, instant: instant)
equatorial = saturn.apparent.equatorial

equatorial.right_ascension.str(:hms)
# => "20h 45m 2.6702s"
```

You can learn more about angles on the [Angle page].

### Declination

Angle measured north and south of the celestial equator in degrees, with north
being positive. The North Celestial Pole is at +90° and the South Celestial Pole
is at -90°.

```rb
equatorial.declination.str(:dms)
# => "-18° 46′ 16.1226″"
```

### Hour angle

Sometimes convenient for astronomers, a third attribute can be derived from
equatorial coordinates: the hour angle. It is angle between the meridian plane
and the hour circle, meaning it depends on the observer's longitude and time. By
convention, the hour angle is usually displayed in hours.

```rb
longitude = Astronoby::Angle.from_degrees(2)

equatorial.compute_hour_angle(longitude: longitude, time: time).str(:hms)
# => "23h 27m 54.9585s"
```

## Ecliptic

In Astronoby, ecliptic coordinates are geocentric spherical coordinates. Their
origin is the centre of Earth, their primary direction is towards the March
equinox, and they have a right-hand convention. Ecliptic coordinates are
particularly handy for representing positions of Solar System objects.

As per Wikipedia's definition:

> The celestial equator and the ecliptic are slowly moving due to perturbing
> forces on the Earth, therefore the orientation of the primary direction, their
> intersection at the March equinox, is not quite fixed. A slow motion of
> Earth's axis, precession, causes a slow, continuous turning of the coordinate
> system westward about the poles of the ecliptic. Superimposed on this is a
> smaller motion of the ecliptic, and a small oscillation of the Earth's axis,
> nutation.

This primary direction depends on the [reference frame] used.

They have two main angular attributes:

### Latitude

The ecliptic longitude measures the angular distance of an object along the
ecliptic from the primary direction.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(1962, 7, 24)
instant = Astronoby::Instant.from_time(time)

saturn = Astronoby::Saturn.new(ephem: ephem, instant: instant)
ecliptic = saturn.apparent.ecliptic

ecliptic.latitude.str(:dms)
# => "-0° 41′ 27.5439″"
```

### Longitude

The ecliptic latitude measures the angular distance of an object from the
ecliptic towards the north (positive) or south (negative) ecliptic pole.

```rb
ecliptic.longitude.str(:dms)
# => "+308° 38′ 33.1744″"
```

## Horizontal

Horizontal coordinates are the most observer-centered and human intuitive
coordinates, they measure where an object is in the sky as seen from an observer
on Earth as "up and down" and "left and right".

In Astronoby, they can only be computed from a [topocentric position].

They have two main angular attributes:

### Altitude

The angle between the object and the observer's local horizon.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(1962, 7, 24)
instant = Astronoby::Instant.from_time(time)

observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(42),
  longitude: Astronoby::Angle.from_degrees(2)
)

saturn = Astronoby::Saturn.new(ephem: ephem, instant: instant)
horizontal = saturn.observed_by(observer).horizontal

horizontal.altitude.str(:dms)
# => "+28° 46′ 39.5994″"
```

### Azimuth

The angle of the object around the horizon from the north and increasing
eastward.

```rb
horizontal.azimuth.str(:dms)
# => "+171° 19′ 50.5798″"
```

[reference frame]: reference_frames.md
[Wikipedia]: https://en.wikipedia.org/wiki/Equatorial_coordinate_system
[Angle page]: angles.md
[topocentric position]: reference_frames.md#topocentric
