# Refraction

The atmosphere bends the light of a body on its way to the observer, so the body appears higher in the sky than its true, geometric altitude. The difference is about half a degree at the horizon, five arcminutes at 10° of altitude and one arcminute at 45°, and it vanishes at the zenith.

Astronoby gives true altitudes by default. Refraction is applied on request, with the temperature and the pressure of the observer.

## Requesting refraction

The places that return or search altitudes take a `refraction:` option, `false` by default:

```rb
sky = Astronoby::Sky.load("tmp/inpop19a.bsp")
instant = Astronoby::Instant.from_time(Time.utc(2025, 10, 1, 20))
saturn = sky.saturn.at(instant)

observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.8566),
  longitude: Astronoby::Angle.from_degrees(2.3522)
)

horizontal = saturn.observed_by(observer).horizontal(refraction: true)

horizontal.refracted?
# => true
```

`HorizontalTransformation#apply` takes the same option, as described on the [Deep-sky Bodies page]. A local sky searches for apparent altitudes given as `Astronoby::Altitude.apparent(degrees:)`, as described on the [Altitude crossings page].

## Refracting horizontal coordinates

`Astronoby::Coordinates::Horizontal` knows whether its altitude is true or apparent, with `#refracted?`. `#refract` returns the same coordinates seen through the atmosphere, with the same azimuth and observer:

```rb
true_horizontal = saturn.observed_by(observer).horizontal
true_horizontal.refracted?
# => false

apparent_horizontal = true_horizontal.refract
apparent_horizontal.refracted?
# => true
```

Refracting coordinates that are already refracted raises an `Astronoby::IncompatibleArgumentsError`, as the refraction would be counted twice.

## Atmospheric conditions

Refraction grows with the density of the air: it is larger when the air is cold and the pressure high. Both are read from the observer:

- `temperature` (`Astronoby::Temperature`): 10 °C by default
- `pressure` (`Astronoby::Pressure`): by default, the standard atmosphere of 1013.25 hPa brought to the observer's elevation with the barometric formula

```rb
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(19.8207),
  longitude: Astronoby::Angle.from_degrees(-155.4681),
  elevation: Astronoby::Distance.from_meters(4205),
  temperature: Astronoby::Temperature.from_celsius(-2),
  pressure: Astronoby::Pressure.from_millibars(615)
)
```

`Astronoby::Temperature` is built with `.from_celsius` or `.from_kelvins`, and `Astronoby::Pressure` with `.from_millibars`, `.from_hectopascals` or `.from_pascals`. With a pressure of zero there is no atmosphere and no refraction.

## Refraction angle

`Astronoby::Refraction.angle` returns the refraction itself, to add to a true altitude:

```rb
Astronoby::Refraction.angle(
  altitude: Astronoby::Angle.from_degrees(10),
  observer: observer
)
```

## Model

The refraction is computed with Bennett's formula, the one given by the Explanatory Supplement to the Astronomical Almanac and by Meeus in Astronomical Algorithms (chapter 16), and used by the USNO's NOVAS. It is scaled by the temperature and the pressure.

Bennett's formula takes the apparent altitude, while Astronoby computes the true one, so it is inverted. The inversion starts from Sæmundsson's formula, Meeus's direct inverse of Bennett's, and two Newton steps then land on the exact inverse to within a microarcsecond.

The formulas are fitted down to the horizon and are meaningless far below it, so below a true altitude of -1° the refraction is kept at its value there. The apparent altitude then always grows with the true altitude, which the altitude crossing search relies on.

From a high place the horizon is lower than the astronomical horizon, by about 0.5° at 300 m, 1° at 1100 m and 2° at 4000 m, so from above about 1100 m bodies can be seen below -1°. Their refraction is then kept at its value at -1°, and their apparent altitude can be too low by several arcminutes.

## Accuracy

At 10 °C and 1013.25 hPa, compared with Skyfield, which inverts Bennett's formula the same way:

| True altitude | Astronoby | Skyfield |
|---|---|---|
| 0° | 28′ 59.98″ | 28′ 59.75″ |
| 1° | 21′ 48.78″ | 21′ 48.60″ |
| 5° | 9′ 39.63″ | 9′ 39.55″ |
| 10° | 5′ 21.66″ | 5′ 21.61″ |
| 45° | 59.82″ | 59.81″ |

The two agree to within 0.3″ from the horizon to the zenith, from -30 °C to 40 °C and from 600 hPa to 1050 hPa.

IMCCE's Miriade service uses another model. Brought to the same temperature and pressure, its refraction is 3 to 5% larger below 10° of altitude.

Near the horizon, the real refraction also depends on the temperature profile of the air along the line of sight, which no formula from ground conditions can know. It commonly differs from the computed value by several arcminutes there.

## Rising, setting and twilight

Rise and set times do not use this model. They follow the usual convention of a body's centre being 34′ below the horizon, or 50′ for the Sun, whatever the weather, as described on the [Rise, transit and setting times page]. The model puts the apparent horizon at a true altitude of -34.6′ at the standard conditions, in line with that convention.

Twilight is defined on the Sun's true altitude, so it is computed without refraction.

[Deep-sky Bodies page]: deep_sky_bodies.md
[Altitude crossings page]: altitude_crossings.md
[Rise, transit and setting times page]: rise_transit_set_times.md
