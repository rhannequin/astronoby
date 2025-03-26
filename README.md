# Astronoby

[![Tests](https://github.com/rhannequin/astronoby/workflows/Ruby/badge.svg)](https://github.com/rhannequin/astronoby/actions?query=workflow%3ARuby)
[![Coverage Status](https://codecov.io/gh/rhannequin/astronoby/branch/main/graph/badge.svg)](https://codecov.io/gh/rhannequin/astronoby)

Ruby library to provide a useful API to compute astronomical calculations, based
on astrometry books.

The main reference is:
- _Astronomical Algorithms_ by Jean Meeus
- _Celestial Calculations_ by J. L. Lawrence
- _Practical Astronomy with your Calculator or Spreadsheet_ by Peter
  Duffet-Smith and Jonathan Zwart

## Content
- [Installation](#installation)
- [Usage](#usage)
  - [Deprecated documentation notice](#deprecated-documentation-notice)
  - [Angle manipulation](#angle-manipulation)
  - [Coordinates conversion](#coordinates-conversion)
  - [Sun](#sun)
    - [Sun's location in the sky](#suns-location-in-the-sky)
    - [Sunrise and sunset times and azimuths](#sunrise-and-sunset-times-and-azimuths)
    - [Twilight times](#twilight-times)
  - [Solstice and Equinox times](#solstice-and-equinox-times)
  - [Moon](#moon)
    - [Moon's location in the sky](#moons-location-in-the-sky)
    - [Moon's current attributes](#moons-current-attributes)
    - [Moon's phases of the month](#moons-phases-of-the-month)
    - [Moonrise and moonset times and azimuths](#moonrise-and-moonset-times-and-azimuths)
- [Precision](#precision)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add astronoby

If bundler is not being used to manage dependencies, install the gem by
executing:

    $ gem install astronoby

## Usage

### Deprecated documentation notice

The following documentation is meant for version 0.6.0 or below. Astronoby
is currently in complete refactoring and its new documentation will live in the
[Wiki](https://github.com/rhannequin/astronoby/wiki).

### Expected breaking changes notice

This library is still in heavy development. The public is not stable, please
be aware new minor versions will probably lead to breaking changes until a
major one is released.

### Angle manipulation

```rb
angle1 = Astronoby::Angle.from_degrees(90)
angle2 = Astronoby::Angle.from_radians(Math::PI / 2)
angle3 = Astronoby::Angle.from_hours(12)

angle1 == angle2
# => true

angle1 < angle3
# => true

angle = angle1 + angle2 + angle3
angle.cos
# => 1.0
```

### Distance manipulation

```rb
distance1 = Astronoby::Distance.from_astronomical_units(1)
distance2 = Astronoby::Distance.from_kilometers(149_597_870.7)
distance3 = Astronoby::Distance.from_meters(300)

distance1 == distance2
# => true

distance1 > distance3
# => true

distance =
  Astronoby::Distance.from_m(300) +
  Astronoby::Distance.from_km(3)

distance.km
# => 3.3
```

### Coordinates conversion

```rb
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(38),
  longitude: Astronoby::Angle.from_degrees(-78)
)

equatorial = Astronoby::Coordinates::Equatorial.new(
  right_ascension: Astronoby::Angle.from_hms(17, 43, 54),
  declination: Astronoby::Angle.from_dms(-22, 10, 0)
)

horizontal = equatorial.to_horizontal(
  time: Time.new(2016, 1, 21, 21, 30, 0, "-05:00"),
  observer: observer
)

horizontal.altitude.str(:dms)
# => "-73° 27′ 19.1557″"

horizontal.azimuth.str(:dms)
# => "+341° 33′ 21.587″"
```

### Sun

#### Sun's location in the sky

```rb
time = Time.utc(2023, 2, 17, 11, 0, 0)

observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.8566),
  longitude: Astronoby::Angle.from_degrees(2.3522)
)

sun = Astronoby::Sun.new(time: time)

horizontal_coordinates = sun.horizontal_coordinates(
  observer: observer
)

horizontal_coordinates.altitude.degrees
# => 27.500082409271247

horizontal_coordinates.altitude.str(:dms)
# => "+27° 30′ 0.2966″"
```

#### Sunrise and sunset times and azimuths

Only date part of the time is relevant for the calculation. The offset must
be provided to the observer.

```rb
utc_offset = "-05:00"
time = Time.new(2015, 2, 5, 0, 0, 0, utc_offset)
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(38),
  longitude: Astronoby::Angle.from_degrees(-78),
  utc_offset: utc_offset
)
sun = Astronoby::Sun.new(time: time)
observation_events = sun.observation_events(observer: observer)

observation_events.rising_time.getlocal(utc_offset)
# => 2015-02-05 07:12:59 -0500

observation_events.rising_azimuth.str(:dms)
# => "+109° 29′ 35.5069″"

observation_events.transit_time.getlocal(utc_offset)
# => 2015-02-05 12:25:59 -0500

observation_events.transit_altitude.str(:dms)
# => "+36° 8′ 14.9673″"

observation_events.setting_time.getlocal(utc_offset)
# => 2015-02-05 17:39:27 -0500

observation_events.setting_azimuth.str(:dms)
# => "+250° 40′ 41.7129″"
```

#### Twilight times

```rb
time = Time.new(2024, 1, 1)
sun = Astronoby::Sun.new(time: time)
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.8566),
  longitude: Astronoby::Angle.from_degrees(2.3522)
)
twilight_events = sun.twilight_events(observer: observer)

twilight_events.morning_astronomical_twilight_time
# => 2024-01-01 05:49:25 UTC

twilight_events.morning_nautical_twilight_time
# => 2024-01-01 06:27:42 UTC

twilight_events.morning_civil_twilight_time
# => 2024-01-01 07:07:50 UTC

twilight_events.evening_civil_twilight_time
# => 2024-01-01 16:40:01 UTC

twilight_events.evening_nautical_twilight_time
# => 2024-01-01 17:20:10 UTC

twilight_events.evening_astronomical_twilight_time
# => 2024-01-01 17:58:26 UTC
```

### Solstice and Equinox times

```rb
year = 2024

Astronoby::EquinoxSolstice.march_equinox(year)
# => 2024-03-20 03:05:08 UTC

Astronoby::EquinoxSolstice.june_solstice(year)
# => 2024-06-20 20:50:18 UTC
```

### Moon

#### Moon's location in the sky

```rb
time = Time.utc(2023, 2, 17, 11, 0, 0)

observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(48.8566),
  longitude: Astronoby::Angle.from_degrees(2.3522)
)

moon = Astronoby::Moon.new(time: time)

horizontal_coordinates = moon.horizontal_coordinates(
  observer: observer
)

horizontal_coordinates.altitude.degrees
# => 10.277834691708053

horizontal_coordinates.altitude.str(:dms)
# => "+10° 16′ 40.2048″"
```

#### Moon's current attributes

```rb
time = Time.utc(2024, 6, 1, 10, 0, 0)
moon = Astronoby::Moon.new(time: time)

moon.illuminated_fraction.round(2)
# => 0.31

moon.current_phase_fraction.round(2)
# => 0.82

moon.distance.km.round
# => 368409

moon.phase_angle.degrees.round
# => 112
```

#### Moon's phases of the month

```rb
june_phases = Astronoby::Moon.monthly_phase_events(
  year: 2024,
  month: 6
)

june_phases.each { puts "#{_1.phase}: #{_1.time}" }
# new_moon: 2024-06-06 12:37:41 UTC
# first_quarter: 2024-06-14 05:18:28 UTC
# full_moon: 2024-06-22 01:07:53 UTC
# last_quarter: 2024-06-28 21:53:25 UTC
```

#### Moonrise and moonset times and azimuths

Only date part of the time is relevant for the calculation. The offset must
be provided to the observer.

```rb
utc_offset = "-10:00"
time = Time.new(2024, 9, 1, 0, 0, 0, utc_offset)
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.from_degrees(-17.5325),
  longitude: Astronoby::Angle.from_degrees(-149.5677),
  utc_offset: utc_offset
)
moon = Astronoby::Moon.new(time: time)
observation_events = moon.observation_events(observer: observer)

observation_events.rising_time.getlocal(utc_offset)
# => 2024-09-01 05:24:55 -1000

observation_events.rising_azimuth.str(:dms)
# => "+72° 15′ 19.1814″"

observation_events.transit_time.getlocal(utc_offset)
# => 2024-09-01 11:12:32 -1000

observation_events.transit_altitude.str(:dms)
# => "+56° 39′ 59.132″"

observation_events.setting_time.getlocal(utc_offset)
# => 2024-09-01 16:12:08 -1000

observation_events.setting_azimuth.str(:dms)
# => "+290° 25′ 42.5421″"
```

## Precision

The current precision for the Sun's apparent location in the sky, compared 
to values computed by the [IMCCE] is approximately 1 arc minute. It corresponds
to twice the apparent size of Jupiter when it is the closest to Earth.

While the precision is not enough for very high accuracy computations, it is
equal to the Human naked eye's angular resolution.

[IMCCE]: https://www.imcce.fr

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to [rubygems.org].

[rubygems.org]: https://rubygems.org

## Contributing

Please see [CONTRIBUTING.md](https://github.com/rhannequin/astronoby/blob/main/CONTRIBUTING.md).

[code of conduct]: https://github.com/rhannequin/astronoby/blob/main/CODE_OF_CONDUCT.md

## License

The gem is available as open source under the terms of the [MIT License].

[MIT License]: https://opensource.org/licenses/MIT

## Code of Conduct

Everyone interacting in the Astronoby project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct].

[code of conduct]: https://github.com/rhannequin/astronoby/blob/main/CODE_OF_CONDUCT.md
