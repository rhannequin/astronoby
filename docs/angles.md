# Angles

`Astronoby::Angle` is one of the most important object in the library. An object
on the celestial sphere is described with angles, an observer's location on
Earth is described with angles, the distance between two points in the sky is
described with an angle.

## Create an angle

You can create an instance of `Astronoby::Angle` with a value in different
units: radians, degrees or hours.

```rb
Astronoby::Angle.from_radians(Math::PI)
Astronoby::Angle.from_degrees(180)
Astronoby::Angle.from_hours(12)
```

You can also use the hour-minute-second (HMS) or degree-minute-second (DMS)
formats.

```rb
Astronoby::Angle.from_hms(22, 45, 23)
Astronoby::Angle.from_dms(340, 45, 23)
```

Alternatively, you can create an angle of 0 (regardless of the unit).

```rb
Astronoby::Angle.zero
```

Finally, you can create an angle from the ratio of a trigonometric function.

```rb
Astronoby::Angle.acos(0)
Astronoby::Angle.asin(-1)
Astronoby::Angle.atan(1 / Math.sqrt(3))
```

## Convert between units

Once an angle object is instantiated, its value lives inside it. You need to
specify a unit to extract it.

```rb
angle = Astronoby::Angle.from_degrees(180)

angle.degrees # => 180.0
angle.radians # => 3.141592653589793
angle.hours   # => 12.0
```

## Format an angle

You can format an angle in HMS or DMS formatted strings.

```rb
angle = Astronoby::Angle.from_degrees(155.76479)

angle.str(:dms) # => "+155° 45′ 53.2439″"
angle.str(:hms) # => "10h 23m 3.5496s"
```

Alternatively you can extract these numbers without having to format them into a
string.

```rb
angle = Astronoby::Angle.from_degrees(155.76479)

dms = angle.to_dms
dms.sign    # => "+"
dms.degrees # => 155
dms.minutes # => 45
dms.seconds # => 53.2439

hms = angle.to_hms
hms.hours   # => 10
hms.minutes # => 23
hms.seconds # => 3.5496
```

## Manipulate angles

You can compare an angle with another angle.

```rb
Astronoby::Angle.from_hours(12) == Astronoby::Angle.from_degrees(180)
# => true

angle1 = Astronoby::Angle.from_degrees(90)
angle2 = Astronoby::Angle.from_hours(12)

angle1 < angle2 # => true
```

## Math with angles

Trigonometric functions can be applied to angles to get the value as a `Float`.
Please be aware some results won't be strictly exact because of the limited
precision of floating-point numbers and the limited amount of digits
of `Math::PI`.

```rb
angle = Astronoby::Angle.from_degrees(180)

angle.cos # => -1.0
angle.sin # => 1.2246467991473532e-16, strictly supposed to be 0
angle.tan # => -1.2246467991473532e-16, strictly supposed to be 0
```

You can add up or subtract angles into a new one. Multiplication and division
are not supported as they mathematically should return something else than an
angle.

```rb
angle1 = Astronoby::Angle.from_hours(12)
angle2 = Astronoby::Angle.from_degrees(90)

angle3 = angle1 + angle2
angle3.degrees   # => 270.0

angle4 = angle1 - angle2
angle4.degrees   # => 90.0

angle5 = -angle1
angle5.degrees   # => -180.0

angle1.positive? # => true
angle1.negative? # => false
```

## See also
- [Coordinates](coordinates.md) - for using angles in coordinate systems
- [Observer](observer.md) - for latitude and longitude
- [Reference Frames](reference_frames.md) - for position calculations
- [Celestial Bodies](celestial_bodies.md) - for object positions
