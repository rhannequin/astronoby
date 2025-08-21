# Astronoby

[![Tests](https://github.com/rhannequin/astronoby/workflows/Ruby/badge.svg)](https://github.com/rhannequin/astronoby/actions?query=workflow%3ARuby)

Ruby library that provides a useful API for computing astronomical calculations.

Some algorithms are based on the following astrometry books:
* _Astronomical Algorithms_ by Jean Meeus
* _Celestial Calculations_ by J. L. Lawrence
* _Practical Astronomy with your Calculator or Spreadsheet_ by Peter
  Duffet-Smith and Jonathan Zwart

Solar System bodies' positions are computed based on ephemerides from the
[IMCCE] or [NASA/JPL].

## Content
- [Installation](#installation)
- [Usage Documentation](#usage-documentation)
- [Precision](#precision)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add astronoby

If [Bundler] is not being used to manage dependencies, install the gem by
executing:

    $ gem install astronoby

## Usage Documentation

Since version 0.7.0, the usage documentation resides in [`docs/`]. For
previous versions, you can access the documentation in the README for each
[release].

### See also
- [Quick Start Guide](docs/README.md) - for getting started examples
- [Celestial Bodies](docs/celestial_bodies.md) - for understanding planets and objects
- [Reference Frames](docs/reference_frames.md) - for coordinate systems
- [Observer Setup](docs/observer.md) - for location configuration
- [Glossary](docs/glossary.md) - for astronomical and technical terms

### Expected breaking changes notice

This library is still in heavy development. The public API is not stable, so
please be aware that new minor versions will probably lead to breaking changes
until a major one is released.

Changes are documented in the [CHANGELOG] and adapting to breaking changes is
described in the [UPGRADING] document.

## Precision

The current precision for the major Solar System bodies' locations in the sky
as seen from an observer on Earth is below 10 arc seconds. This corresponds to
half the size of Saturn when it is closest to Earth.

While the precision is not enough for spacecraft navigation, it is enough for
automated guiding of amateur telescopes.

The sources used for comparison are: [IMCCE], [JPL Horizons], [Stellarium],
and the [Skyfield] library.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to [rubygems.org].

### Performance

The library is designed to be fast, but there is always room for improvement.
When comparing the performance of two implementations, please use the
performance benchmark in the console before and after your implementation.

    $ bin/console

```rb
require_relative "benchmarks/performance"

PerformanceBenchmark.new.run
```

For fast feedback, you can customise the parameters:

```rb
PerformanceBenchmark
  .new(warmup_runs: 1, measure_runs: 3, iterations_per_run: 5)
  .run
```

Performance is not absolute, which is why the results are not documented here.
What is important is to compare the relative performance of two implementations
and make sure new features do not degrade performance.

## Contributing

Please see [CONTRIBUTING.md].

## License

The gem is available as open source under the terms of the [MIT License].

[MIT License]: https://opensource.org/licenses/MIT

## Code of Conduct

Everyone interacting in the Astronoby project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct].

[NASA/JPL]: https://ssd.jpl.nasa.gov/planets/eph_export.html
[Bundler]: https://bundler.io
[`docs/`]: https://github.com/rhannequin/astronoby/blob/main/docs
[release]: https://github.com/rhannequin/astronoby/releases
[CHANGELOG]: https://github.com/rhannequin/astronoby/blob/main/CHANGELOG.md
[UPGRADING]: https://github.com/rhannequin/astronoby/blob/main/UPGRADING.md
[IMCCE]: https://www.imcce.fr
[JPL Horizons]: https://ssd.jpl.nasa.gov/horizons.cgi
[Stellarium]: https://stellarium.org
[Skyfield]: https://rhodesmill.org/skyfield/
[rubygems.org]: https://rubygems.org
[CONTRIBUTING.md]: https://github.com/rhannequin/astronoby/blob/main/CONTRIBUTING.md
[code of conduct]: https://github.com/rhannequin/astronoby/blob/main/CODE_OF_CONDUCT.md
