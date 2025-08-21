# Celestial Bodies

Currently, Astronoby only supports the following major bodies of the Solar
System:
* the Sun (`Astronoby::Sun`)
* planets from Mercury to Neptune, including the Earth (`Astronoby::Earth`, ...)
* the Moon (`Astronoby::Moon`)

Given an ephemeris (`Astronoby::Ephem`) and an instant object
(`Astronoby::Instant`), these classes enable to get instances which provides
positions in different reference frames.

You can learn more about [ephemerides] and [reference frames].

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")
time = Time.utc(2021, 7, 8)
instant = Astronoby::Instant.from_time(time)

venus = Astronoby::Venus.new(ephem: ephem, instant: instant)
apparent_position = venus.apparent.position

apparent_position.x.km.round
# => -148794622
```

Each of these bodies also provide their own equatorial radius
(`Astronoby::Distance`).

```rb
Astronoby::Venus::EQUATORIAL_RADIUS.meters
# => 6051800
```

## Attributes of planets

For all Solar System bodies, except the Sun and the Earth, the following
attributes are available. Note that dynamic values accessible through instance
methods, while absolute values are accessible through class methods.

### `#constellation`

Constellation where the body appears in the sky as seen from Earth. Returns
a `Astronoby::Constellation` object.

```rb
venus.constellation.name
# => "Cancer"

venus.constellation.abbreviation
# => "Cnc"
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

[ephemerides]: ephem.md
[reference frames]: reference_frames.md
