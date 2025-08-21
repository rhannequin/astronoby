# Equinoxes and Solstices Times

The equinox and solstice are two precise events that each happen twice a year.

The equinox is the time when the Sun appears directly above the equator, the
solstice is the time when the Sun reaches its most northerly or southerly
excursion relative to the celestial equator on the celestial sphere.

Astronoby enables to compute the time for each of these four events.

```rb
ephem = Astronoby::Ephem.load("inpop19a.bsp")

Astronoby::EquinoxSolstice.march_equinox(2025, ephem)
# => 2025-03-20 09:01:29 UTC

Astronoby::EquinoxSolstice.june_solstice(2025, ephem)
# => 2025-06-21 02:42:19 UTC

Astronoby::EquinoxSolstice.september_equinox(2025, ephem)
# => 2025-09-22 18:19:22 UTC

Astronoby::EquinoxSolstice.december_solstice(2025, ephem)
# => 2025-12-21 15:03:03 UTC
```
