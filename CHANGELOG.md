# Changelog

## 0.5.0 - 2024-06-11

_If you are upgrading: please see [UPGRADING.md]._

[UPGRADING.md]: https://github.com/rhannequin/astronoby/blob/main/UPGRADING.md

### Features

* Make `Sun#mean_anomaly` public ([#72])
* Moon ecliptic coordinates ([#73])
* Moon apparent geocentric equatorial coordinates ([#75])
* Moon horizontal coordinates ([#76])
* Assume Moon's equatorial coordinates are geocentric ([#77])
* Use observer object for geocentric parallax ([#79])
* Moon's phase angle and illuminated fraction ([#80])
* Monthly Moon phases ([#82])
* Rationalize negative degree angles ([#83])
* Factorize Moon phases periodic terms ([#85])
* Introduce observation events for Moon ([#86])

[#72]: https://github.com/rhannequin/astronoby/pull/72
[#73]: https://github.com/rhannequin/astronoby/pull/73
[#75]: https://github.com/rhannequin/astronoby/pull/75
[#76]: https://github.com/rhannequin/astronoby/pull/76
[#77]: https://github.com/rhannequin/astronoby/pull/77
[#79]: https://github.com/rhannequin/astronoby/pull/79
[#80]: https://github.com/rhannequin/astronoby/pull/80
[#82]: https://github.com/rhannequin/astronoby/pull/82
[#83]: https://github.com/rhannequin/astronoby/pull/83
[#85]: https://github.com/rhannequin/astronoby/pull/85
[#86]: https://github.com/rhannequin/astronoby/pull/86

### Improvements

* Create FUNDING.yml ([#70])
* Bump standard from 1.35.1 to 1.36.0 ([#71])
* Bump rexml from 3.2.6 to 3.2.8 ([#74])
* Expand the number of tested Ruby versions ([#84])
* Add Ruby 3.1.6 and 3.3.2 coverage ([#88])
* Improve and update documentation ([#87])
* Update UPGRADING.md ([#89])

[#70]: https://github.com/rhannequin/astronoby/pull/70
[#71]: https://github.com/rhannequin/astronoby/pull/71
[#74]: https://github.com/rhannequin/astronoby/pull/74
[#84]: https://github.com/rhannequin/astronoby/pull/84
[#88]: https://github.com/rhannequin/astronoby/pull/88
[#87]: https://github.com/rhannequin/astronoby/pull/87
[#89]: https://github.com/rhannequin/astronoby/pull/89

### Backward-incompatible changes

* Use Observer in Horizontal coordinates ([#69])
* Introduce `Astronoby::Distance` value object ([#78])

[#69]: https://github.com/rhannequin/astronoby/pull/69
[#78]: https://github.com/rhannequin/astronoby/pull/78

**Full Changelog**: https://github.com/rhannequin/astronoby/compare/v0.4.0...v0.5.0

## 0.4.0 - 2024-04-29

_If you are upgrading: please see [UPGRADING.md]._

[UPGRADING.md]: https://github.com/rhannequin/astronoby/blob/main/UPGRADING.md

### Bug fixes

* Fix ecliptic to equatorial epoch ([#56])

[#56]: https://github.com/rhannequin/astronoby/pull/56

### Features

* Add twilight times ([#49])
* Add interpolation method ([#52])
* Add decimal_hour_to_time util ([#53])
* Calculate leap seconds for an instant ([#54])
* Add `Angle#-@` ([#55])
* Enable equivalence and hash equality to `Observer` ([#57])
* Twilight events dedicated class ([#61])

[#49]: https://github.com/rhannequin/astronoby/pull/49
[#52]: https://github.com/rhannequin/astronoby/pull/52
[#53]: https://github.com/rhannequin/astronoby/pull/53
[#54]: https://github.com/rhannequin/astronoby/pull/54
[#55]: https://github.com/rhannequin/astronoby/pull/55
[#57]: https://github.com/rhannequin/astronoby/pull/57
[#61]: https://github.com/rhannequin/astronoby/pull/61

### Improvements

* Upgrade bundler from 2.3.11 to 2.5.7 by @dorianmariecom ([#45])
* Drop `BigDecimal` ([#46])
* Bump rake from 13.1.0 to 13.2.0 ([#47])
* Increase Ruby versions support ([#48])
* Bump rake from 13.2.0 to 13.2.1 ([#51])
* Dedicated constants class ([#62])
* Improve accuracy of equation of time ([#63])
* Twilight times better accuracy ([#65])
* Update UPGRADING.md ([#66])
* release: Bump version to 0.4.0 ([#67])

[#45]: https://github.com/rhannequin/astronoby/pull/45
[#46]: https://github.com/rhannequin/astronoby/pull/46
[#47]: https://github.com/rhannequin/astronoby/pull/47
[#48]: https://github.com/rhannequin/astronoby/pull/48
[#51]: https://github.com/rhannequin/astronoby/pull/51
[#62]: https://github.com/rhannequin/astronoby/pull/62
[#63]: https://github.com/rhannequin/astronoby/pull/63
[#65]: https://github.com/rhannequin/astronoby/pull/65
[#66]: https://github.com/rhannequin/astronoby/pull/66
[#67]: https://github.com/rhannequin/astronoby/pull/67

### Backward-incompatible changes

* More accurate rising, transit and setting times ([#50])
* Observation events dedicated and centralized class ([#60])
* Change `Astronoby::Sun` constructor ([#64])

[#50]: https://github.com/rhannequin/astronoby/pull/50
[#60]: https://github.com/rhannequin/astronoby/pull/60
[#64]: https://github.com/rhannequin/astronoby/pull/64

### New Contributors

* @dorianmariecom made their first contribution in [#45]

[#45]: https://github.com/rhannequin/astronoby/pull/45

**Full Changelog**: https://github.com/rhannequin/astronoby/compare/v0.3.0...v0.4.0

## 0.3.0 - 2024-03-29

_If you are upgrading: please see [`UPGRADING.md`]._

### Improvements

* Drop `Angle#==` ([#42])
* Improved accuracy with Sun's location predictions ([#41])

### Breaking changes

* **breaking:** Difference between true and apparent ecliptic and equatorial
  coordinates ([#41])
* **breaking:** Rename `Angle::as_*` into `Angle::from_*` ([#43])

[#41]: https://github.com/rhannequin/astronoby/pull/41
[#42]: https://github.com/rhannequin/astronoby/pull/42
[#43]: https://github.com/rhannequin/astronoby/pull/43

## 0.2.0 - 2024-03-24

_If you are upgrading: please see [`UPGRADING.md`]._

### Features

* Angle comparison ([#21])
* Add `#distance` and `#angular_size` to `Astronoby::Sun` ([#30])
* Add geocentric parallax `Astronoby::GeocentricParallax` ([#31])
* Ability to calculate equinoxes and solstices times ([#32])
* Round rising and setting times to the second ([#38])
* Provide sunrise and sunset times ([#35])
* Provide sunrise and sunset azimuths ([#39])
* Ability to calculate the equation of time ([#40])

### Breaking changes

* **breaking:** Accurate setting and rising times for punctual bodies ([#29])
* **breaking:** Drop `Astronoby::Util::Time` in favor of
  `Astronoby::GreenwichSiderealTime` and `Astonoby::LocalSiderealTime` ([#36])

### Improvements

* Add Dependabot for Bundler and GitHub Actions ([#24])
* Add bundler-audit GitHub Action ([#25])
* Bump actions/checkout from 3 to 4 ([#26])
* Bump standard from 1.29.0 to 1.35.1 ([#27], [#37])
* Bump rspec from 3.12.0 to 3.13.0 ([#28])

[#21]: https://github.com/rhannequin/astronoby/pull/21
[#24]: https://github.com/rhannequin/astronoby/pull/24
[#25]: https://github.com/rhannequin/astronoby/pull/25
[#26]: https://github.com/rhannequin/astronoby/pull/26
[#27]: https://github.com/rhannequin/astronoby/pull/27
[#28]: https://github.com/rhannequin/astronoby/pull/28
[#29]: https://github.com/rhannequin/astronoby/pull/29
[#30]: https://github.com/rhannequin/astronoby/pull/30
[#31]: https://github.com/rhannequin/astronoby/pull/31
[#32]: https://github.com/rhannequin/astronoby/pull/32
[#35]: https://github.com/rhannequin/astronoby/pull/35
[#36]: https://github.com/rhannequin/astronoby/pull/36
[#37]: https://github.com/rhannequin/astronoby/pull/37
[#28]: https://github.com/rhannequin/astronoby/pull/38
[#39]: https://github.com/rhannequin/astronoby/pull/39
[#40]: https://github.com/rhannequin/astronoby/pull/40

## 0.1.0 - 2024-02-28

### Features

* Support angles in hours
* Support coordinates
  * `Astronoby::Coordinates::Horizontal`
  * `Astronoby::Coordinates::Equatorial`
  * `Astronoby::Coordinates::Ecliptic`
* Add new body `Astronoby::Sun`
* Add `Astronoby::Aberration`
* Add `Astronoby::Epoch`
* Add `Astronoby::MeanObliquity`
* Add `Astronoby::TrueObliquity`
* Add `Astronoby::Nutation`
* Add `Astronoby::Precession`
* Add `Astronoby::Refraction`
* Add utils
  * `Astronoby::Util::Astrodynamics`
  * `Astronoby::Util::Time`
  * `Astronoby::Util::Trigonometry`

## 0.0.1 - 2022-04-20

* Add `Astronoby::Angle`
* Support angles in degrees and radians

[`UPGRADING.md`]: https://github.com/rhannequin/astronoby/blob/main/UPGRADING.md
