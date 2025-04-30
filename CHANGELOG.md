# Changelog

## 0.7.0 - 2025-05-12

_If you are upgrading: please see [UPGRADING.md]._

### Bug fixes

* Fix Moon monthly phase events calculation by @valeriy-sokoloff in ([#124])

### Features

* Add `Instant` value object ([#121])
* Introduce barycentric position of Solar System major bodies ([#127])
* Introduce Astrometric position for planets ([#129])
* Rename Barycentric into Geometric ([#130])
* Rename IRCF and remove module Position ([#131])
* Geometric and Astrometric reference frames with coordinates ([#132])
* Ecliptic coordinates for Geometric and Astrometric reference frames ([#134])
* Add Geometric and Astrometric positions for `Sun` and `Moon` ([#135])
* Implement new aberration correction ([#136])
* Precession matrix for 2006 P03 model ([#137])
* Introduce `MeanOfDate` reference frame ([#138])
* New nutation model ([#141])
* Light deflection correction ([#142])
* Introduce `Apparent` reference frame ([#143])
* Introduce `Topocentric` reference frame ([#145])
* Improve Vector integration with value objects ([#146])
* Handle refracted topocentric horizontal coordinates ([#147])
* Add `#angular_diameter` to apparent and topocentric reference frames ([#149])
* Introduce new calculator for rising, transit and setting times ([#148])
* Clean code after Ephem refactoring ([#152])
* Improve `RisingTransitSettingEventsCalculator` ([#155])
* Simplify `RisingTransitSettingEventsCalculator` ([#156])
* Lazy-load reference frames ([#157])
* Overall performance improvements ([#163])
* Add support for IMCCE INPOP by @JoelQ and @rhannequin ([#166])
* Update INPOP excerpt in spec data ([#167])
* Introduce a better rise/transit/set calculator ([#168])
* Drop `Astronoby::Observer#observe` ([#174])

### Improvements

* Bump standard from 1.42.1 to 1.49.0 by @dependabot ([#123], [#128], [#150], [#165])
* Bump rubyzip from 2.3.2 to 2.4.1 by @dependabot ([#120])
* Add more tests for Julian Date conversion ([#122])
* Upgrade main Ruby version and supported ones ([#125])
* Update email address and gem description ([#126])
* Increase precision of mean obliquity ([#133])
* Add supported Rubies ([#139])
* Set Ruby 3.4.2 as default version ([#140])
* Fix dependency secutiry patch ([#151])
* Improve HMS/DMS formats ([#153])
* Use excerpts ephemerides for specs of Sun and Moon ([#154])
* Add link to deprecated documentation ([#160])
* Default Ruby 3.4.3 and support recent rubies ([#169])
* Better Moon phases test coverage ([#172])
* Optimize Observer with GMST from Instant ([#173])
* Update README about documentation location ([#175])
* Add GitHub Actions permissions ([#176])

### New Contributors

* @valeriy-sokoloff made their first contribution in https://github.com/rhannequin/astronoby/pull/124
* @JoelQ made their first contribution in https://github.com/rhannequin/astronoby/pull/166

**Full Changelog**: https://github.com/rhannequin/astronoby/compare/v0.6.0...v0.7.0

[#120]: https://github.com/rhannequin/astronoby/pull/120
[#121]: https://github.com/rhannequin/astronoby/pull/121
[#122]: https://github.com/rhannequin/astronoby/pull/122
[#123]: https://github.com/rhannequin/astronoby/pull/123
[#124]: https://github.com/rhannequin/astronoby/pull/124
[#125]: https://github.com/rhannequin/astronoby/pull/125
[#126]: https://github.com/rhannequin/astronoby/pull/126
[#127]: https://github.com/rhannequin/astronoby/pull/127
[#128]: https://github.com/rhannequin/astronoby/pull/128
[#129]: https://github.com/rhannequin/astronoby/pull/129
[#130]: https://github.com/rhannequin/astronoby/pull/130
[#131]: https://github.com/rhannequin/astronoby/pull/131
[#132]: https://github.com/rhannequin/astronoby/pull/132
[#133]: https://github.com/rhannequin/astronoby/pull/133
[#134]: https://github.com/rhannequin/astronoby/pull/134
[#135]: https://github.com/rhannequin/astronoby/pull/135
[#136]: https://github.com/rhannequin/astronoby/pull/136
[#137]: https://github.com/rhannequin/astronoby/pull/137
[#138]: https://github.com/rhannequin/astronoby/pull/138
[#139]: https://github.com/rhannequin/astronoby/pull/139
[#140]: https://github.com/rhannequin/astronoby/pull/140
[#141]: https://github.com/rhannequin/astronoby/pull/141
[#142]: https://github.com/rhannequin/astronoby/pull/142
[#143]: https://github.com/rhannequin/astronoby/pull/143
[#145]: https://github.com/rhannequin/astronoby/pull/145
[#146]: https://github.com/rhannequin/astronoby/pull/146
[#147]: https://github.com/rhannequin/astronoby/pull/147
[#148]: https://github.com/rhannequin/astronoby/pull/148
[#149]: https://github.com/rhannequin/astronoby/pull/149
[#150]: https://github.com/rhannequin/astronoby/pull/150
[#151]: https://github.com/rhannequin/astronoby/pull/151
[#152]: https://github.com/rhannequin/astronoby/pull/152
[#153]: https://github.com/rhannequin/astronoby/pull/153
[#154]: https://github.com/rhannequin/astronoby/pull/154
[#155]: https://github.com/rhannequin/astronoby/pull/155
[#156]: https://github.com/rhannequin/astronoby/pull/156
[#157]: https://github.com/rhannequin/astronoby/pull/157
[#160]: https://github.com/rhannequin/astronoby/pull/160
[#163]: https://github.com/rhannequin/astronoby/pull/163
[#165]: https://github.com/rhannequin/astronoby/pull/165
[#166]: https://github.com/rhannequin/astronoby/pull/166
[#167]: https://github.com/rhannequin/astronoby/pull/167
[#168]: https://github.com/rhannequin/astronoby/pull/168
[#169]: https://github.com/rhannequin/astronoby/pull/169
[#172]: https://github.com/rhannequin/astronoby/pull/172
[#173]: https://github.com/rhannequin/astronoby/pull/173
[#174]: https://github.com/rhannequin/astronoby/pull/174
[#175]: https://github.com/rhannequin/astronoby/pull/175
[#176]: https://github.com/rhannequin/astronoby/pull/176

## 0.6.0 - 2024-12-10

_If you are upgrading: please see [UPGRADING.md]._

[UPGRADING.md]: https://github.com/rhannequin/astronoby/blob/main/UPGRADING.md

### Bug fixes

* Fix `ObservationEvents` infinite loop in ([#110])
* Fix observation events times with local time dates in ([#105])
* Fix `IncompatibleArgumentsError` on Moon's observation events in ([#111])

### Features

* Add `Astronoby::Moon#current_phase_fraction` in ([#115])
* Add sources and results for comparison in ([#114])

### Improvements

* Bump standard from 1.36.0 to 1.39.2 by @dependabot in ([#95])
* Bump standard from 1.39.2 to 1.40.0 by @dependabot in ([#96])
* Bump dependencies in ([#100])
* Move dependencies to development ones in ([#99])
* Bump standard from 1.40.0 to 1.41.1 by @dependabot in ([#104])
* Bump standard from 1.41.1 to 1.42.0 by @dependabot in ([#107])
* Bump standard from 1.42.0 to 1.42.1 by @dependabot in ([#108])
* Bump dependencies in ([#116])
* Add supported Ruby versions in ([#117])

**Full Changelog**: https://github.com/rhannequin/astronoby/compare/v0.5.0...v0.6.0

[#95]: https://github\.com/rhannequin/astronoby/pull/95
[#96]: https://github\.com/rhannequin/astronoby/pull/96
[#99]: https://github\.com/rhannequin/astronoby/pull/99
[#100]: https://github\.com/rhannequin/astronoby/pull/100
[#104]: https://github\.com/rhannequin/astronoby/pull/104
[#105]: https://github\.com/rhannequin/astronoby/pull/105
[#107]: https://github\.com/rhannequin/astronoby/pull/107
[#108]: https://github\.com/rhannequin/astronoby/pull/108
[#110]: https://github\.com/rhannequin/astronoby/pull/110
[#111]: https://github\.com/rhannequin/astronoby/pull/111
[#114]: https://github\.com/rhannequin/astronoby/pull/114
[#115]: https://github\.com/rhannequin/astronoby/pull/115
[#116]: https://github\.com/rhannequin/astronoby/pull/116
[#117]: https://github\.com/rhannequin/astronoby/pull/117

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
