# Glossary

This glossary defines key astronomical and technical terms used throughout the Astronoby documentation.

## Astronomical Terms

### **Aberration**
The apparent displacement of a celestial object due to the finite speed of light and the motion of the observer. In Astronoby, this is automatically corrected in apparent reference frames.

### **Altitude**
The angular distance of a celestial object above the observer's local horizon, measured in degrees from 0° (horizon) to 90° (zenith).

### **Apparent Position**
The position of a celestial object as it appears in the sky, corrected for light-time, aberration, and other effects. This is what you actually see when looking through a telescope.

### **Arc Second**
A unit of angular measurement equal to 1/3600th of a degree. Often used to describe the precision of astronomical calculations.

### **Azimuth**
The angular distance around the horizon from north, measured clockwise in degrees. North is 0°, east is 90°, south is 180°, and west is 270°.

### **Barycentre**
The centre of mass of a system of bodies. In the Solar System, this is the point around which all planets orbit, which is usually close to but not exactly at the Sun's centre.

### **Celestial Equator**
The projection of Earth's equator onto the celestial sphere. It's the reference plane for equatorial coordinates.

### **Celestial Sphere**
An imaginary sphere surrounding Earth, on which all celestial objects appear to be located. Used as a reference system for astronomical coordinates.

### **Constellation**
A region of the sky containing a group of stars that form a recognizable pattern. Astronoby can determine which constellation a celestial body appears to be in.

### **Declination**
The angular distance north or south of the celestial equator, measured in degrees. Positive values are north, negative values are south.

### **Ecliptic**
The apparent path of the Sun across the celestial sphere throughout the year. It's the plane of Earth's orbit around the Sun.

### **Ephemeris**
A table or file containing the calculated positions of celestial objects at specific times. Astronoby uses ephemeris files from JPL and IMCCE for high-precision calculations.

### **Equinox**
The two times each year when the Sun crosses the celestial equator, making day and night approximately equal in length. The March (vernal) and September (autumnal) equinoxes.

### **Geocentric**
As seen from the centre of Earth. Geocentric coordinates are useful for calculations but don't account for an observer's specific location.

### **Horizon**
The apparent boundary between Earth and sky as seen by an observer. The local horizon depends on the observer's location and elevation.

### **Illuminated Fraction**
The portion of a celestial body's disk that appears illuminated as seen from Earth. For the Moon, this varies from 0 (new moon) to 1 (full moon).

### **Julian Date**
A continuous count of days since January 1, 4713 BCE. Used in astronomy for precise time measurements and calculations.

### **Light-Time Correction**
The adjustment made to account for the time it takes light to travel from a celestial object to Earth. Important for accurate position calculations.

### **Magnitude**
A measure of a celestial object's brightness. Lower numbers indicate brighter objects (e.g., -4 is brighter than +2). Apparent magnitude is as seen from Earth, absolute magnitude is intrinsic brightness.

### **Meridian**
An imaginary line passing through the observer's zenith and the north and south celestial poles. Objects transit (cross) the meridian when they reach their highest point in the sky.

### **Nutation**
Small periodic variations in the orientation of Earth's rotation axis, caused by gravitational forces from the Sun and Moon.

### **Obliquity**
The angle between Earth's equatorial plane and the ecliptic plane. Currently about 23.4° and slowly decreasing.

### **Parallax**
The apparent shift in position of a nearby object when viewed from different locations. Important for calculating distances to nearby stars.

### **Phase Angle**
The angle between the Sun, a celestial object, and Earth. For planets, this determines how much of the disk is illuminated.

### **Precession**
The slow, continuous change in the orientation of Earth's rotation axis, causing the positions of the equinoxes to shift over time.

### **Refraction**
The bending of light as it passes through Earth's atmosphere, causing celestial objects to appear slightly higher in the sky than they actually are.

### **Right Ascension**
The angular distance eastward along the celestial equator from the vernal equinox, measured in hours (0-24h) or degrees (0-360°).

### **Solstice**
The two times each year when the Sun reaches its northernmost (June) or southernmost (December) position relative to the celestial equator.

### **Topocentric**
As seen from a specific location on Earth's surface. Topocentric positions account for the observer's latitude, longitude, and elevation.

### **Transit**
The moment when a celestial object crosses the observer's meridian, reaching its highest point in the sky for that day.

### **Twilight**
The period before sunrise and after sunset when the sky is partially illuminated by scattered sunlight. Civil, nautical, and astronomical twilight have different definitions based on the Sun's position below the horizon.

### **Zenith**
The point directly above an observer on Earth, at an altitude of 90°.

## Technical Terms

### **API (Application Programming Interface)**
The set of methods and classes that programmers use to interact with the Astronoby library.

### **Cache**
A temporary storage system that stores frequently used calculation results to improve performance.

### **Coordinate System**
A system for specifying the position of objects in space. Astronoby supports equatorial, ecliptic, and horizontal coordinate systems.

### **Ephemeris File**
A binary file (usually with .bsp extension) containing orbital data for Solar System bodies. These files are produced by JPL and IMCCE.

### **Floating-Point Precision**
The accuracy of decimal number calculations. Higher precision values in Astronoby provide more accurate results but may be slower.

### **Reference Frame**
A coordinate system used to specify positions. Astronoby provides geometric, astrometric, mean of date, apparent, and topocentric reference frames.

### **SPICE**
A NASA toolkit for computing positions and orientations of Solar System bodies. Astronoby uses SPICE binary kernels (.bsp files) for ephemeris data.

### **UTC (Coordinated Universal Time)**
The primary time standard used worldwide. All astronomical calculations in Astronoby are based on UTC.

## Units and Measurements

### **Angular Units**
- **Degree (°)**: 1/360th of a circle
- **Arc Minute (′)**: 1/60th of a degree
- **Arc Second (″)**: 1/60th of an arc minute
- **Hour (h)**: 15 degrees (used for right ascension)
- **Radian**: 180/π degrees (≈57.3°)

### **Distance Units**
- **Astronomical Unit (AU)**: The average distance between Earth and Sun (≈149.6 million km)
- **Kilometre (km)**: Standard metric unit for distances
- **Metre (m)**: Standard metric unit for elevations

### **Time Units**
- **Julian Day**: Continuous day count since 4713 BCE
- **Terrestrial Time (TT)**: Astronomical time scale used for calculations
- **UTC**: Coordinated Universal Time, the standard for civil time

## See also
- [Quick Start Guide](README.md) - for getting started
- [Coordinates](coordinates.md) - for coordinate systems
- [Reference Frames](reference_frames.md) - for position calculations
- [Angles](angles.md) - for angular measurements
