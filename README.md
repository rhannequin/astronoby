# Astronoby

[![Tests](https://github.com/rhannequin/astronoby/workflows/Ruby/badge.svg)](https://github.com/rhannequin/astronoby/actions?query=workflow%3ARuby)

Ruby library to provide a useful API to compute astronomical calculations, based
on astrometry books.

The main reference is:
- _Astronomical Algorithms_ by Jean Meeus
- _Celestial Calculations_ by J. L. Lawrence
- _Practical Astronomy with your Calculator or Spreadsheet_ by Peter
  Duffet-Smith and Jonathan Zwart

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add astronoby

If bundler is not being used to manage dependencies, install the gem by
executing:

    $ gem install astronoby

## Usage

This library is still in heavy development. The public is not stable, please
be aware new minor versions will probably lead to breaking changes until a
major one is released.

### Angle manipulation

```rb
angle1 = Astronoby::Angle.as_degrees(90)
angle2 = Astronoby::Angle.as_radians(Astronoby::Angle::PI / 2)
angle3 = Astronoby::Angle.as_hours(12)

angle1 == angle2
# => true

angle1 < angle3
# => true

angle = angle1 + angle2 + angle3
angle.cos
# => 1.0
```

### Coordinates conversion

```rb
equatorial = Astronoby::Coordinates::Equatorial.new(
  right_ascension: Astronoby::Angle.as_hms(17, 43, 54),
  declination: Astronoby::Angle.as_dms(-22, 10, 0)
)

horizontal = equatorial.to_horizontal(
  time: Time.new(2016, 1, 21, 21, 30, 0, "-05:00"),
  latitude: Astronoby::Angle.as_degrees(38),
  longitude: Astronoby::Angle.as_degrees(-78)
)

horizontal.altitude.str(:dms)
# => "-73° 27′ 19.1557″"

horizontal.azimuth.str(:dms)
# => "+341° 33′ 21.587″"
```

### Sun's location in the sky

```rb
time = Time.utc(2023, 2, 17, 11, 0, 0)
epoch = Astronoby::Epoch.from_time(time)

latitude = Astronoby::Angle.as_degrees(48.8566)
longitude = Astronoby::Angle.as_degrees(2.3522)

sun = Astronoby::Sun.new(epoch: epoch)

horizontal_coordinates = sun.horizontal_coordinates(
  latitude: latitude,
  longitude: longitude
)

horizontal_coordinates.altitude.degrees.to_f
# => 27.50008242057459

horizontal_coordinates.altitude.str(:dms)
# => "+27° 30′ 0.2967″"
```

### Sunrise and sunset times and azimuths

```rb
date = Date.new(2015, 2, 5)
epoch = Astronoby::Epoch.from_time(date)
observer = Astronoby::Observer.new(
  latitude: Astronoby::Angle.as_degrees(38),
  longitude: Astronoby::Angle.as_degrees(-78)
)
sun = Astronoby::Sun.new(epoch: epoch)

sun.rising_time(observer: observer)
# => 2015-02-05 12:13:26 UTC

sun.rising_azimuth(observer: observer).str(:dms)
# => "+109° 41′ 22.2585″"

sun.setting_time(observer: observer)
# => 2015-02-05 22:35:12 UTC

sun.setting_azimuth(observer: observer).str(:dms)
# => "+250° 18′ 37.7414″"
```

### Solstice and Equinox times

```rb
year = 2024

Astronoby::EquinoxSolstice.march_equinox(year)
# => 2024-03-20 03:05:08 UTC

Astronoby::EquinoxSolstice.june_solstice(year)
# => 2024-06-20 20:50:18 UTC
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
