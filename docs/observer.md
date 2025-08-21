# Observer

`Astonoby::Observer` is the representation of an observer on Earth. Most of the
events computed by Astronoby are location and date based.

## Initialization

The two required key arguments to instantiate an observer are:
* `latitude` (`Astronoby::Angle`): the angle from the equator to the observer,
* from 90° to -90°, with positive angles for the Northern Hemisphere.
* `longitude` (`Astronoby::Angle`): the angle from the Greenwich meridian to the
* observer, from 180° to -180°, with positive angles eastward the Greenwich
* meridian.

Latitude and longitude are defined according to the
[World Geodetic System](https://en.wikipedia.org/wiki/World_Geodetic_System). In
other terms, they are the same as the ones used for the
[GPS](https://en.wikipedia.org/wiki/GPS).

It is also possible to give the following optional key arguments:
* `elevation` (`Astronoby::Distance`): the distance above or below the average sea level
* `utc_offset`: local time difference with UTC. Check the [timezone specifiers](https://ruby-doc.org/3.4.1/Time.html#class-Time-label-Timezone+Specifiers) for the format.

```rb
# Location: Alhambra, Spain

observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(37.176),
  longitude: Astronoby::Angle.from_degrees(-3.588),
  elevation: Astronoby::Distance.from_meters(792)
)
```

You can learn more about angles on the
[Angle page](https://github.com/rhannequin/astronoby/wiki/Angle).

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
