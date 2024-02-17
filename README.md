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

This library is still in heavy development. The following API is likely to 
change any time.

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

horizontal_coordinates.altitude.value.to_f
# => 27.50236513017543

horizontal_coordinates.altitude.to_dms.format
# => "+27° 30′ 8.5144″"
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

Bug reports and pull requests are welcome on GitHub at
https://github.com/rhannequin/astronoby. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct].

[code of conduct]: https://github.com/rhannequin/astronoby/blob/main/CODE_OF_CONDUCT.md

## License

The gem is available as open source under the terms of the [MIT License].

[MIT License]: https://opensource.org/licenses/MIT

## Code of Conduct

Everyone interacting in the Astronoby project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct].

[code of conduct]: https://github.com/rhannequin/astronoby/blob/main/CODE_OF_CONDUCT.md
