# Solar System Bodies

Currently, Astronoby only supports the following major bodies of the Solar
System:

- the Sun (`Astronoby::Sun`)
- planets from Mercury to Neptune, including the Earth (`Astronoby::Earth`, ...)
- the Moon (`Astronoby::Moon`)

A sky (`Astronoby::Sky`) loaded from an ephemeris gives each of them at an
instant (`Astronoby::Instant`), as an instance which provides positions in
different reference frames.

You can learn more about the [sky], [ephemerides] and [reference frames].

```rb
sky = Astronoby::Sky.load("tmp/inpop19a.bsp")
time = Time.utc(2021, 7, 8)
instant = Astronoby::Instant.from_time(time)

venus = sky.venus.at(instant)
apparent_position = venus.apparent.position

apparent_position.x.km.round
# => -148794601
```

Each of these bodies also provides its own equatorial radius
(`Astronoby::Distance`).

```rb
Astronoby::Venus::EQUATORIAL_RADIUS.meters
# => 6051800
```

## Attributes of planets

For all Solar System bodies, except the Sun and the Earth, the following
attributes are available. Note that dynamic values are accessible through
instance methods, while absolute values are accessible through class methods.

### `#angular_diameter`

Size of the body in the sky. Returns a `Astronoby::Angle` object.

```rb
venus.angular_diameter.str(:dms)
# => "+0° 0′ 11.4587″"
```

### `#constellation`

Constellation where the body appears in the sky as seen from Earth. Returns
a `Astronoby::Constellation` object.

```rb
venus.constellation.name
# => "Cancer"

venus.constellation.abbreviation
# => "Cnc"
```

### `#elongation`

Apparent angular distance between the body and the Sun, as seen from Earth
("Sun-Earth-object" angle). Returns a `Astronoby::Angle` object.

```rb
venus.elongation.degrees.round
# => 27
```

### `#eastern?` and `#western?`

Whether the body lies east of the Sun (visible in the evening) or west of it
(visible in the morning). Both return a `Boolean`.

```rb
venus.eastern? # => true
venus.western? # => false
```

### `#phase_angle`

"Sun-object-Earth" angle. Returns a `Astronoby::Angle` object.

```rb
venus.phase_angle.degrees.round
# => 40
```

### `#illuminated_fraction`

Fraction of the object's disk illuminated as seen from Earth. Returns a `Float`
between `0` and `1`.

```rb
venus.illuminated_fraction.round(2)
# => 0.88
```

### `#apparent_magnitude`

Apparent brightness of the body. Returns a `Float`.

```rb
venus.apparent_magnitude.round(2)
# => -3.89
```

### `::absolute_magnitude`

Absolute brightness of the body. Returns a `Float`.

```rb
Astronoby::Venus.absolute_magnitude
# => -4.384
```

[sky]: sky.md
[ephemerides]: ephem.md
[reference frames]: reference_frames.md

## See also

- [Sky](sky.md) - for loading an ephemeris and getting bodies from it
- [Ephemerides](ephem.md) - for understanding data sources
- [Reference Frames](reference_frames.md) - for coordinate systems
- [Observer](observer.md) - for setting up observation locations
- [Angles](angles.md) - for working with angular measurements
