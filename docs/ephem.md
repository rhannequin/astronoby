# `Ephem`

`Astronoby` depends on the gem [`ephem`] which provides a Ruby interface for
<abbr title="Jet Propulsion Laboratory">JPL</abbr> SPICE binary kernels.

These kernels are extremely precise ephemerides produced by the JPL and are the
foundation of the data provided by Astronoby. The [IMCCE] also produces
kernels in the same format for their
<abbr title="Intégrateur numérique planétaire de l'Observatoire de Paris">INPOP</abbr>
model.

## Download an ephemeris

To download an ephemeris, you can either do it manually or use `ephem` by
providing the filename.

### Manually

Ephemerides are available for download from:
* the JPL public FTP interface: https://ssd.jpl.nasa.gov/ftp/eph/planets/bsp/
* the INPOP releases page of the IMCCE: https://www.imcce.fr/inpop

You can download any `.bsp` file. For the moment, Astronoby only supports the
planets of the Solar System, and the Sun and the Moon, so you need to
download a _Development Ephemeris_, which starts with `de` (i.e. `de421.bsp`),
or any of the INPOP ephemeris files (i.e. `inpop19a.bsp`).

### With `Ephem`

If you already know the ephemeris you want to use, you can use `Ephem` to
download and store it for you:

```rb
Astronoby::Ephem.download(name: "de421.bsp", target: "tmp/de421.bsp")
```

## Load an ephemeris

To compute the position of a Solar System body, you need to provide an ephemeris
to extract the data from. You can use `Astronoby::Ephem` to load the file you
downloaded.

```rb
ephem = Astronoby::Ephem.load("tmp/de421.bsp")
```

## How to choose the right ephemeris?

JPL produces many different kernels over the years, with different accuracy and
ranges of supported years. Here are some that we recommend to begin with:
- `de421.bsp`: from 1900 to 2050, 17 MB
- `de440s.bsp`: from 1849 to 2150, 32 MB
- `inpop19a.bsp`: from 1900 to 2100, 22 MB

## How to limit weight and increase speed?

The `Ephem` library offers a <abbr title="Command-Line Interface">CLI</abbr> to
produce excerpt ephemerides in order to limit the range of dates or bodies.

Here is an example to produce an excerpt ephemeris for the year 2025:

```
ruby-ephem excerpt 2024-12-31 2026-01-01 de440s.bsp de440s_2025_excerpt.bsp
```

You can also specify which bodies of the Solar System (or "targets") you want to
include:

```
ruby-ephem excerpt --targets 10,399 2024-12-31 2026-01-01 inpop19a.bsp inpop19a_2025_sun_earth.bsp
```

You may want to check how bodies are handled between JPL DE and IMCCE INPOP. For
example, the excerpt file from a JPL DE kernel needs to include targets `3` and
`399` for the Earth, while the excerpt file from a IMCCE INPOP kernel only needs
the target `399`.

[`ephem`]: https://github.com/rhannequin/ruby-ephem
[IMCCE]: https://www.imcce.fr

## See also
- [Solar System Bodies](solar_system_bodies.md) - for using ephemeris data
- [Reference Frames](reference_frames.md) - for coordinate calculations
- [Observer](observer.md) - for location-based calculations
- [Configuration](configuration.md) - for performance tuning
