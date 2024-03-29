# Changelog

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
