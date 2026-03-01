# Observer

`Astronoby::Observer` is the representation of an observer on Earth. Most of the
events computed by Astronoby are location and date based.

## Initialization

The two required key arguments to instantiate an observer are:

- `latitude` (`Astronoby::Angle`): the angle from the equator to the observer,
  from 90° to -90°, with positive angles for the Northern Hemisphere.
- `longitude` (`Astronoby::Angle`): the angle from the Greenwich meridian to the
  observer, from 180° to -180°, with positive angles eastward of the Greenwich
  meridian.

Latitude and longitude are defined according to the [World Geodetic System].
In other words, they are the same as those used for the [GPS].

It is also possible to give the following optional key arguments:

- `elevation` (`Astronoby::Distance`): the distance above or below the average
  sea level
- `utc_offset`: local time difference with UTC. Check the [timezone specifiers]
  for the format.

```rb
# Location: Alhambra, Spain

observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(37.176),
  longitude: Astronoby::Angle.from_degrees(-3.588),
  elevation: Astronoby::Distance.from_meters(792)
)
```

You can learn more about angles on the [Angles page].

## Value equality

`Astronoby::Observer` is a value object, which means it implements value
equality.

```rb
observer1 = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(90),
  longitude: Astronoby::Angle.from_degrees(180)
)

observer2 = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_hours(6),
  longitude: Astronoby::Angle.from_hours(12)
)

observer1 == observer2
# => true
```

[World Geodetic System]: https://en.wikipedia.org/wiki/World_Geodetic_System
[GPS]: https://en.wikipedia.org/wiki/GPS
[timezone specifiers]: https://ruby-doc.org/3.4.1/Time.html#class-Time-label-Timezone+Specifiers
[Angles page]: angles.md

## See also

- [Angles](angles.md) - for working with latitude and longitude
- [Coordinates](coordinates.md) - for understanding position systems
- [Reference Frames](reference_frames.md) - for topocentric calculations
- [Solar System Bodies](solar_system_bodies.md) - for observing objects
