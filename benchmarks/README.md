# Benchmark

This is a first attempt to benchmark the accuracy of the library. It is not
very scientific, but it gives a rough idea.

## Method

The goal is to answer these two questions:
- Is the library accurate enough compared to a source of truth?
- Is the library accurate enough compared with other Ruby libraries?

The source of truth is the <abbr title="Institut de Mécanique
Céleste et de Calcul des Éphémérides">IMCCE</abbr>, a French public
institude attached to the Paris Observatory. Their ephemerides are used by
governements and public institutions in multiple European countries, their
precesion is among the highest in the world.
They also provide web services to easily access all their data. Many thanks
for providing such high accuracy data for free.

The other Ruby library is [sun_calc](https://github.com/fishbrain/sun_calc).

474,336 combinations of dates, latitudes and longitudes have been used to
produce time predictions for the following events:
- sunrise
- sun's highest point
- sunset
- moonrise
- moon's highest point
- moonset

For each combination, we first find out which of SunCalc or Astronoby is the
closest to the IMCCE. Then we calculate the difference between Astronoby and
the IMCCE, to discover if the difference is larger than the defined
threshold of 5 minutes.

## Results

The following output has been generated using what will be part of version 0.6.

```
Unarchiving sun_calc.csv.zip...
Done unarchiving sun_calc.csv.zip.
Parsing sun_calc.csv...
Done parsing sun_calc.csv.
Unarchiving imcce.csv.zip...
Done unarchiving imcce.csv.zip.
Parsing imcce.csv...
Done parsing imcce.csv.
Comparing data...
2024-01-01: Done.
2024-01-02: Done.
...
2024-12-30: Done.
2024-12-31: Done.
Done comparing data.


Sun rising time:
astronoby: 295395 (62.28%)
sun_calc: 99710 (21.02%)
n/a: 79231 (16.7%)

Sun transit time:
astronoby: 434495 (91.6%)
sun_calc: 39769 (8.38%)
n/a: 72 (0.02%)

Sun setting time:
astronoby: 358428 (75.56%)
n/a: 79231 (16.7%)
sun_calc: 36677 (7.73%)

Moon rising time:
astronoby: 290866 (61.32%)
n/a: 113815 (23.99%)
sun_calc: 69655 (14.68%)

Moon transit time:
astronoby: 341902 (72.08%)
n/a: 101916 (21.49%)
sun_calc: 30518 (6.43%)

Moon setting time:
astronoby: 327099 (68.96%)
n/a: 114308 (24.1%)
sun_calc: 32929 (6.94%)

Moon illuminated fraction:
astronoby: 474336 (100.0%)

Sun rising time too far:
false: 452887 (95.48%)
true: 21449 (4.52%)

Sun transit time too far:
false: 396617 (83.62%)
true: 77719 (16.38%)

Sun setting time too far:
false: 453208 (95.55%)
true: 21128 (4.45%)

Moon rising time too far:
false: 459044 (96.78%)
true: 15292 (3.22%)

Moon transit time too far:
false: 384516 (81.06%)
true: 89820 (18.94%)

Moon setting time too far:
false: 459222 (96.81%)
true: 15114 (3.19%)
```

## Conclusion

As we can see, Astronoby is more accurate than SunCalc in a vast majority of
cases. When it comes to the Moon's illuminated fraction, Astronoby is always
more accurate than SunCalc.

`n/a` values means that at least one of the three sources don't have a value
for the combination of date, latitude and longitude. This happens because
the Moon and the Sun cannot always rise, transit and set everywhere on Earth
every day of the year. Latitudes close to the poles are more likely to miss
data.

Astronoby can be considered "good enough" for more around 90% of the cases,
which means there is still work to do if we want to always be less than 5
minutes away from the what the IMCCE provides. We can notice that transit
times are those that experience the most significant differences.
