# Lunar Eclipses

Astronoby computes lunar eclipses: the passages of the Moon through Earth's shadow. A lunar eclipse is a geocentric event, the same for every observer who can see the Moon, so finding one takes no observer. What one place sees of it depends only on whether the Moon is above its horizon, which is covered in [Local circumstances](#local-circumstances) below. The geometry is built from the apparent geocentric positions of the Sun and Moon, which matches the standard reduction used by [NASA's Five Millennium Canon of Lunar Eclipses] and by IMCCE.

There are three kinds of lunar eclipses. A penumbral eclipse is when the Moon only enters Earth's penumbra, the outer, partial shadow. A partial eclipse is when part of the Moon enters the umbra, the inner, total shadow. A total eclipse is when the whole Moon enters the umbra.

## Finding eclipses

`Astronoby::Moon.eclipse_events` takes an ephemeris and a time range, and returns the lunar eclipses whose greatest instant falls in that range, sorted by time.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")

eclipses = Astronoby::Moon.eclipse_events(
  ephem: ephem,
  start_time: Time.utc(2025, 1, 1),
  end_time: Time.utc(2026, 1, 1)
)

eclipses.map { |eclipse| [eclipse.instant.to_time, eclipse.kind] }
# => [[2025-03-14 06:58:46 UTC, :total], [2025-09-07 18:11:49 UTC, :total]]
```

## An eclipse

Each eclipse is an `Astronoby::LunarEclipse`. Its `#instant` (also available as `#greatest_eclipse_instant`) is the moment of greatest eclipse, when the Moon's centre is least distant from the axis of Earth's shadow.

```rb
eclipse = eclipses.first

eclipse.kind                 # => :total
eclipse.total?               # => true
eclipse.instant.to_time      # => 2025-03-14 06:58:46 UTC
eclipse.greatest_eclipse_instant # => same as #instant
```

The umbral and penumbral magnitudes are the fractions of the Moon's diameter immersed in the umbra and the penumbra at greatest eclipse. The umbral magnitude is negative for a penumbral eclipse (the Moon misses the umbra), between 0 and 1 for a partial eclipse, and 1 or more for a total eclipse.

```rb
eclipse.umbral_magnitude     # => 1.179
eclipse.penumbral_magnitude  # => 2.26
```

`#gamma` is the least distance of the Moon's centre from the axis of Earth's shadow at greatest eclipse, in Earth radii, positive when the Moon passes north of the axis and negative when it passes south. It is the standard, dimensionless eclipse parameter used by IMCCE and NASA. The same quantity is also available as a `Astronoby::Distance` through `#shadow_axis_distance`, and the side of the axis it takes its sign from is on the geometry as `#north_of_axis?`.

```rb
eclipse.gamma                       # => 0.348
eclipse.shadow_axis_distance.km     # => 2222.37
```

## Phases

An eclipse exposes its phases as `Astronoby::LunarEclipsePhase` objects, each with a `#starting_instant`, an `#ending_instant`, and a `#duration` (an `Astronoby::Duration`). The penumbral phase is always present. The partial phase is present for partial and total eclipses, and the total phase (totality) only for total eclipses. A phase that does not occur is `nil`.

```rb
eclipse.penumbral.starting_instant.to_time # => 2025-03-14 03:57:28 UTC (P1)
eclipse.partial.starting_instant.to_time   # => 2025-03-14 05:09:36 UTC (U1)
eclipse.total.starting_instant.to_time     # => 2025-03-14 06:26:02 UTC (U2)
eclipse.total.ending_instant.to_time       # => 2025-03-14 07:31:29 UTC (U3)
eclipse.partial.ending_instant.to_time     # => 2025-03-14 08:47:55 UTC (U4)
eclipse.penumbral.ending_instant.to_time   # => 2025-03-14 10:00:08 UTC (P4)

eclipse.total.duration.seconds # => 3927.11 (seconds of totality)
```

For a penumbral eclipse, `#partial` and `#total` are `nil`. For a partial eclipse, `#total` is `nil`.

## Shadow geometry

`Astronoby::LunarEclipseGeometry` describes Earth's shadow and the Moon's place in it at one instant. The eclipse carries the geometry at greatest eclipse, and each phase carries the geometry at its two contacts, so all six contacts of a total eclipse are reachable as well as greatest eclipse. It gives the size of the two shadow cones, how far the Moon's centre is from the shadow axis, and where on the Moon's limb the shadow bites.

```rb
geometry = eclipse.geometry

geometry.umbra_angular_radius.degrees * 60     # => 39.23 (arcminutes)
geometry.penumbra_angular_radius.degrees * 60  # => 71.39
geometry.angular_axis_distance.degrees * 60    # => 19.03
geometry.position_angle.degrees                # => 29.07
```

The cone radii are measured in the plane perpendicular to the shadow axis at the Moon's distance, which is where they are published. They are available as an `Astronoby::Distance` through `#umbra_radius` and `#penumbra_radius`, and as an `Astronoby::Angle` through `#umbra_angular_radius` and `#penumbra_angular_radius`. `#moon_distance` is the geocentric distance of the Moon, the distance of that plane.

`#position_angle` is the position angle of the contact point on the Moon's limb, seen from the Moon's centre, from celestial north through east. This is the quantity IMCCE and NASA publish. At greatest eclipse, where there is no contact point, it is the direction from the shadow axis to the Moon, which is what they report there too.

`#umbral_magnitude` and `#penumbral_magnitude` are available at any of these instants, not only at greatest eclipse. Each one is 0 at the contacts that define it, so the penumbral magnitude at P1 and P4 and the umbral magnitude at U1 and U4. The umbral magnitude is 1 at U2 and U3, where the Moon is wholly inside the umbra. The penumbral magnitude is well past 1 by then, since the Moon is far deeper into the penumbra than into the umbra.

```rb
eclipse.penumbral.starting_geometry.penumbral_magnitude # => 0.0 (P1)
eclipse.partial.starting_geometry.umbral_magnitude      # => 0.0 (U1)
eclipse.total.starting_geometry.umbral_magnitude        # => 1.0 (U2)
```

```rb
eclipse.penumbral.starting_geometry.position_angle.degrees # => 131.8 (P1)
eclipse.total.starting_geometry.position_angle.degrees     # => 350.46 (U2)
```

Note that IMCCE labels the end of the penumbral phase `P2`, where this documentation uses `P4`.

```rb
penumbral_eclipse = Astronoby::Moon.eclipse_events(
  ephem: ephem,
  start_time: Time.utc(2024, 3, 1),
  end_time: Time.utc(2024, 4, 1)
).first

penumbral_eclipse.kind    # => :penumbral
penumbral_eclipse.partial # => nil
penumbral_eclipse.total   # => nil
```

## Local circumstances

The eclipse is the same everywhere, so there is no path of visibility to compute. All that changes from place to place is whether the Moon is above the horizon, and visibility is the intersection of the eclipse with the time the Moon spends up. Half the Earth sees an eclipse; the other half is in daylight, with the Moon below the horizon.

`LunarEclipse#visibility_from` takes an `Astronoby::Observer` and returns an `Astronoby::LunarEclipseVisibility`. No ephemeris is involved: the Moon's place at every contact is already carried by the geometry, so an eclipse can be observed from as many places as wanted, including after a round trip through a cache.

```rb
paris = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.8566),
  longitude: Astronoby::Angle.from_degrees(2.3522)
)

visibility = eclipse.visibility_from(paris)

visibility.visible?           # => true
visibility.entirely_visible?  # => false
visibility.circumstance       # => :ends_after_moonset
```

`#circumstance` sums up what the place gets of the eclipse:

- `:not_visible`, the Moon is below the horizon for the whole eclipse
- `:entirely_visible`, the Moon is up from the first to the last penumbral contact
- `:begins_before_moonrise`, the eclipse is already under way when the Moon rises
- `:ends_after_moonset`, the eclipse is still under way when the Moon sets
- `:partially_visible`, anything else, which at high latitudes can be the Moon rising and setting within the eclipse

`#coverage` takes a phase and answers how much of it happens with the Moon up, in the same three words `#circumstance` uses of the whole eclipse: `:entirely_visible`, `:partially_visible`, `:not_visible`, or `nil` when the eclipse has no such phase. In the example, in Paris, the Moon sets during the partial phase, before totality begins.

```rb
visibility.coverage(:penumbral) # => :partially_visible
visibility.coverage(:partial)   # => :partially_visible
visibility.coverage(:total)     # => :not_visible
```

`#horizon_crossings` are the instants of the eclipse at which the Moon rises or sets, and `#observable_windows` are the stretches of the eclipse spent with the Moon up. There is one window for an eclipse seen whole or in part, none for one not seen at all, and more than one only where the Moon crosses the horizon repeatedly.

```rb
visibility.horizon_crossings.map { |instant| instant.to_time }
# => [2025-03-14 06:11:41 UTC]

visibility.observable_windows.map { |window| [window.first.to_time, window.last.to_time] }
# => [[2025-03-14 03:57:28 UTC, 2025-03-14 06:11:41 UTC]]
```

From Mexico City the same eclipse runs from end to end with the Moon high in the sky.

```rb
mexico_city = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(19.4326),
  longitude: Astronoby::Angle.from_degrees(-99.1332)
)

visibility = eclipse.visibility_from(mexico_city)

visibility.circumstance     # => :entirely_visible
visibility.coverage(:total) # => :entirely_visible
visibility.horizon_crossings # => []
```

`#above_horizon_at?` answers whether the Moon is up at an instant of the eclipse, and raises outside it.

```rb
visibility.above_horizon_at?(eclipse.total.starting_instant) # => true
```

Visibility answers whether the Moon is up, not how high it is. The Moon's place at each contact is interpolated from what the eclipse carries, which is what lets an eclipse be observed from anywhere without an ephemeris, and that is accurate well past what the horizon convention can resolve. For the altitude itself, ask the Moon, which computes it from the ephemeris with no interpolation at all.

```rb
Astronoby::Moon
  .new(ephem: ephem, instant: eclipse.total.starting_instant)
  .observed_by(mexico_city)
  .horizontal
  .altitude
  .degrees # => 72.45
```

The Moon counts as up once its upper limb clears the refracted horizon, which is the convention Astronoby uses for moonrise and moonset, through `Astronoby::Horizon`.

## Precision

Two conventions shape the result. Earth's shadow is enlarged by its atmosphere, so Astronoby adds a 64 km shell to Earth's radius before building the shadow cones. And eclipse contacts are reduced with the IAU eclipse constant k, which puts the Moon's radius at 1738.09 km, slightly above its physical equatorial radius. Both are calibrated against IMCCE.

Validated against IMCCE, the eclipse kind and the magnitudes match, and the contacts agree to within a couple of seconds. The shadow radii and the distance from the shadow axis match to well under an arcsecond, and position angles to 0.03 degrees.

The local circumstances are reduced without the ephemeris, from the Moon's place at the contacts and the sidereal rate. The altitudes agree with the topocentric places computed from the ephemeris to under an arcminute, and the horizon crossings put the Moon on the horizon to a few arcseconds, which is well inside the uncertainty of the fixed refraction the convention assumes.

## See also

- [Moon Phases](moon_phases.md) - for lunar phases
- [Lunar Observation](lunar_observation.md) - for libration, axis and limb angles
- [Planetary Phenomena](planetary_phenomena.md) - for conjunctions, oppositions and elongations
- [Solar System Bodies](solar_system_bodies.md) - for moon object details
- [Ephemerides](ephem.md) - for data sources

[NASA's Five Millennium Canon of Lunar Eclipses]: https://eclipse.gsfc.nasa.gov/SEpubs/5MCLE.html
[IMCCE]: https://www.imcce.fr/
