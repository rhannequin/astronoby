# Configuration

Astronoby handles an internal configuration to enable users to tweak the
performance and precision of computed data.

## Cache

Some calculations are expensive but also repetitive in the intermediate computed
data. To improve performance, an internal cache system has been developed.

➡️ **Please note caching is disabled by default.**

### Enable caching

You can turn caching on with the following command:

```rb
Astronoby.configuration.cache_enabled = true
```

Once caching is enabled, it will be used for the following parts of the library
with default precision values:
* [Geometric positions]
* [Topocentric positions] when computing rising/transit/setting times
* [Moon phases]
* Nutation
* Precession

## Cache precision

When cache is enabled, some data is cached following a default precision
threshold so that precision doesn't noticeably decrease.

However, users may want to improve performance even more at the cost of some
precision.

It is possible to change the precision value for the following:
* Geometric position, default: `9`
* Topocentric position, default: `5`
* Nutation, default: `2`
* Precession, default: `2`

### Precision value

The precision value is how much rounded instants are. Because instants are
stored as a [Julian Day], rounding may not seem very natural.

Let's take the example of `1`. Rounding a Julian Day with only one digit means
that all times within 8640 seconds will be rounded to the same instant, which
means a maximum rounding of 2.4 hours.

* `1`: 2.4 hours
* `2`: 14.4 minutes
* `3`: 86.4 seconds
* `4`: 8.6 seconds
* `5`: 0.86 seconds
* `6`: 0.086 seconds
* `7`: 0.0086 seconds
* ...

### Setting custom precision

To set up your own precision, you can use:

```rb
Astronoby.cache_precision(:geometric, 5)
```

All geometric positions of the same celestial body within 0.86 seconds will be
rounded and cached.

## Cache size

Cache has limited and configurable capacity, set by default to 10,000 stored
items. This value can be changed to any positive number.

```rb
Astronoby.configuration.cache_enabled = true

Astronoby.cache.max_size
# => 10000

Astronoby.cache.max_size = 1000000

Astronoby.cache.max_size
# => 1000000
```

[Geometric positions]: reference_frames.md#geometric
[Topocentric positions]: reference_frames.md#topocentric
[Moon phases]: moon_phases.md
[Julian Day]: https://en.wikipedia.org/wiki/Julian_day

## See also
- [Reference Frames](reference_frames.md) - for understanding position calculations
- [Ephemerides](ephem.md) - for data sources
- [Performance Benchmarks](benchmarks/README.md) - for testing improvements
- [Cache System](cache.md) - for detailed caching information
