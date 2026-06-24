# Lunar Observation

Beyond phases and apsides, Astronoby exposes the quantities lunar observers rely on to describe the Moon's appearance and orientation in the sky: its libration, the position angle of its rotation axis, the position angle of its bright limb, and the parallactic angle. By default they follow Jean Meeus, *Astronomical Algorithms*, 2nd edition, and are derived from the Moon's and the Sun's apparent positions, which Astronoby already computes from the ephemeris. The libration and the position angle of the axis can additionally use the integrated lunar orientation from a JPL DE kernel to reach arcsecond accuracy, as described below.

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

By default this is the analytic optical plus physical libration from Meeus's series. Compared with the lunar orientation integrated in the JPL DE solution (as reported by JPL Horizons), the libration in longitude and the position angle of the axis agree to within a few arcseconds, while the libration in latitude agrees to about 0.02 degrees. That residual is the well known difference between the mean lunar equator used by the classical Meeus method and the DE mean-Earth frame. It is eliminated by loading an orientation kernel.

## Arcsecond accuracy with an orientation kernel

For the libration and the position angle of the axis, you can reach the accuracy of JPL Horizons, Skyfield and IMCCE by also loading a binary PCK lunar orientation kernel, such as `moon_pa_de440_200625.bpc`, which carries the integrated DE440 orientation of the Moon. Load it once with `Astronoby::Orientation` and pass it to the Moon alongside the ephemeris.

```rb
ephem = Astronoby::Ephem.load("de440.bsp")
orientation = Astronoby::Orientation.load("moon_pa_de440_200625.bpc")

moon = Astronoby::Moon.new(instant: instant, ephem: ephem, orientation: orientation)

moon.libration.latitude.str(:dms)     # => "+0° 27′ 27.7258″"
moon.position_angle_of_axis.str(:dms) # => "-21° 48′ 32.9625″"
```

The libration is then computed as the selenographic longitude and latitude of the sub-Earth point in the Moon's mean-Earth body-fixed frame, and matches JPL Horizons to better than an arcsecond. Without an orientation kernel the Moon keeps using the analytic method, so this is an opt-in refinement, not a requirement. The `bright_limb_position_angle` and `parallactic_angle` are unaffected and do not need a kernel.

If you do not already have the kernel, Astronoby can download it for you.

```rb
Astronoby::Orientation.download(
  name: "moon_pa_de440_200625.bpc",
  target: "moon_pa_de440_200625.bpc"
)
```

## Position angle of the axis

`Astronoby::Moon#position_angle_of_axis` returns the position angle of the Moon's axis of rotation, the angle of the projection of the lunar north pole, measured eastward from the north point of the disk. It is returned as an `Astronoby::Angle`.

```rb
moon.position_angle_of_axis.str(:dms) # => "-21° 48′ 46.657″"
```

## Position angle of the bright limb

`Astronoby::Moon#bright_limb_position_angle` returns the position angle of the midpoint of the illuminated limb, measured eastward from the north point of the disk, between 0 and 360 degrees. It is a geocentric quantity computed from the apparent equatorial coordinates of the Moon and the Sun, and it points towards the Sun, since the bright limb is the limb facing the Sun.

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
