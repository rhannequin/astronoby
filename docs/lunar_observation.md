# Lunar Observation

Beyond phases and apsides, Astronoby exposes the quantities lunar observers rely on to describe the Moon's appearance and orientation in the sky: its libration, the position angle of its rotation axis, the position angle of its bright limb, and the parallactic angle. They all follow Jean Meeus, *Astronomical Algorithms*, 2nd edition, and are derived from the Moon's and the Sun's apparent positions, which Astronoby already computes from the ephemeris.

All of these are available directly on a `Astronoby::Moon` instance.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
instant = Astronoby::Instant.from_time(Time.utc(2025, 3, 1))
moon = Astronoby::Moon.new(instant: instant, ephem: ephem)
```

## Libration

Libration is the apparent oscillation that lets an observer on Earth see slightly more than half of the lunar surface over time. `Astronoby::Moon#libration` returns a `Astronoby::Libration` value object holding the total (optical plus physical) libration in longitude and latitude, both as `Astronoby::Angle` objects. A positive longitude exposes more of the Moon's eastern limb (Mare Crisium side); a positive latitude exposes more of its northern limb.

```rb
libration = moon.libration

libration.longitude.str(:dms) # => "-2° 5′ 4.4219″"
libration.latitude.str(:dms)  # => "+0° 28′ 45.9616″"
```

The optical libration is derived from the apparent geocentric coordinates supplied by the ephemeris, so it is as accurate as the ephemeris itself. The physical libration is computed from Meeus's truncated series. Compared with the lunar orientation integrated in the JPL DE solution (as reported by JPL Horizons), the libration in longitude and the position angle of the axis agree to within a few arcseconds, while the libration in latitude agrees to about 0.02 degrees. That residual is the well known difference between the mean lunar equator used by the classical Meeus method and the DE principal axis frame, and it cannot be reduced without the separate lunar orientation kernel, which the position ephemerides do not contain.

## Position angle of the axis

`Astronoby::Moon#position_angle_of_axis` returns the position angle of the Moon's axis of rotation, the angle of the projection of the lunar north pole, measured eastward from the north point of the disk. It is returned as an `Astronoby::Angle`.

```rb
moon.position_angle_of_axis.str(:dms) # => "-21° 48′ 46.657″"
```

## Position angle of the bright limb

`Astronoby::Moon#bright_limb_position_angle` returns the position angle of the midpoint of the illuminated limb, measured eastward from the north point of the disk, between 0 and 360 degrees. It is a geocentric quantity computed from the apparent equatorial coordinates of the Moon and the Sun, and it points away from the Sun.

```rb
moon.bright_limb_position_angle.str(:dms) # => "+248° 1′ 57.9467″"
```

## Parallactic angle

The parallactic angle is the angle at the Moon between the direction of the north celestial pole and the direction of the observer's zenith. Unlike the previous quantities it depends on the observer, so it is computed from the topocentric place, where lunar parallax is significant. `Astronoby::Moon#parallactic_angle` takes an observer and returns an `Astronoby::Angle`.

```rb
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.8566),
  longitude: Astronoby::Angle.from_degrees(2.3522)
)

moon.parallactic_angle(observer: observer).str(:dms) # => "+11° 42′ 47.1246″"
```

## See also

- [Solar System Bodies](solar_system_bodies.md) - for the Moon's other properties
- [Moon Phases](moon_phases.md) - for lunar phase events
- [Observer](observer.md) - for setting up observation locations
- [Reference Frames](reference_frames.md) - for coordinate systems
- [Angles](angles.md) - for working with angular measurements
